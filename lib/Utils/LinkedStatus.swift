//
//  LinkedStatus.swift
//  Mapotempo-Fleet
//
//  Created by julien boyer on 03/06/2018.
//  Copyright © 2018 julien boyer. All rights reserved.
//

import Foundation

public class LinkedStatus {
    
    // MARK: Properties
    weak var prev: LinkedStatus?
    var next: LinkedStatus?
    let current: Status
    
    // MARK: Constructor
    init(prev: LinkedStatus?, next: LinkedStatus?, status: Status) {
        self.prev = prev
        self.next = next
        self.current = status
    }
}
