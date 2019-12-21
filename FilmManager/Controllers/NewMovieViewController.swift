//
//  ViewController.swift
//  FilmManager
//
//  Created by Dylan Southard on 2019/07/03.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Cocoa
import SwiftTMDB_MacOS
import SwiftyJSON

class NewMovieViewController: AddUpDateVC {

    //MARK: - =============== IBOUTLETS ===============
    @IBOutlet weak var fileDropView: FileDropView!
    
    //MARK: - === Tables ===
    @IBOutlet weak var suggestionTable: NSTableView!
    
    //MARK: - === Buttons ===
    @IBOutlet weak var createFileButton: NSButton!
    
    //MARK: - === Other Views ===
    @IBOutlet weak var posterView: NSImageView!
    
    //MARK: - =============== VARS ===============
    
    //MARK: - === Managers ===
    
    var queryManager:TMDBQueryManager!
    
    //MARK: - === DataSets ===
    var suggestionTableData = [TMDBMovie]()
    
    var selectedMovie:TMDBMovie? {
        
        if self.suggestionTable.selectedRow >= 0 {
            return self.suggestionTableData[self.suggestionTable.selectedRow]
        }
        return nil
    }
    
    //MARK: - === Status Vars ===
    var currentSearchTitle:String?
    
    var currentMovieURL:URL?

    //MARK: - =============== SETUP ===============
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.queryManager = TMDBQueryManager(delegate: self, apiKey: Prefs.ApiKey)
        
        self.queryManager.defaultPosterSize = .w342
        
        self.fileDropView.delegate = self
        
        self.setDelegate(forTableView: self.suggestionTable)
        
        self.setDelegate(forTableView: self.tagTable)
        
        
        
    }

    
    func setDelegate(forTableView tableView:NSTableView) {
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    //MARK: - =============== UPDATE STATES ===============
    
    func toggleButtons() {
        
        let enabled = self.suggestionTable.selectedRow >= 0
        self.createFileButton.isEnabled = enabled
        self.addTagField.isEnabled = enabled
        
    }
    
    func clearAll() {
        
        self.posterView.image = nil
        
        self.suggestionTableData.removeAll()
        self.suggestionTable.reloadData()
        
        self.tagTableData.removeAll()
        self.tagTable.reloadData()
        
        self.addTagField.stringValue = ""
        
        self.toggleButtons()
        
    }
    
    //MARK: - === REFRESH VIEWS ===
    
    func refreshMovieView() {
        
        if self.suggestionTable.selectedRow >= 0 {
            
            self.posterView.image = NSImage.SafeImage(fromData: self.suggestionTableData[self.suggestionTable.selectedRow].imageData)
            
        } else {
            
            self.posterView.image = nil
        
        }
        self.toggleButtons()
        
    }
    
    func refreshTagTableView() {
        
        self.tagTableData.removeAll()
        
            if self.suggestionTable.selectedRow >= 0 {
                
                for title in Prefs.CheckBoxTitles {
                    
                    self.tagTableData.append (Tag(name: title, checked: Prefs.CheckedBoxes.contains(title), type:.userDefault))
                    
                }
                
                let movie = self.suggestionTableData[self.suggestionTable.selectedRow]
                
                for genre in movie.genres {
                    
                    self.tagTableData.append(Tag(name: genre, checked: true, type:.queried))
                    
                }
                
                for director in movie.directors {
                    
                    self.tagTableData.append(Tag(name: director.name, checked: true, type:.queried))
                    
                }
            }
        
        self.tagTable.reloadData()
        
    }
    
    
    
    //MARK: - =============== USER INTERACTION ===============
 
    
    @IBAction func createFilePressed (_ sender: Any) {
        
        self.createFileButton.isEnabled = false
        guard let movie = self.selectedMovie, let movieURL = self.currentMovieURL else {
            Alert.PresentErrorAlert(text: "No movie selected!")
            return
        }
        
        
        
        fileCreator.fileMovie(movie, withTags: (self.selectedTags.map{ $0.name }).appending("movie"), videoFileURL: movieURL, key: "\(movie.id)")
    
    }
    
    //MARK: - =============== DROP VIEW ===============
    
    override func didGetURL(url: URL, dropView: DropView) {
        
        print("got URL")
        
        self.clearAll()
        
        self.currentMovieURL = url
        
        self.currentSearchTitle = url.deletingPathExtension().lastPathComponent
        
        self.queryManager.searchForMovie(title: currentSearchTitle!.searchString())
        
    }
    
    //MARK: - =============== TABLEVIEW ===============
    
    override func numberOfRows(in tableView: NSTableView) -> Int {
        
        return tableView == self.suggestionTable ? self.suggestionTableData.count : super.numberOfRows(in: tableView)
        
    }
    
    override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var view:NSView?
        
        if tableView == self.suggestionTable {
            
            let cellView = (tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView)
            
            let dataSource = self.suggestionTableData[row]
            
            cellView.textField?.stringValue = tableColumn?.identifier.rawValue == "Title" ? dataSource.title : dataSource.releaseDate.year()
            
            view = cellView
            
        } else {
            
            view = super.tableView(tableView, viewFor: tableColumn, row: row)
            
        }
        
        return view
        
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        if let tableView = notification.object as? NSTableView, tableView == self.suggestionTable {
            
            self.addTagField.stringValue = ""
            self.refreshMovieView()
            self.refreshTagTableView()
            
        }
        
    }

    
}



//MARK: - =============== QUERY MANAGER ===============



extension NewMovieViewController:TMDBQueryManagerDelegate {
    
    
    func objectQueryComplete(TMDBQueryManager: TMDBQueryManager, queryType: TMDBQueryManager.QueryType, results: [TMDBObject]?, error: String?, key: String?, sender: Any?) {
        
        guard let realResults = results else  {
           Alert.PresentErrorAlert(text: "No results " + (error ?? "unknown error"))
            return
        }
        
        guard realResults.count > 0 else {Alert.PresentErrorAlert(text: "No results!"); return}
        
        if queryType == .search {
            
            self.suggestionTableData = realResults as! [TMDBMovie]
            
            for movie in self.suggestionTableData {
                
                self.queryManager.queryMovieDetails(movie: movie, includeOptions: [.credits, .videos])
                
            }
            
            self.suggestionTable.reloadData()
            
        } else if queryType == .get {
            
            //check if this is the movie selected
            guard let movie = realResults.first as? TMDBMovie else { return }
            
            if self.suggestionTable.selectedRow >= 0 && movie.id == self.suggestionTableData[self.suggestionTable.selectedRow].id {
                
                self.refreshTagTableView()
                
            }
        }
    }
    
    func imageQueryComplete(TMDBQueryManager: TMDBQueryManager, data: Data?, forObject object: TMDBObject?, objectID: Int, objectType: TMDBObject.ObjectType, backdrop: Bool, error: String?, key: String?, sender: Any?) {
        
        if self.posterView == nil {
            
            self.refreshMovieView()
            
        }
        
        
    }
    
}



//MARK: - =============== OTHER EXTENSIONS ===============

extension String {
    
    func searchString()-> String {
        
        let array = self.components(separatedBy: .whitespaces).filter {!$0.isEmpty}
        
        let exportString = array.joined(separator: "+")
        
        return exportString
    }
    
    func year()->String {
        
        let array = self.components(separatedBy: "-")
        if array.count > 0 {
            return array[0]
        }
        return self
    }
    
}


