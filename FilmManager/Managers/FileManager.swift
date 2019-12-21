//
//  FileManager.swift
//  FilmManager
//
//  Created by Dylan Southard on 2019/07/05.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Foundation
import Cocoa
import SwiftyJSON



extension FileManager {
    
    static var ExternalDestinationAvailable: Bool {
        
        guard let url = Prefs.ExternalDestinationFolder, url.hasDirectoryPath else {return false}
        
        return true
    }
    
    
    static func CreateUniqueFolder(withName name:String, atDestination destination:URL, alternateNameSuggestion:String? = nil)->URL? {
        
        let folderURL = destination.appendingPathComponent(name)
        
        if folderURL.hasDirectoryPath {
            
            guard let newName = Alert.GetUserInput(message: "A file named \(name) already exists! Please enter a new name", placeholderText: "\(alternateNameSuggestion ?? name)") else { return nil}
            print("new name =\(newName) ")
            
            return FileManager.CreateUniqueFolder(withName: newName, atDestination: destination)
            
        } else {
            
            return FileManager.CreateFolder(withName: name, atDestination: destination)
            
        }

    }
    
    

    static func CreateFolder(withName name:String, atDestination destination:URL)->URL? {
        let folder = destination.appendingPathComponent(name)
       
        if folder.hasDirectoryPath {
            return folder
        }
        
        do {
            
            
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: false, attributes: nil)
            
            return folder

        } catch {
            
            Alert.PresentErrorAlert(text: error.localizedDescription)
            return nil
            
        }
    }
    
   
    
    static func WriteTextToFile(text:String, toFolder folder:URL, fileName:String) {
        
        do {
            
            try text.write(to: folder.appendingPathComponent(fileName), atomically: false, encoding: .utf8)
            
        } catch let error {
            
            Alert.PresentErrorAlert(text: "Error saving file: \(fileName)!" + error.localizedDescription)
            
        }
        
    }
    
    static func AddTags(_ tags:[String], toFileAtURL folder:URL) {
        
        var folderTags = folder.tags
        for tag in tags {
            
            if !(folderTags.map {$0.lowercased()}).contains(tag.lowercased()) {
                
                folderTags.append(tag)
                
            }
            
        }
        
        self.SetTags(ofFileAtURL: folder, to: folderTags)
        
    }
    
    static func SetTags(ofFileAtURL folder:URL, to tags:[String]) {
        
        do {
            
            try (folder as NSURL).setResourceValue(tags, forKey: .tagNamesKey)
            
        } catch let error as NSError {
            
            Alert.PresentErrorAlert(text: "Error adding tags!\n" + error.localizedDescription)
            return
            
        }
        
    }

    
    static func Contents(ofFolder folderUrl:URL) -> [URL] {
        var urls = [URL]()
        do {
            
            let contents = try FileManager.default.contentsOfDirectory(atPath: folderUrl.path)
            urls = contents.map { return folderUrl.appendingPathComponent($0) }
            
        } catch let error as NSError {
            
            Alert.PresentErrorAlert(text: "Error getting folder contents\n" + error.localizedDescription)
            
        }
        
        return urls
    }
    
    
    static func CopyFile(atURL fileURL:URL, toFolder folderURL:URL, overwrite:Bool = false, newFileName:String? = nil, operation:CopyOperation?) {
        
        let fileName = newFileName ?? fileURL.lastPathComponent
        
         DispatchQueue.global(qos: .utility).async {
            
            do {
                let destination = folderURL.appendingPathComponent(fileName)
                
                if overwrite { try? FileManager.default.removeItem(at: destination) }
                
                try FileManager.default.copyItem(at: fileURL, to: destination)
                
            } catch let error as NSError{
                
                DispatchQueue.main.async {
                    
                    operation?.cancel()
                    
                    Alert.PresentErrorAlert(text: "Error copying file!\n" + error.localizedDescription)
                    
                }
            }
            
        }
        
    }
    
    static func ChangeName(ofItemAtURL sourceURL:URL, to newName:String)-> URL? {
        
        let pathExtension = sourceURL.pathExtension
        
        let newURL = sourceURL.deletingLastPathComponent().appendingPathComponent(newName).appendingPathExtension(pathExtension)
        
        do {
            
            try FileManager.default.moveItem(at: sourceURL, to: newURL)
            return newURL
            
        } catch {
            Alert.PresentErrorAlert(text: "Error renaming file!\n" + error.localizedDescription)
            return nil
            
        }
        
    }
    
    static func CopyTextToClipboard(_ text:String) {
        
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        pasteboard.setString(text, forType: NSPasteboard.PasteboardType.string)
        
    }
    
    static func ReadJSON(atURL url: URL ) -> JSON? {
        
        guard let data = try? Data(contentsOf: url), let json = try? JSON(data:data) else {return nil}
        
        return json
        
    }
    
    static func StringFromFile(atURL url:URL)-> String? {
        
        do {
            
            return try String(contentsOf: url)
            
        } catch let error {
            
            Alert.PresentErrorAlert(text: "Could not get contents of idx file\n" + error.localizedDescription)
            
        }
        return nil
    }
    
    static func OpenString(atURL srtURL:URL, withEncoding encoding:String.Encoding)-> String? {
        
        do {
            
            let text = try String(contentsOf: srtURL, encoding: encoding)
            
            return text
            
        } catch {
            
            return nil
        }
        
    }
    
    
    
}


