//
//  LGPoolService.swift
//  
//
//  Created by Murilo Araujo on 02/10/20.
//

import Foundation
import Disk
import WebKit

internal class LGPoolService {
    static let shared = LGPoolService()
    
    
    private func encondeToData(poolToEncode: WKProcessPool) -> Data? {
        return try? NSKeyedArchiver.archivedData(withRootObject: poolToEncode, requiringSecureCoding: true)
    }
    
    private func decodeFromData(data: Data) -> WKProcessPool? {
        return try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? WKProcessPool
    }
    
    private func poolPath(id: String) -> String {
        return "Pools/\(id)"
    }
    
    internal func getPool(for id: String) -> WKProcessPool {
        
        if let poolData = try? Disk.retrieve(poolPath(id: id), from: .applicationSupport, as: Data.self), let decodedPool = decodeFromData(data: poolData) {
            return decodedPool
        }
        
        return WKProcessPool()
    }
    
    internal func save(pool: WKProcessPool,for id: String) {
        if let poolData = encondeToData(poolToEncode: pool) {
            try? Disk.save(poolData, to: .applicationSupport, as: poolPath(id: id))
        }
    }
    
    internal func clearPoolData(for id: String) {
        try? Disk.remove(poolPath(id: id), from: .applicationSupport)
    }
}
