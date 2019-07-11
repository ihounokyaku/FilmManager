//
//  MovieFileManager.swift
//  FilmManager
//
//  Created by Dylan Southard on 2019/07/07.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Cocoa
import SwiftTMDB_MacOS
import SwiftyJSON

class MovieFileManager: NSObject {
    
    static var BackupFolderExists:Bool {
        
        if let folder = Prefs.BackupDestinationFolder {
            
            
            if !folder.hasDirectoryPath {
                
                guard FileManager.CreateFolder(withName: folder.lastPathComponent, atDestination: folder.deletingLastPathComponent()) == nil else {return false}
                
            }
            
            return true
            
        } else {
            
            Alert.PresentErrorAlert(text: "No backup directory selected")
            
        }
        
        return false
        
    }
    
    static func ConstructMovieFolder(forMovie movie:TMDBMovie, toFolder folder:URL, withTags tags:[String], updateCatalogue:Bool) {
        
        
        FileManager.AddTags(tags, toFileAtURL: folder)
        
        
        
        let image = NSImage.SafeImage(fromData: movie.imageData).resizeCanvas(size:NSSize(width:300, height:300))
        
        NSWorkspace.shared.setIcon(image, forFile: folder.path, options: NSWorkspace.IconCreationOptions.excludeQuickDrawElementsIconCreationOption)
        
        movie.title.makeLink(atPath: folder.path + "/Trailer")
        movie.title.makeLink(atPath: folder.path + "/予告編")
        
        KodiXMLManager.WriteKodiXML(fromMovie: movie, withTags: tags, toFolder: folder)
        
        
        if let metadataFolder = FileManager.CreateFolder(withName: "Metadata", atDestination: folder) {
            
            var movieJSON = JSON(movie.json)
            
            movieJSON.dictionaryObject?.removeValue(forKey:  TMDBReference.SupplimentaryMovieData.credits.rawValue)
            
            if let credits = movie.json.valueFor(.credits).rawString() {
                
                FileManager.WriteTextToFile(text: credits, toFolder: metadataFolder, fileName: "credits.json")
                
            }
            
            if let movieData = movieJSON.rawString() {
                
                FileManager.WriteTextToFile(text: movieData, toFolder: metadataFolder, fileName: "movieData.json")
                
            }
            
            if updateCatalogue { LibraryCatalogManager.UpdateCatalogueFile(withMovieData: movieJSON, andTags: tags) }
            
            if tags.contains("3D") {
                
                let _ = FileManager.CreateFolder(withName: "Extras", atDestination: folder)
                
                FileManager.CopyTextToClipboard(folder.lastPathComponent + "-3D")
                
            }
            
        }
        
    }
    
    static func GetSubFiles(inFolder folderURL:URL, _ recursive:Bool = true) -> [URL] {
        
        var urls = [URL]()
        
        let allUrls = FileManager.Contents(ofFolder: folderURL)
        
        for url in allUrls {
            
            if Prefs.SubtitleExtensions.contains(url.pathExtension) {
                
                urls.append(url)
                
            } else if url.hasDirectoryPath && recursive == true {
                
                urls += MovieFileManager.GetSubFiles(inFolder: url, false)
                
            }
        }
        
        return urls
        
    }
    
    static func CopySubtitles(fromFolder sourceFolder:URL, toFolder destinationFolder:URL) {
        
        let subtitleURLs = MovieFileManager.GetSubFiles(inFolder: sourceFolder)
        
        if let subFolder = FileManager.CreateFolder(withName: "Subs", atDestination: destinationFolder) {
            
            for subtitleURL in subtitleURLs {
                
                FileManager.CopyFile(atURL: subtitleURL, toFolder: subFolder, operation: nil)
                
            }
            
        }
        
    }
    
    

}
