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
        
        var title = movie.title.replacingOccurrences(of: "/", with: " -")
        title = movie.title.replacingOccurrences(of: ":", with: " -")
        
        guard let folderURL = FileManager.CreateUniqueFolder(withName: title, atDestination: destinationURL, alternateNameSuggestion: "\(movie.title) (\(movie.releaseDate.year()))") else { return }
        

        MovieFileManager.ConstructMovieFolder(forMovie: movie, toFolder: folderURL, withTags: tags, updateCatalogue: Prefs.CreateLibrary)
        
        
        
        if let backupURL = MovieFileManager.CreateBackupFolder(forFolder: folderURL) {


            MovieFileManager.ConstructMovieFolder(forMovie: movie, toFolder: backupURL, withTags: tags, updateCatalogue: false)

        }

        let copyOperation = CopyOperation(sourceFileURL:videoFileURL, destinationFileURL: folderURL, delegate: self, key:key)

        self.executeOrQueue(operation: copyOperation)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            SubtitleManager.CopySubtitles(fromURL: videoFileURL.deletingLastPathComponent(), toFolder: folderURL, movieTitle: movie.title)
            
        }

    }
    
    func copy3DFile(atURL fileURL:URL, toMovieFolder folderURL:URL, key:String?) {
        
        guard let extrasURL = FileManager.CreateFolder(withName: MovieFileManager.SubFolderName.extras.rawValue, atDestination: folderURL) else { return }
        
        guard let newfileURL = FileManager.ChangeName(ofItemAtURL: fileURL, to: folderURL.lastPathComponent + "-3D") else { return }
        
        SubtitleManager.CopySubtitles(fromURL: newfileURL.deletingLastPathComponent(), toFolder: folderURL, movieTitle: folderURL.lastPathComponent, extras:true)
        
        MovieFileManager.AddTags(["3D"], toFolder: folderURL)
        
        let copyOperation = CopyOperation(sourceFileURL:newfileURL, destinationFileURL: extrasURL, delegate: self, key:key)
        
        self.executeOrQueue(operation: copyOperation)
        
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
                        self.finishOperationAndContinue(operation: operation)
                        timer.invalidate()
                        
                    }
                }
                
            }
            
        }
}


