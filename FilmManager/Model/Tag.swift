//
//  Tag.swift
//  FilmManager
//
//  Created by Dylan Southard on 2019/07/04.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Foundation

enum TagType:String {
    
    case userDefault = "default"
    case user = "user"
    case queried = "queried"
    
}


struct Tag {
    
    var name:String
    var checked:Bool
    var type:TagType
    
}
