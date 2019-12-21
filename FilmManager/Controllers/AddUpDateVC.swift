//
//  AddUpDateVC.swift
//  FilmManager
//
//  Created by Dylan Southard on 2019/07/11.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Cocoa

class AddUpDateVC: NSViewController, DropViewDelegate, MovieCreatorDelegate{
    
    
    @IBOutlet weak var progressBar: NSProgressIndicator!
    
    @IBOutlet weak var tagTable: NSTableView!
    
    //MARK: - === FIELDS ===
    @IBOutlet weak var addTagField: NSTextField!
    
    //MARK: - === DATA SETS ===
    
    var tagTableData = [Tag]()
    
    var fileCreator:MovieFileCreator!
    
    var selectedTags:[Tag] { return self.tagTableData.filter{ $0.checked } }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tagTable.delegate = self
        self.tagTable.dataSource = self

        self.fileCreator = MovieFileCreator(delegate: self)
    }
    
    
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
    
    func didGetURL(url: URL, dropView: DropView) {}
    
    //MARK: - =============== MOVIE CREATOR ===============
    
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


extension AddUpDateVC:NSTableViewDelegate, NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.tagTableData.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var view:NSView?
        
         if tableView == self.tagTable {
            
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
    
    
}






