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
    
    enum SubFolderName:String, CaseIterable {
        
        case subs = "Subs"
        case extras = "Extras"
        case metadata = "Metadata"
    }
    
    enum FileName:String, CaseIterable {
        
        case kodi = "combination.nfo"
        case movieData = "movieData.json"
        
    }
    
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
        
        
        FileManager.SetTags(ofFileAtURL: folder, to: tags)
        
        
        
        let image = NSImage.SafeImage(fromData: movie.imageData).resizeCanvas(size:NSSize(width:300, height:300))
        
        
        
        NSWorkspace.shared.setIcon(image, forFile: folder.path, options: NSWorkspace.IconCreationOptions.excludeQuickDrawElementsIconCreationOption)
        
        
        
        
        movie.title.makeLink(atPath: folder.path + "/Trailer")
        movie.title.makeLink(atPath: folder.path + "/予告編")
        
        KodiXMLManager.WriteKodiXML(fromMovie: movie, withTags: tags, toFolder: folder)
        
        
        if let metadataFolder = FileManager.CreateFolder(withName: MovieFileManager.SubFolderName.metadata.rawValue, atDestination: folder) {
            
            var movieJSON = JSON(movie.json)
            
            movieJSON.dictionaryObject?.removeValue(forKey:  TMDBReference.SupplimentaryMovieData.credits.rawValue)
            
            if let credits = movie.json.valueFor(.credits).rawString() {
                
                FileManager.WriteTextToFile(text: credits, toFolder: metadataFolder, fileName: "credits.json")
                
            }
            
            if let movieData = movieJSON.rawString() {
                
                FileManager.WriteTextToFile(text: movieData, toFolder: metadataFolder, fileName: MovieFileManager.FileName.movieData.rawValue)
                
            }
            
            
            
            if updateCatalogue { LibraryCatalogManager.UpdateCatalogueFile(withMovieData: movieJSON, andTags: tags) }
            
            if tags.contains("3D") {
                
                let _ = FileManager.CreateFolder(withName: MovieFileManager.SubFolderName.extras.rawValue, atDestination: folder)
                
                FileManager.CopyTextToClipboard(folder.lastPathComponent + "-3D")
                
            }
            
        }
        
    }
    
    static func AddTags(_ tags:[String], toFolder folderURL:URL) {
        
        FileManager.AddTags(tags, toFileAtURL: folderURL)
        
        for tag in tags { KodiXMLManager.AddTag(tag, toMovieAtURL: folderURL) }
        
        if let backupURL = MovieFileManager.CreateBackupFolder(forFolder: folderURL) {
            
            FileManager.AddTags(tags, toFileAtURL: backupURL)
            
            for tag in tags { KodiXMLManager.AddTag(tag, toMovieAtURL: backupURL) }
            
        }
        
         MovieFileManager.UpdateLibraryCatalogue(forMovieFolder: folderURL)
    }
    
    static func ReplaceTags(ofMovieAtURL folderURL:URL, with tags:[String]) {
        
        FileManager.SetTags(ofFileAtURL: folderURL, to: tags)
        
        if let backupURL = MovieFileManager.CreateBackupFolder(forFolder: folderURL) {
            
            FileManager.SetTags(ofFileAtURL: backupURL, to: tags)
            
        }
        
        MovieFileManager.UpdateLibraryCatalogue(forMovieFolder: folderURL)
    }
    
    
    static func CreateBackupFolder(forFolder folderURL:URL)->URL? {
        
        if Prefs.CreateBackup, MovieFileManager.BackupFolderExists {
            
            return FileManager.CreateFolder(withName: folderURL.lastPathComponent, atDestination: Prefs.BackupDestinationFolder!)
            
        }
        
        return nil
        
    }
    
    static func UpdateLibraryCatalogue(forMovieFolder folderURL:URL) {
        
        if Prefs.CreateLibrary, let jsonData = MovieFileManager.movieDataJSON(forMovieInFolder: folderURL) {
            
            LibraryCatalogManager.UpdateCatalogueFile(withMovieData: jsonData, andTags: folderURL.tags)
            
        }
        
    }
    
    
    static func movieDataJSON(forMovieInFolder folderURL:URL)->JSON? {
        
       
        do {
            
            let data = try Data(contentsOf: folderURL.appendingPathComponent(MovieFileManager.SubFolderName.metadata.rawValue).appendingPathComponent(MovieFileManager.FileName.movieData.rawValue))
            
            return try JSON(data: data)
            
        } catch {
            
            Alert.PresentErrorAlert(text: "Could not find movie data folder\n" + error.localizedDescription)
            return nil
            
        }
        
    }
    
    static func BackupFolderURL(forMovie folderName:String)->URL? {
        
        guard Prefs.CreateBackup, let backupFolder = Prefs.BackupDestinationFolder else { return nil }
        
        let destinationFolder = backupFolder.appendingPathComponent(folderName)
        
        guard destinationFolder.hasDirectoryPath else {
            
            Alert.PresentErrorAlert(text: "Could not find backup folder for \(folderName)")
            
            return nil
        }
        
        return destinationFolder
        
    }
    
    static func AddLanguages(_ languages:[String], toMovieFolder folderURL:URL) {
        
        let realLanguages = languages.filter { TMDBReference.Language(rawValue: $0) != nil }
        
        var languageNames = realLanguages.map { LanguageDic[$0]! }
        
        languageNames = languageNames.filter { Prefs.LanguagesToTag.contains($0) }
        
        if languageNames.count > 0 { MovieFileManager.AddTags(languageNames, toFolder: folderURL) }
        
    }
}
