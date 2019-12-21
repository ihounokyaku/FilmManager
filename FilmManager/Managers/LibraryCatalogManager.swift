//
//  LibraryCatalogManager.swift
//  FilmManager
//
//  Created by Dylan Southard on 2019/07/11.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Cocoa
import SwiftyJSON
import SwiftTMDB_MacOS

class LibraryCatalogManager: NSObject {
    
    static var CatalogFileURL:URL? {
        
        guard Prefs.CreateLibrary, let folderURL = Prefs.LibraryDestinationFolder, folderURL.hasDirectoryPath else {return nil}
        
        return folderURL.appendingPathComponent("FilmLibrary.json")
        
    }
    
    
    
    static var CatalogueFile:JSON? {
        
        get {
            
            if let catalogueURL = LibraryCatalogManager.CatalogFileURL, catalogueURL.isFileURL {
                
                if !catalogueURL.fileExists {
                    
                    let json:JSON = [:]
                    FileManager.WriteTextToFile(text: json.rawString()!, toFolder: Prefs.LibraryDestinationFolder!, fileName: catalogueURL.lastPathComponent)
                    
                }
                
                return FileManager.ReadJSON(atURL: catalogueURL)
                
            } else {
                
                
            }
        
            return nil

        }
        
        set {
            guard let nv = newValue?.rawString(), let fileURL = CatalogFileURL, fileURL.isFileURL else {
                
                Alert.PresentErrorAlert(text: "Error updating library catalogue file")
                
                return
                
            }
            
            FileManager.WriteTextToFile(text: nv, toFolder: fileURL.deletingLastPathComponent(), fileName: fileURL.lastPathComponent)
            
        }
        
    }
    
    static func UpdateCatalogueFile(withMovieData movieData:JSON, andTags tags:[String]) {
        
        
        guard let id = movieData.valueFor(TMDBReference.MovieField.id).int, let catalogueJSON = LibraryCatalogManager.CatalogueFile else {
            
            Alert.PresentErrorAlert(text: "Could not write JSON Data \n id = \(movieData.valueFor(TMDBReference.MovieField.id).int) catalogueFile = \(LibraryCatalogManager.CatalogueFile)")
            
            return
            
        }
        
        let newJSON:JSON = ["\(id)":["tags":tags, "movieData":movieData]]
        
        var tempJSON = catalogueJSON
        
        if !(tempJSON["\(id)"].rawString() == newJSON.rawString()!) { tempJSON["\(id)"] = newJSON["\(id)"] }
        
        LibraryCatalogManager.CatalogueFile = tempJSON
        
    }

}
