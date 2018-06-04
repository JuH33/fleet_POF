//
//  Constants.swift
//  Mapotempo-Fleet
//
//  Created by julien boyer on 27/04/2018.
//  Copyright © 2018 julien boyer. All rights reserved.
//

import Foundation
import Mapbox

struct Constants {
    
    ////////////////////////////////////////////////////////////////////////////////
    /// MAP CONFIGURATION (MAPBOX)
    ////////////////////////////////////////////////////////////////////////////////
    public struct MapConf {
        public static let style: URL = MGLStyle.lightStyleURL
    }
    
    public enum MissionDetail {
        public static let LIST_UNWIND = "unwindToList"
        public static let LOCATION_UNWIND = "editLocation"
    }
}
