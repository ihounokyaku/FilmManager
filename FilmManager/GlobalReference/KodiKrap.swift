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
        
        xmlString += KodiXMLManager.TagText(tags: tags)
        
        xmlString += "</movie>\nhttps://www.themoviedb.org/movie/" + "\(movie.id)"
        
        FileManager.WriteTextToFile(text: xmlString, toFolder: folderURL, fileName: MovieFileManager.FileName.kodi.rawValue)
        
    }
    
    static func AddTag(_ tag:String, toMovieAtURL folderURL:URL) {
        
        let nfoUrl = folderURL.appendingPathComponent(MovieFileManager.FileName.kodi.rawValue)
        
        do {
            
            let text = try String(contentsOf: nfoUrl)
            
            let tagText = "<tag>" + tag + "</tag>"
            
            if !text.contains(tagText) {
                
                let modifiedText = text.replacingOccurrences(of: "</movie>", with: tagText + "\n</movie>")
                
                try FileManager.default.removeItem(at: nfoUrl)
                
                try modifiedText.write(to: nfoUrl, atomically: true, encoding: .utf8)
                
            }
            
        } catch {
            
            Alert.PresentErrorAlert(text: "Could not update kodi file \n" + error.localizedDescription)
            
        }
    }

    
    static func ReplaceTags(with tags:[String], toMovieAtURL folderURL:URL) {
        
        let nfoUrl = folderURL.appendingPathComponent(MovieFileManager.FileName.kodi.rawValue)
        
        
        do {
            
            let text = try String(contentsOf: nfoUrl)
            
            let firstHalf = text.components(separatedBy: "</playcount>\n")[0] + "</playcount>\n"
            
            let secondHalf = text.components(separatedBy: "</movie>")[0] + "</movie>"
            
            let xmlText = firstHalf + KodiXMLManager.TagText(tags: tags) + secondHalf
            
            try FileManager.default.removeItem(at: nfoUrl)
                
            try xmlText.write(to: nfoUrl, atomically: true, encoding: .utf8)
            
            
        } catch {
            
            Alert.PresentErrorAlert(text: "Could not update kodi file \n" + error.localizedDescription)
            
        }
        
    }
    
    
    static func TagText(tags:[String]) -> String {
        var xmlString = ""
        
        for tag in tags {
            
            if tag !=  "movie" {
                
                xmlString += "<tag>" + tag + "</tag>\n"
                
            }
            
        }
        
        return xmlString
        
    }
    
}
