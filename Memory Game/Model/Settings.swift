//
//  Settings.swift
//  Memory Game
//
//  Created by Michail Grebionkin on 14.03.17.
//  Copyright © 2017 mihato. All rights reserved.
//

import Foundation

enum SettingKey: String {
    case authKey500px = "500px Auth Key"
    case persistentContainerName = "Persistent Container Name"
}

class Settings <ValueType> {
    
    fileprivate var key: SettingKey
    
    var value: ValueType?
    
    init?(key: SettingKey) {
        guard let url = Bundle.main.url(forResource: "Settings", withExtension: "plist"),
            let settings = NSDictionary(contentsOf: url) as? [String: AnyObject] else {
                return nil
        }
        self.key = key
        self.value = settings[key.rawValue] as? ValueType
    }
    
    init(key: SettingKey, value: ValueType?) {
        self.key = key
        self.value = value
    }
}
