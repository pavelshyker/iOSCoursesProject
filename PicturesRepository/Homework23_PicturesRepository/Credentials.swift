//
//  Credential.swift
//  Homework23_PicturesRepository
//
//  Created by Pavel Shyker on 11/26/20.
//  Copyright © 2020 Pavel Shyker. All rights reserved.
//

import Foundation

class Credential: Codable {
    var userName: String
    var password: String
    
    init (_ name: String, _ password: String) {
        self.userName = name
        self.password = password
    }
}
