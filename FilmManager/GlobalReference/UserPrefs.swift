//
//  UserPrefs.swift
//  FilmManager
//
//  Created by Dylan Southard on 2019/07/03.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Foundation

class Prefs:NSObject {
    
    static var LocalDestinationFolder:URL {
        
        get {
            
            return UserDefaults.standard.url(forKey: "initialDestinationFolder") ?? Prefs.DefaultFolder
            
        }
        
        set {
            
            UserDefaults.standard.set(newValue, forKey: "initialDestinationFolder")
            
        }
        
    }
    
    
    static var ExternalDestinationFolder:URL? {
        get {

            return UserDefaults.standard.url(forKey: "ExternalDestinationFolder")
        }
        
        set {
            
            UserDefaults.standard.set(newValue, forKey: "ExternalDestinationFolder")
           
        }
    }
    
    
    static var BackupDestinationFolder:URL? {
        get {
            
            return UserDefaults.standard.url(forKey: "BackupDestinationFolder")
        }
        
        set {
            
            UserDefaults.standard.set(newValue, forKey: "BackupDestinationFolder")
            
        }
    }
    
    static var LibraryDestinationFolder:URL? {
        get {
            
            return UserDefaults.standard.url(forKey: "LibraryDestinationFolder")
        }
        
        set {
            
            UserDefaults.standard.set(newValue, forKey: "LibraryDestinationFolder")
            
        }
    }
    
    static var DefaultFolder:URL {
        get {
            
            return UserDefaults.standard.url(forKey: "DefaultFolder") ?? URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        }
        
        set {
            
            UserDefaults.standard.set(newValue, forKey: "DefaultFolder")
            
        }
    }
    
    static var CreateBackup:Bool {
        get {
            
            return UserDefaults.standard.value(forKey: "CreateBackup") as? Bool ?? true
        }
        
        set {
            
            UserDefaults.standard.set(newValue, forKey: "CreateBackup")
            
        }
        
    }
    
    static var CreateLibrary:Bool {
        get {
            
            return UserDefaults.standard.value(forKey: "CreateLibrary") as? Bool ?? true
        }
        
        set {
            
            UserDefaults.standard.set(newValue, forKey: "CreateLibrary")
            
        }
        
    }
    
    static var ApiKey:String { return "0c3663b8d7962487b7ad4329bf07b432" }
    
    
    static var CheckBoxTitles:[String] {
        
        get {
            
            return UserDefaults.standard.value(forKey: "CheckBoxTitles") as? [String] ?? ["to watch", "Thai", "English", "japanese", "mindfuck", "CG", "Super Hero"]
           
        }
        
        set {
            
            UserDefaults.standard.set(newValue, forKey: "CheckBoxTitles")
            
        }
    }
    
    static var CheckedBoxes:[String] {
        
        get {
            return UserDefaults.standard.value(forKey: "CheckBoxTitles") as? [String] ?? ["to watch", "English"]
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "CheckBoxTitles")
        }
        
    }
    
    static var SubtitleExtensions:[String] {
        
        get {
            
            return UserDefaults.standard.value(forKey: "SubtitleExtensions") as? [String] ?? ["sub", "srt", "idx", "sup", "ass", "vtt"]
            
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "SubtitleExtensions")
        }
        
        
    }
    
    static var LanguagesToTag:[String] {
        get {
            
            return UserDefaults.standard.value(forKey: "LanguagesToTag") as? [String] ?? ["japanese", "english", "thai"]
            
        }
        
        set {
            
            UserDefaults.standard.set(newValue, forKey: "LanguagesToTag")
            
        }
    
    
    }
    
    
    
}
