//
//  BaseCouchBase.swift
//  Mapotempo-Fleet
//
//  Created by julien boyer on 27/04/2018.
//  Copyright © 2018 julien boyer. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift

class CouchbaseWrapper {
    
    // MARK: Properties
    let login: String
    let password: String
    let dbName: String
    
    let demo: Bool = true
    
    // MARK: CouchBaseObjects
    var database: Database?
    
    // SINGLETON:
    private static var Instance: CouchbaseWrapper?
    
    public static func GetInstance() -> CouchbaseWrapper {
        if CouchbaseWrapper.Instance == nil {
            Database.setLogLevel(.debug, domain: .all)
            CouchbaseWrapper.Instance = CouchbaseWrapper.init(login: Logins.name.rawValue, password: Logins.password.rawValue, dbName: Logins.dbName.rawValue)
        }
        
        return CouchbaseWrapper.Instance!
    }
    
    // MARK: Constructors
    private init?(login: String, password: String, dbName: String) {
        guard !login.isEmpty || !password.isEmpty || !dbName.isEmpty else {
            return nil
        }
        self.password = password
        self.login = login
        self.dbName = dbName
        
        if !initDatabase() {
            return nil
        }
        
        if self.demo {
            fakeData()
        }
    }
    
    private func initDatabase() -> Bool {
        database = try? Database(name: dbName)
        return database != nil
    }
    
    // MARK: Public Accessors
    
    public func missionAccess() -> MissionAccess {
        return MissionAccess(db: database!)
    }
    
    // MARK: DEBUG ONLY, FAKE DATA
    
    private func fakeData() -> Void {
        let access = missionAccess()
        if access.getMissions().count > 0 { return }
        
        var gagnon = Dictionary<String, Any>()
        var painDore = Dictionary<String, Any>()
        var bellOeuvre = Dictionary<String, Any>()
        
        gagnon[MDbKeys.NAME.rawValue] = "Dr Gagnon Mathieu"
        gagnon[MDbKeys.DATE.rawValue] = "6/4/18, 1:07 AM"
        gagnon[MDbKeys.LATITUDE.rawValue] = 44.85775394333226
        gagnon[MDbKeys.LONGITUDE.rawValue] = -0.5652806455447035
        gagnon[MDbKeys.DESCRIPTION.rawValue] = "Lorem up sum dolor dit amer, cons√©crateur adipiscing √©lit. Suspendisse portion thon us l‚Äôavis dit amer place √©tat. Nullam thon us mourus egestas faucon us"
        gagnon[MDbKeys.ADDRESS.rawValue] = "Gironde, 25 Rue Sainte-Philom√®ne, 33300 Bordeaux, France"
        gagnon[MDbKeys.STATUS.rawValue] = "Done"
        gagnon[MDbKeys.PHONE.rawValue] = "0678985646"
        
        painDore[MDbKeys.NAME.rawValue] = "Boulangerie Le pain d'or"
        painDore[MDbKeys.DATE.rawValue] = "6/4/18, 1:07 AM"
        painDore[MDbKeys.LATITUDE.rawValue] = 44.84947884353505
        painDore[MDbKeys.LONGITUDE.rawValue] = -0.5751511746227607
        painDore[MDbKeys.DESCRIPTION.rawValue] = "Lorem up sum dolor dit amer, cons√©crateur adipiscing √©lit. Suspendisse portion thon us l‚Äôavis dit amer place √©tat. Nullam thon us mourus egestas faucon us"
        painDore[MDbKeys.ADDRESS.rawValue] = "Gironde, 25 Rue Sainte-Philom√®ne, 33300 Bordeaux, France"
        painDore[MDbKeys.STATUS.rawValue] = "InProgress"
        painDore[MDbKeys.PHONE.rawValue] = "0678985646"
        
        bellOeuvre[MDbKeys.NAME.rawValue] = "La Belle oeuvre"
        bellOeuvre[MDbKeys.DATE.rawValue] = "6/6/18, 3:12 AM"
        bellOeuvre[MDbKeys.LATITUDE.rawValue] = 44.8416285691662
        bellOeuvre[MDbKeys.LONGITUDE.rawValue] = -0.5780694179987904
        bellOeuvre[MDbKeys.DESCRIPTION.rawValue] = "Lorem up sum dolor dit amer, cons√©crateur adipiscing √©lit. Suspendisse portion thon us l‚Äôavis dit amer place √©tat. Nullam thon us mourus egestas faucon us"
        bellOeuvre[MDbKeys.ADDRESS.rawValue] = "Gironde, 25 Rue Sainte-Philom√®ne, 33300 Bordeaux, France"
        bellOeuvre[MDbKeys.STATUS.rawValue] = "Await"
        bellOeuvre[MDbKeys.PHONE.rawValue] = "0678985646"
        
        var m1 = missionAccess().createMission()
        var m2 = missionAccess().createMission()
        var m3 = missionAccess().createMission()
        
        m1.properties(map: gagnon)
        m2.properties(map: painDore)
        m3.properties(map: bellOeuvre)
        
        try? m1.save()
        try? m2.save()
        try? m3.save()
    }
}
