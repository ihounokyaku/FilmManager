//
//  File.swift
//  FilmManager
//
//  Created by Dylan Southard on 2019/07/06.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Foundation
import Cocoa
import SwiftTMDB_MacOS

class KodiXMLManager:NSObject {
    
    static func WriteKodiXML(fromMovie movie:TMDBMovie, withTags tags:[String], toFolder folderURL:URL) {
        
        var playCount = "1"
        
        if tags.contains("to watch") {
            playCount = "0"
        }
        
        var xmlString = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?>\n<movie>\n<title>" + movie.title + "</title>\n<playcount>" + playCount + "</playcount>\n"
        
        for tag in tags {
            
            if tag !=  "movie" {
                
                xmlString += "<tag>" + tag + "</tag>\n"
                
            }
            
        }
        
        xmlString += "</movie>\nhttps://www.themoviedb.org/movie/" + "\(movie.id)"
        
        FileManager.WriteTextToFile(text: xmlString, toFolder: folderURL, fileName: "combination.nfo")
        
    }
    
}
