//
//  ExpressibleByJSONDictionary.swift
//  Technical task iOS
//
//  Created by Ruslan Pitula on 5/15/19.
//  Copyright © 2019 Ruslan Pitula. All rights reserved.
//

import Foundation

protocol  ExpressibleByJSONDictionary: Codable  {
    var dictionary: [String: Any] {get}
    static func create(fromDictionary dictionary:[String: Any]) -> Self?
}

extension ExpressibleByJSONDictionary {
    
    var dictionary: [String: Any] {
        if let data = try? JSONEncoder().encode(self),
            let dict =  (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] {
            return dict
        }
        return [:]
    }
    
    static func create(fromDictionary dictionary:[String: Any]) -> Self? {
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary) else { return nil }
        return try? JSONDecoder().decode(Self.self, from: data)
    }
    
}
