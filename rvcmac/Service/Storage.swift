//
//  Storage.swift
//  rvcmac
//
//  Created by Nikita Titov on 23/09/2017.
//  Copyright © 2017 Ribose. All rights reserved.
//

import Foundation

// Storage is a simple dict wrapper
// It behaves like a set
// For each mutable operation it posts a notificaion
// so that observers could update UI

extension NSNotification.Name {
    public static let RvcConnectionInserted = NSNotification.Name(rawValue: "RvcConnectionInserted")
    public static let RvcConnectionDeleted = NSNotification.Name(rawValue: "RvcConnectionDeleted")
}

class Storage {
    private var _connections = [String: RvcStatus]()
    
    var connections: [String: RvcStatus] {
        get {
            return _connections
        }
    }
    
    func put(_ connection: RvcStatus) {
        if !contains(connection.name) {
            insert(connection)
        } else {
            update(connection)
        }
    }
    
    func delete(_ key: String) {
        if let connection = _connections.removeValue(forKey: key) {
            NotificationCenter.default.post(name: .RvcConnectionDeleted, object: connection)
        }
    }
    
    func delete(ifMissingIn keys: Set<String>) {
        if connections.isEmpty {
            return
        }
        Set(connections.keys).symmetricDifference(keys).forEach(delete(_:))
    }
    
    private func insert(_ connection: RvcStatus) {
        let key = connection.name
        _connections[key] = connection
        NotificationCenter.default.post(name: .RvcConnectionInserted, object: connection)
    }
    
    private func update(_ newConnection: RvcStatus) {
        let connection = connections[newConnection.name]!
        
        if connection.status != newConnection.status {
            connection.status = newConnection.status
        }
        if connection.ovpnStatus != newConnection.ovpnStatus {
            connection.ovpnStatus = newConnection.ovpnStatus
        }
        if connection.inTotal != newConnection.inTotal {
            connection.inTotal = newConnection.inTotal
        }
        if connection.outTotal != newConnection.outTotal {
            connection.outTotal = newConnection.outTotal
        }
        if connection.timestamp != newConnection.timestamp {
            connection.timestamp = newConnection.timestamp
        }
    }
    
    private func contains(_ key: String) -> Bool {
        return _connections.keys.contains(key)
    }
}
