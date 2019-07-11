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

class NewMovieViewController: NSViewController {
    

    //MARK: - =============== IBOUTLETS ===============
    @IBOutlet weak var fileDropView: FileDropView!
    
    //MARK: - === Tables ===
    @IBOutlet weak var suggestionTable: NSTableView!
    @IBOutlet weak var tagTable: NSTableView!
    
    //MARK: - === Buttons ===
    @IBOutlet weak var createFileButton: NSButton!
    
    //MARK: - === FIELDS ===
    @IBOutlet weak var addTagField: NSTextField!
    
    
    //MARK: - === Other Views ===
    @IBOutlet weak var posterView: NSImageView!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    
    //MARK: - =============== VARS ===============
    
    //MARK: - === Managers ===
    
    var queryManager:TMDBQueryManager!
    
    //MARK: - === DataSets ===
    var suggestionTableData = [TMDBMovie]()
    
    var tagTableData = [Tag]()
    
    var selectedTags:[Tag] { return self.tagTableData.filter{ $0.checked } }
    
    var selectedMovie:TMDBMovie? {
        
        if self.suggestionTable.selectedRow >= 0 {
            return self.suggestionTableData[self.suggestionTable.selectedRow]
        }
        return nil
    }
    
    //MARK: - === Status Vars ===
    var currentSearchTitle:String?
    
    var currentMovieURL:URL?
    
    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
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
 
    @IBAction func checkBoxChecked(_ sender: NSButton) {
        
        let index = self.tagTable.row(for: sender)
        if index >= 0 {
            
            self.tagTableData[index].checked = !self.tagTableData[index].checked
            
        }
        
    }
    
    @IBAction func newTagEntered(_ sender: NSTextField) {
        
        let str = sender.stringValue
        guard str != "", !(self.tagTableData.map{ return $0.name }.contains(str)) else {return}
        
        sender.stringValue = ""
        self.tagTableData.append(Tag(name: str, checked: true, type: .user))
        
        self.tagTable.reloadData()
        
    }
    
    @IBAction func createFilePressed (_ sender: Any) {
        
        self.createFileButton.isEnabled = false
        guard let movie = self.selectedMovie, let movieURL = self.currentMovieURL else {
            Alert.PresentErrorAlert(text: "No movie selected!")
            return
        }
        
        let fileCreator = MovieFileCreator(delegate: self)
        
        fileCreator.fileMovie(movie, withTags: self.selectedTags.map{ $0.name }, videoFileURL: movieURL, key: "\(movie.id)")
    
    }

    
}



//MARK: - =============== QUERY MANAGER ===============



extension NewMovieViewController:TMDBQueryManagerDelegate {
    
    
    func objectQueryComplete(TMDBQueryManager: TMDBQueryManager, queryType: TMDBQueryManager.QueryType, results: [TMDBObject]?, error: String?, key: String?, sender: Any?) {
        
        guard let realResults = results else  {
            print("ERROR!! \(error ?? "Unknown Error!")")
            return
        }
        
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




//MARK: - =============== MOVIE CREATOR ===============

extension NewMovieViewController:MovieCreatorDelegate {
    
    func taskBegan(inMovieCreator movieCreator: MovieFileCreator, key: String?) {
        
        self.progressBar.doubleValue = 0
        
    }
    
    func taskComplete(inMovieCreator movieCreator: MovieFileCreator, key: String?) {
        
        self.progressBar.doubleValue = 0
        
    }
    
    func updateCopyProgress(forMovieCreator movieCreator: MovieFileCreator, amountComplete: Double, total: Double, key: String?) {
        
        self.progressBar.doubleValue = (amountComplete / total) * 100
        
    }
    
    func handleMovieCreatorError(forMovieCreator movieCreator: MovieFileCreator, key: String?, error: Error?) {
    
    }
    
    
}

//MARK: - =============== DROP VIEW ===============

extension NewMovieViewController:DropViewDelegate {
    
    func didGetURL(url: URL, dropView: DropView) {
        
        self.clearAll()
        
        self.currentMovieURL = url
        
        self.currentSearchTitle = url.deletingPathExtension().lastPathComponent
        
        self.queryManager.searchForMovie(title: currentSearchTitle!.searchString())
        
    }
    
}




//MARK: - =============== TABLEVIEW ===============


extension NewMovieViewController:NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        return tableView == self.suggestionTable ? self.suggestionTableData.count : self.tagTableData.count
        
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var view:NSView?
        
        if tableView == self.suggestionTable {
            
            let cellView = (tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView)
            
            let dataSource = self.suggestionTableData[row]
            
            cellView.textField?.stringValue = tableColumn?.identifier.rawValue == "Title" ? dataSource.title : dataSource.releaseDate.year()
            
            view = cellView
            
        } else if tableView == self.tagTable {
            
            let tag = self.tagTableData[row]
            
            let checkCell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! CheckCell
            
            checkCell.checkBox.state = tag.checked == true ? .on : .off
            
            checkCell.checkBox.title = tag.name
            
            checkCell.checkBox.attributedTitle = NSAttributedString(string: tag.name, attributes: [ NSAttributedString.Key.foregroundColor: NSColor.TextDarkPrimary()])
            
            let alpha:CGFloat = 0.6
            
            let cellColors:[TagType:NSColor] = [.userDefault:NSColor.OffWhitePrimary(alpha:alpha), .queried:NSColor.ColorSecondaryLight(alpha: alpha), .user:NSColor.ColorTextEmphasisLight()]
            
            checkCell.wantsLayer = true
            checkCell.layer?.backgroundColor = cellColors[tag.type]?.cgColor
            
            view = checkCell
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


