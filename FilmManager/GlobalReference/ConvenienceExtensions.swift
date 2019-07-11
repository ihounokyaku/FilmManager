//
//  ConvenienceExtensions.swift
//  FilmManager
//
//  Created by Dylan Southard on 2019/07/04.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Foundation
import Cocoa

extension Array where Element:Equatable {
    
    func removing(_ element:Element)->Array {
        var array = self
        
        if let index = self.firstIndex(of: element) {
            
            array.remove(at: index)
            
        }
        return array
    }
    
    func appending(_ element:Element)-> Array {
        var array = self
        
        if array.contains(element) {
            return self
        } else {
            array.append(element)
            return array
        }
        
    }
    
    
}

extension String {
    
    func makeLink(atPath path:String) {
        let content = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n<plist version=\"1.0\">\n<dict>\n<key>URL</key>\n<string>" + self + "</string>\n</dict>\n</plist>"
        do {
            try content.write(toFile: path + ".webloc", atomically: false, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            
            Alert.PresentErrorAlert(text: error.localizedDescription)
            
        }
    }
    
}

extension URL {
    
    var fileSize: Int? {
        let value = try? resourceValues(forKeys: [.fileSizeKey])
        return value?.fileSize
    }
    
    var fileExists:Bool {
        
        let path = self.path
        
        if FileManager.default.fileExists(atPath: path) {return true}
        
        return false
        
    }
}


