//
//  MissionAccess.swift
//  Mapotempo-Fleet
//
//  Created by julien boyer on 18/05/2018.
//  Copyright © 2018 julien boyer. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift

class MissionAccess {
    
    // Mark: properties
    var db: Database
    
    init(db: Database) {
        self.db = db
    }
    
    func createMission() -> IMission {
        return MissionCouchbase(db)
    }
    
    func getMissions() -> [IMission] {
        var missions = [IMission]()
        
        var selectors: [SelectResultProtocol] = [SelectResultProtocol]()
        for key in MDbKeys.getAll() {
            selectors.append(SelectResult.property(key))
        }
        
        selectors.append(SelectResult.expression(Meta.id))
        
        let query = QueryBuilder.select(selectors)
            .from(DataSource.database(db))
            .where(Expression.property("type").equalTo(Expression.string(MissionCouchbase.type)))
        
        guard let models = try? query.execute() else {
            fatalError("Error during the Cbdb query");
        }
        
        for row: Result in models {
            var mission: IMission = MissionCouchbase(db)

            // Db is supposed to be trustable
            mission.properties(map: row.toDictionary())
            missions.append(mission)
        }

        return missions
    }
}
