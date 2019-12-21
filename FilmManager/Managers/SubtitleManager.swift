//
//  SubtitleManager.swift
//  FilmManager
//
//  Created by Dylan Southard on 2019/07/12.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Cocoa
import SwiftTMDB_MacOS


protocol SubtitleDelegate { func didUpdateSubtitles() }

extension SubtitleDelegate { func didUpdateSubtitles(){} }

class SubtitleManager: NSObject {
    
    enum CompanionFileType:String, CaseIterable {
        
        case idx = "idx"
        case sub = "sub"
        case xml = "xml"
        
    }

    
    static func SubtitleName(forSubtitleAtURL sourceURL:URL, withTitle movieTitle:String, languages:[String], destinationFolder:URL)-> String {
        
        var fileName = movieTitle
        
        if languages.count == 1 {fileName += ("." + languages[0])}
        
        while destinationFolder.appendingPathComponent(fileName).appendingPathExtension(sourceURL.pathExtension).fileExists {
            
            fileName = fileName.steppedUp()
        
        }
        
        return fileName
        
    }
    
    
    
    static func CopySubtitles(fromURL sourceURL:URL, toFolder destinationFolder:URL, movieTitle:String, extras:Bool = false, delegate:SubtitleDelegate? = nil) {
       
        if sourceURL.hasDirectoryPath {
            
            let subtitles = SubtitleManager.GetSubFiles(inFolder: sourceURL)
            
            for sub in subtitles {
                
                SubtitleManager.CopySubtitles(fromURL: sub, toFolder: destinationFolder, movieTitle: movieTitle, extras:extras, delegate:delegate)
                }
            return
        }
        
        let finalDestinationURL = extras ? destinationFolder.appendingPathComponent(MovieFileManager.SubFolderName.extras.rawValue) : destinationFolder
        
        
        
        
        var filesToCopy:[URL] = [sourceURL]
        
        if let companionFiles = SubtitleManager.CompanionFiles(forSubAtURL: sourceURL) {
            
            if (companionFiles.map {$0.pathExtension}).contains("idx") { return }
            
            if sourceURL.pathExtension == "idx" { filesToCopy += companionFiles}
        }
    
        
        if let subFolder = FileManager.CreateFolder(withName: MovieFileManager.SubFolderName.subs.rawValue, atDestination: finalDestinationURL) {
            
            let languages = SubtitleManager.LanguagesOfSubfile(atURL: sourceURL)
            
            let fileName = SubtitleManager.SubtitleName(forSubtitleAtURL: sourceURL, withTitle: (extras ? movieTitle + "-3D" : movieTitle), languages: languages, destinationFolder: subFolder)
            
            if !extras && languages.count > 0 {
                
                MovieFileManager.AddLanguages(languages, toMovieFolder: destinationFolder )
                
                delegate?.didUpdateSubtitles()
            }
            
            
            for url in filesToCopy {
                
                self.ExecuteCopy(from: url, toFolder: subFolder, name: fileName, movieTitle:destinationFolder.lastPathComponent, extras: extras)
                
            }
            
        }
        
    }
    
    static func ExecuteCopy(from sourceURL:URL, toFolder subFolder:URL, name:String, movieTitle:String, extras:Bool) {
        
        let fileName = name + ("." + sourceURL.pathExtension)
        
        FileManager.CopyFile(atURL: sourceURL, toFolder: subFolder, newFileName:fileName, operation: nil)
        
        if let backupDestination = SubtitleManager.SubtitleBackupURL(forMovie: movieTitle, extras:extras) {
            
            FileManager.CopyFile(atURL: sourceURL, toFolder: backupDestination, overwrite: true, newFileName:fileName, operation: nil)
            
        }
        
    }
    
