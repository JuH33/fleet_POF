//
//  BaseModel.swift
//  Mapotempo-Fleet
//
//  Created by julien boyer on 28/04/2018.
//  Copyright © 2018 julien boyer. All rights reserved.
//

import Foundation
import CouchbaseLiteSwift

protocol BaseModel {
    
    // MARK: Properties
    var database: Database { get set }
    var model: Dictionary<String, Any> { get set }
    
    // MARK: Callbacks
    var beforeSave: ((_ entity: Document) -> Void)? { get set }
    var beforeDelete: ((_ entity: Document) -> Void)? { get set }
    var afterUpdate: ((_ entity: Document) -> Void)? { get set }
    var onModelInit: ((_ model: Dictionary<String, Any>) -> Void)? { get set }
    
}

extension BaseModel {
    
    // MARK: Setters polymorphs
    mutating func property(forKey: String, value: Int?) {
        if isValidProperty(forKey: forKey, Int?.self) {
            model[forKey] = value
        }
    }
    
    mutating func property(forKey: String, value: String?) {
        if isValidProperty(forKey: forKey, String?.self) {
            model[forKey] = value
        }
    }
    
    mutating func property(forKey: String, value: Bool?) {
        if isValidProperty(forKey: forKey, Bool?.self) {
            model[forKey] = value
        }
    }
    
    mutating func property(forKey: String, value: Date?) {
        if isValidProperty(forKey: forKey, Date?.self) {
            model[forKey] = value
        }
    }
    
    func isValidProperty<T>(forKey: String, _ type: T.Type) -> Bool {
        let mirror: Mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if child.label != nil && child.label! == forKey {
                return child.value is T
            }
        }
        return false
    }
    
    mutating func properties(map: Dictionary<String, Any>) {
        let properties = Mirror(reflecting: self).children.map { $0.label }
        for el in map {
            if properties.contains(el.key) {
                model[el.key] = el.value
            }
        }
        onModelInit?(model)
    }
    
    mutating func save() throws {
        let document = MutableDocument(data: model)
        self.model["id"] = document.id
        
        self.beforeSave?(document)
        try database.saveDocument(document)
    }
    
    func delete() throws -> Void {
        guard let id = model["id"] as? String, let entity = database.document(withID: id) else {
            fatalError("Mission not found")
        }
        
        self.beforeDelete?(entity)
        try database.deleteDocument(entity)
    }
    
    func update() -> Void {
        if let mutableDoc = database.document(withID: model["id"] as! String)?.toMutable() {
            mutableDoc.setData(model)
            do {
                try database.saveDocument(mutableDoc)
                let document = database.document(withID: mutableDoc.id)!
                self.afterUpdate?(document)
                
                print("Document ID :: \(document.id)")
                print("name: \(document.string(forKey: "name")!)")
            } catch {
                fatalError("Error updating document")
            }
        }
    }
    
}
