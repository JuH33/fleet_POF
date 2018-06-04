//
//  Mission.swift
//  Mapotempo-Fleet
//
//  Created by julien boyer on 28/04/2018.
//  Copyright © 2018 julien boyer. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift

struct MissionCouchbase: BaseModel, IMission {

    public struct Location {
        let lat: Double
        let lng: Double
    }
    
    public var mStatus: LinkedStatus?
    
    // MARK: From BaseModel Protocol
    internal var database: Database
    internal var model: Dictionary<String, Any> = Dictionary<String, Any>() {
        didSet {
            if model["status"] as? String != mStatus?.current.rawValue {
                updateStatus()
            }
        }
    }
    
    var beforeSave: ((Document) -> Void)?
    var beforeDelete: ((Document) -> Void)?
    var afterUpdate: ((Document) -> Void)?
    var onModelInit: ((_ model: Dictionary<String, Any>) -> Void)?
    
    public static let type: String = "MISSION"
    
    // MARK: Used as Description for validations
    private var id: String
    private var name: String?
    private var description: String?
    private var address: String?
    private var status: String?
    private var phoneNumber: String?
    private var latitude: Double?
    private var longitude: Double?
    private var date: String?
    
    public func hasValidCoords() -> Bool {
        if let lat = model[MDbKeys.LATITUDE.rawValue] as? Double,
           let lng = model[MDbKeys.LONGITUDE.rawValue] as? Double {
            return (lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180)
        }
        
        return false
    }
    
    //MARK: Polymorphics Initializers
    
    init(_ database: Database) {
        // Initialize the Linked list
        let head = LinkedStatus(prev: nil, next: nil, status: Status.AWAIT)
        let prim = LinkedStatus(prev: head, next: nil, status: Status.PROGRESS)
        let last = LinkedStatus(prev: prim, next: head, status: Status.DONE)
        
        head.next = prim
        head.prev = last
        prim.next = last
        
        // Keep the head
        self.mStatus = head
        
        self.id = ""
        self.database = database
        
        model["type"] = getType()
        model[MDbKeys.STATUS.rawValue] = Status.AWAIT.rawValue
    }
    
    init(_ database: Database, id: String) throws {
        self.database = database
        self.id = id
        let document = database.document(withID: id)
        if document == nil {
            throw DbError.MissionNotFound
        }
    }
    
    // MARK: GETTERS
    func getName() -> String? {
        return model[MDbKeys.NAME.rawValue] as? String
    }
    
    func getLocation() -> MissionCouchbase.Location? {
        let lat = model[MDbKeys.LATITUDE.rawValue] as? Double
        let lng = model[MDbKeys.LONGITUDE.rawValue] as? Double
        return Location(lat: lat ?? 0, lng: lng ?? 0)
    }
    
    func getDate() -> String? {
        return model[MDbKeys.DATE.rawValue] as? String
    }
    
    func getDescription() -> String? {
        return model[MDbKeys.DESCRIPTION.rawValue] as? String
    }
    
    func getAddress() -> String? {
        return model[MDbKeys.ADDRESS.rawValue] as? String
    }
    
    func getStatus() -> String? {
        return model[MDbKeys.STATUS.rawValue] as? String
    }
    
    func getPhoneNumber() -> String? {
        return model[MDbKeys.PHONE.rawValue] as? String
    }
    
    func getType() -> String {
        return MissionCouchbase.type
    }
    
    mutating func nextStatus() -> Status {
        mStatus = mStatus!.next
        model[MDbKeys.STATUS.rawValue] = mStatus!.current.rawValue
        
        return mStatus!.current
    }
    
    mutating func property(forKey: String, value: MissionCouchbase.Location?) {
        if value == nil { return }

        model[MDbKeys.LATITUDE.rawValue] = value?.lat
        model[MDbKeys.LONGITUDE.rawValue] = value?.lng
        
        if !self.hasValidCoords() {
            model[MDbKeys.LATITUDE.rawValue] = nil
            model[MDbKeys.LONGITUDE.rawValue] = nil
            return
        }
    }
    
    mutating func updateStatus() {
        let status = model["status"] as! String
        for _ in 0..<Status.count() {
            let cStatus = nextStatus()
            if status == cStatus.rawValue {
                break
            }
        }
    }
}

protocol IMission {
    
    // MARK: GETTERS
    func getName() -> String?
    func getLocation() -> MissionCouchbase.Location?
    func getDescription() -> String?
    func getAddress() -> String?
    func getStatus() -> String?
    func getPhoneNumber() -> String?
    func getType() -> String
    func getDate() -> String?
    
    mutating func nextStatus() -> Status
    
    // From base model extension
    mutating func save() throws
    func delete() throws -> Void
    func update() -> Void
    
    // MARK: Callbacks
    var beforeSave: ((Document) -> Void)? { get set }
    var beforeDelete: ((Document) -> Void)? { get set }
    var afterUpdate: ((Document) -> Void)? { get set }
    
    // MARK: SETTERS
    mutating func property(forKey: String, value: Int?)
    mutating func property(forKey: String, value: String?)
    mutating func property(forKey: String, value: Bool?)
    mutating func property(forKey: String, value: Date?)
    mutating func property(forKey: String, value: MissionCouchbase.Location?)
    mutating func properties(map: Dictionary<String, Any>)
    
    // Mark: Validators
    func hasValidCoords() -> Bool
    
}