    static func CompanionFiles(forSubAtURL url:URL)-> [URL]? {
        
        guard let subType = CompanionFileType(rawValue: url.pathExtension) else { return nil }
        
        var files = [URL]()
        
        for type in CompanionFileType.allCases where type != subType {
            
            if url.deletingPathExtension().appendingPathExtension(type.rawValue).fileExists {
                
                files.append(url.deletingPathExtension().appendingPathExtension(type.rawValue))
                
            }
        }
        
        return files
    }
    
    
    
    
    static func SubtitleBackupURL(forMovie folderName:String, extras:Bool)->URL? {
        
        guard var backupFolder = MovieFileManager.BackupFolderURL(forMovie: folderName) else {return nil}
        
        if extras {
            
            guard let extrasFolder = FileManager.CreateFolder(withName: MovieFileManager.SubFolderName.extras.rawValue, atDestination: backupFolder) else {return nil}
            
            backupFolder = extrasFolder
            
        }
        
        return FileManager.CreateFolder(withName: MovieFileManager.SubFolderName.subs.rawValue, atDestination: backupFolder)
        
    }
    
    
    
    static func GetSubFiles(inFolder folderURL:URL, _ recursive:Bool = true) -> [URL] {
        
        var urls = [URL]()
        
        let allUrls = FileManager.Contents(ofFolder: folderURL)
        
        for url in allUrls {
            
            if Prefs.SubtitleExtensions.contains(url.pathExtension) {
                
                urls.append(url)
                
            } else if url.hasDirectoryPath && recursive == true {
                
                urls += SubtitleManager.GetSubFiles(inFolder: url, false)
                
            }
        }
        
        return urls
        
    }
    
    static func CheckLanguageAndReencodeIfNecessary(forFileAtURL url:URL)-> String? {
        
        var language:TMDBReference.Language?
        
        if let text = FileManager.OpenString(atURL: url, withEncoding: .utf8) {
            if text.contains("は") {
                
              language = .japanese
                
            } else if text.contains("ก") {
                
                language = .thai
                
            } else if text.lowercased().contains("what") {
                
                language = .english
                
            }
            
            return language?.rawValue
            
        }
        
        var str:String?
        
        for encoding in [String.Encoding.shiftJIS, String.Encoding.japaneseEUC] {
            
            
            if let decodedString = FileManager.OpenString(atURL: url, withEncoding: encoding) {
                
                language = .japanese
                str = decodedString
                
            }
            
        }
        
        if let text = str {
            
            do {
                
                try FileManager.default.removeItem(at: url)
                
                try text.write(to: url, atomically: false, encoding: .utf8)
                
            }
            catch  {
                
                Alert.PresentErrorAlert(text: "Could not reencode subs\n" + error.localizedDescription)
                
                return nil
                
            }
            
            
        }
        
        return language?.rawValue
        
    }
    
    
    
    static func LanguagesOfSubfile(atURL url:URL)->[String] {
        
        var languages = [String]()
        
        let fileName = url.deletingPathExtension().lastPathComponent
        
        let splitString = fileName.components(separatedBy: ".").map{ String($0) }
        
        if splitString.count > 1 &&  (splitString.contains("Netflix") || TMDBReference.Language(rawValue: splitString.last!) != nil) {
            
            return [splitString.last!]
            
        }
        
        if url.pathExtension == "idx" {
            
            do {
                
                let text = try String(contentsOf: url)
                
                var components = text.components(separatedBy: "id: ")
               
                
                while components.count > 1 {
                    
                    let secondHalfComponents = components[1].components(separatedBy:", index")
                    
                    if TMDBReference.Language(rawValue: secondHalfComponents[0]) != nil {
                        
                        languages = languages.appending(secondHalfComponents[0])
                       
                    }
                    
                    components.remove(at: 0)
                    
                }
                
            } catch {
                
                Alert.PresentErrorAlert(text: "Could not read idx file\n" + error.localizedDescription)
            }
            
        } else {
            
            if let language = SubtitleManager.CheckLanguageAndReencodeIfNecessary(forFileAtURL: url) {
                
                return [language]
                
            }
            
        }
        
        return languages
    }
    
}


