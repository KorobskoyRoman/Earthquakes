//
//  NSCache+Subscript.swift
//  Earthquakes-iOS
//
//  Created by Roman Korobskoy on 23.01.2023.
//  Copyright © 2023 Apple. All rights reserved.
//

import Foundation

extension NSCache where KeyType == NSString, ObjectType == CacheEntryObject {
    subscript(_ url: URL) -> CacheEntry? {
        get {
            let key = url.absoluteString as NSString
            let value = object(forKey: key)
            return value?.entry
        }
        set {
            let key = url.absoluteString as NSString
            if let entry = newValue {
                let value = CacheEntryObject(entry: entry)
                setObject(value, forKey: key) // Set new value
            } else {
                removeObject(forKey: key) // Delete duplicates
            }
        }
    }
}
