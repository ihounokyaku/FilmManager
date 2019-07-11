//
//  MovieFileCreator.swift
//  FilmManager
//
//  Created by Dylan Southard on 2019/07/08.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Cocoa
import SwiftTMDB_MacOS

protocol MovieCreatorDelegate:class {
    
    func updateCopyProgress(forMovieCreator movieCreator:MovieFileCreator, amountComplete:Double, total: Double, key:String?)
    
    func taskComplete(inMovieCreator movieCreator:MovieFileCreator, key:String?)
    
    func handleMovieCreatorError(forMovieCreator movieCreator:MovieFileCreator, key:String?, error:Error?)
    
    func taskBegan(inMovieCreator movieCreator:MovieFileCreator, key:String?)
    
}

extension MovieCreatorDelegate {
    
    func updateCopyProgress(forMovieCreator movieCreator:MovieFileCreator, amountComplete:Double, total: Double, key:String?){}
    
    func taskComplete(inMovieCreator movieCreator:MovieFileCreator, key:String?){}
    
    func handleMovieCreatorError(forMovieCreator movieCreator:MovieFileCreator, key:String?, error:Error?){}
    
    func taskBegan(inMovieCreator movieCreator:MovieFileCreator, key:String?){}
    
}

class MovieFileCreator: NSObject {

    
    weak var delegate:MovieCreatorDelegate?
    
    var currentCopyOperations = [CopyOperation]()
    var queuedCopyOperations = [CopyOperation]()
    var maxOperationCount = 1
    
    
    init(delegate:MovieCreatorDelegate) {
        
        self.delegate = delegate
        
    }
    
    
    func fileMovie(_ movie:TMDBMovie, withTags tags:[String], videoFileURL:URL, key:String?) {
        
        let destinationURL = FileManager.ExternalDestinationAvailable ? Prefs.ExternalDestinationFolder! : Prefs.LocalDestinationFolder
        
        guard let folderURL = FileManager.CreateUniqueFolder(withName: movie.title, atDestination: destinationURL, alternateNameSuggestion: "\(movie.title) (\(movie.releaseDate.year()))") else { return }
        
        
        let copyOperation = CopyOperation(sourceFileURL:videoFileURL, destinationFileURL: folderURL, delegate: self, key:key)
            
        self.executeOrQueue(operation: copyOperation)
        

        MovieFileManager.ConstructMovieFolder(forMovie: movie, toFolder: folderURL, withTags: tags, updateCatalogue: Prefs.CreateLibrary)
        
        MovieFileManager.CopySubtitles(fromFolder: videoFileURL.deletingLastPathComponent(), toFolder: folderURL)
        
       guard Prefs.CreateBackup, MovieFileManager.BackupFolderExists else { return }
            
        guard let backupURL = FileManager.CreateFolder(withName: folderURL.lastPathComponent, atDestination: Prefs.BackupDestinationFolder!) else { return }
        
        MovieFileManager.ConstructMovieFolder(forMovie: movie, toFolder: backupURL, withTags: tags, updateCatalogue: false)
        
        MovieFileManager.CopySubtitles(fromFolder: videoFileURL.deletingLastPathComponent(), toFolder: backupURL)
        
    }
    
    
    func executeOrQueue (operation:CopyOperation) {
        
        if self.currentCopyOperations.count < maxOperationCount {
            
            operation.execute()
            
            self.monitorFileProgress(forOperation: operation, key: operation.key)
            
            self.currentCopyOperations = self.currentCopyOperations.appending(operation)
            
        } else {
            
            self.queuedCopyOperations = self.currentCopyOperations.appending(operation)
        }
        
    }
    
    func finishOperationAndContinue(operation:CopyOperation) {
        
        self.currentCopyOperations = self.currentCopyOperations.removing(operation)
        
        if self.queuedCopyOperations.count > 0 {
            
            let operation = self.queuedCopyOperations.removeFirst()
            
            self.executeOrQueue(operation: operation)
            
        }
    }
    
    func monitorFileProgress(forOperation operation:CopyOperation, key:String?) {
        
        self.delegate?.taskBegan(inMovieCreator: self, key: key)
        
        let destinationURL = operation.destinationFileURL.appendingPathComponent(operation.sourceFileURL.lastPathComponent)
        
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                
                if let currentFileSize = destinationURL.fileSize, let totalFileSize = operation.sourceFileURL.fileSize {
                    
                    
                    self.delegate?.updateCopyProgress(forMovieCreator: self, amountComplete: Double(currentFileSize), total: Double(totalFileSize), key: key)
                    
                    if currentFileSize >= totalFileSize {
                        
                        self.delegate?.taskComplete(inMovieCreator: self, key: key)
                        
                        timer.invalidate()
                        
                    }
                }
                
            }
            
        }
}


