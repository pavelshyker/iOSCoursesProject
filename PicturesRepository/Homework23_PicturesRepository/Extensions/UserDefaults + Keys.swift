//
//  UserDefaults + Keys.swift
//  Homework23_PicturesRepository
//
//  Created by Pavel Shyker on 11/26/20.
//  Copyright © 2020 Pavel Shyker. All rights reserved.
//

import Foundation

extension UserDefaults {
    func setValue(_ value: Any?, forKey key: UserDefaultKeys) {
        setValue(value, forKey: key.rawValue)
    }
    
    func value(forKey key: UserDefaultKeys) -> Any? {
        return value(forKey: key.rawValue)
    }
}
