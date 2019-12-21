//
//  UpdateMovieVC.swift
//  FilmManager
//
//  Created by Dylan Southard on 2019/07/11.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Cocoa

class UpdateMovieVC: AddUpDateVC, SubtitleDelegate {
    
    //MARK: - =============== IBOUTLETS ===============
    
    
    //MARK: - === DROPVIEWS ===
    @IBOutlet weak var subtitleDropView: MixDropView!
    @IBOutlet weak var threeDDropView: FileDropView!
    @IBOutlet weak var folderDropView: FolderDropView!
    
    //MARK: - === LABELS ===
    @IBOutlet weak var topLabel: NSTextField!
    
    var dropViews:[DropView] { return [self.subtitleDropView, self.threeDDropView, self.folderDropView]}
    
    //MARK: - =============== VARS ===============
    
    //MARK: - === STATE VARS ===
    var currentFolderURL:URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for dropview in self.dropViews { dropview.delegate = self }
        
        self.toggleEnabled()
        
        self.subtitleDropView.expectedExt = Prefs.SubtitleExtensions
        // Do view setup here.
    }
    
    func toggleEnabled() {
        
        let enable = self.currentFolderURL != nil
    
        self.addTagField.isEnabled = enable
        self.subtitleDropView.isEnabled = enable
        self.threeDDropView.isEnabled = enable

    }
    
    //MARK: - === TAGS ===
    
    func addDefaultTags() {
        let tagNames = self.tagTableData.map {$0.name}
        
        for tag in Prefs.CheckBoxTitles {
            
            if !tagNames.contains(tag) {
                self.tagTableData.append(Tag(name: tag, checked: false, type: .userDefault))
            }
            
        }
        
    }
    
    @IBAction func saveTags(_ sender: Any) {
        
        guard let folderURL = currentFolderURL else { return }
        
        MovieFileManager.ReplaceTags(ofMovieAtURL: folderURL, with: self.selectedTags.map { $0.name })
        
        
    }
    
    func refreshTags() {
        
        self.tagTableData.removeAll()
        
        guard let url = self.currentFolderURL else { return }
        
        for tag in url.tags {
            
            self.tagTableData.append(Tag(name: tag, checked: true, type: .queried))
            
        }
        
        self.addDefaultTags()
        
        self.tagTable.reloadData()
        
    }
    
    
    
    //MARK: - =============== DROPVIEW ===============
    
    override func didGetURL(url: URL, dropView: DropView) {
        
        switch dropView.dropViewType! {
            
        case .folder:
            
            self.currentFolderURL = url
            
            self.topLabel.stringValue = currentFolderURL!.lastPathComponent
            
            self.refreshTags()
            
            self.toggleEnabled()
            
        case .file:
            guard let movieFolder = self.currentFolderURL else { return }
            
            self.fileCreator.copy3DFile(atURL: url, toMovieFolder: movieFolder, key: "3D")
            
            break
            
        case .mixed:
            
            guard let movieFolder = self.currentFolderURL else { return }
            
            SubtitleManager.CopySubtitles(fromURL: url, toFolder: movieFolder, movieTitle: movieFolder.lastPathComponent, delegate:self)
            
        }
        
    }
    
    override func taskComplete(inMovieCreator movieCreator: MovieFileCreator, key: String?) {
        
        super.taskComplete(inMovieCreator: movieCreator, key: key)
        
        self.refreshTags()
        
    }
    
    func didUpdateSubtitles() {
        
        self.refreshTags()
    }
    
}
