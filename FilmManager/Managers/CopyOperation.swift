//
//  CopyOperation.swift
//  FilmManager
//
//  Created by Dylan Southard on 2019/07/08.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Cocoa

class CopyOperation: NSObject {
    
    var sourceFileURL:URL
    var destinationFileURL:URL
    var timer:Timer?
    var delegate:MovieFileCreator?
    var key:String?
    
    
    required init(sourceFileURL:URL, destinationFileURL:URL, delegate:MovieFileCreator?, key:String?) {
        
        self.sourceFileURL = sourceFileURL
        self.destinationFileURL = destinationFileURL
        self.delegate = delegate
        self.key = key
        
    }
    
    func execute() {
        
        FileManager.CopyFile(atURL: sourceFileURL, toFolder: destinationFileURL, operation: self)
    }
    
    
    func cancel() {
        
        self.delegate?.finishOperationAndContinue(operation: self)
        
        self.timer?.invalidate()
        
    }

}
