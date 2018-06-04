//
//  Constants.swift
//  Mapotempo-Fleet
//
//  Created by julien boyer on 18/05/2018.
//  Copyright © 2018 julien boyer. All rights reserved.
//

import Foundation

// MARK: Static Keys identifiers
public enum MDbKeys: String {
    case ID = "id",
    NAME = "name",
    DATE = "date",
    LOCATION = "location",
    LATITUDE = "latitude",
    LONGITUDE = "longitude",
    DESCRIPTION = "description",
    ADDRESS = "address",
    STATUS = "status",
    PHONE = "phoneNumber"
    
    public static func getAll() -> [String] {
        return [
            MDbKeys.NAME.rawValue,
            MDbKeys.DATE.rawValue,
            MDbKeys.LATITUDE.rawValue,
            MDbKeys.LONGITUDE.rawValue,
            MDbKeys.DESCRIPTION.rawValue,
            MDbKeys.ADDRESS.rawValue,
            MDbKeys.STATUS.rawValue,
            MDbKeys.PHONE.rawValue
        ]
    }
}

public enum Status: String {
    case DONE = "Done",
    PROGRESS = "InProgress",
    AWAIT = "Await"
    
    public static func count() -> Int {
        return 3
    }
    
}

public enum DbError: Error {
    case MissionNotFound
}

public enum Logins: String {
    case name = "admin",
    password = "adminPassword",
    dbName = "fleetbaseDb"
    
}
