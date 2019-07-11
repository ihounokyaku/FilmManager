//
//  PrefsVC.swift
//  FilmManager
//
//  Created by Dylan Southard on 2019/07/07.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Cocoa

class LocationPrefsVC: NSViewController {
    
    @IBOutlet weak var localLabel: NSTextField!
    @IBOutlet weak var localView: NSView!
    
    
    @IBOutlet weak var externalLabel: NSTextField!
    @IBOutlet weak var externalView: NSView!
    
    
    @IBOutlet weak var backupLabel: NSTextField!
    @IBOutlet weak var backupCheckbox: NSButton!
    @IBOutlet weak var backupView: NSView!
    @IBOutlet weak var backupBrowse: NSButton!
    
    @IBOutlet weak var libraryView: NSView!
    @IBOutlet weak var libraryCheckbox: NSButton!
    @IBOutlet weak var libraryLabel: NSTextField!
    @IBOutlet weak var libraryBrowse: NSButton!
    
    
    var checkBoxViews = [String:CheckboxFilePickerView]()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.checkBoxViews["backup"] = CheckboxFilePickerView(checkbox: self.backupCheckbox, view: self.backupView, button: self.backupBrowse)
        
        self.checkBoxViews["library"] = CheckboxFilePickerView(checkbox: self.libraryCheckbox, view: self.libraryView, button: self.libraryBrowse)
        
       self.setDisplay()
        
    }
    
    var libraryCheckboxSet:CheckboxFilePickerView {return self.checkBoxViews["library"]!}
    
    var backupCheckboxSet:CheckboxFilePickerView { return self.checkBoxViews["backup"]! }
    
    
    
    struct CheckboxFilePickerView {
        
        var checkbox:NSButton
        var view:NSView
        var button:NSButton
        
    }
    
    func setDisplay() {
        
        for view in [self.backupView, self.externalView, self.localView, self.libraryView] {
            view!.wantsLayer = true
            view!.layer?.borderColor = NSColor.ColorSecondaryDark(alpha:0.4).cgColor
            view!.layer?.borderWidth = 2
            
        }
        
       self.setCheckBoxState(forCheckbox: self.backupCheckboxSet, on: Prefs.CreateBackup)
        
        self.setCheckBoxState(forCheckbox: self.libraryCheckboxSet, on: Prefs.CreateLibrary)
        
        self.setLabels()
        
    }
    
 
    
    func setCheckBoxState(forCheckbox checkboxSet:CheckboxFilePickerView, on:Bool) {
        
        checkboxSet.checkbox.state = on ? .on : .off
        
        self.enableDisableView(forCheckboxSet: checkboxSet)
    }
    
    func enableDisableView(forCheckboxSet checkboxSet:CheckboxFilePickerView) {
        
       
        let enable = checkboxSet.checkbox.state == .on
        
        checkboxSet.view.alphaValue = enable ? 1 : 0.5
        
        checkboxSet.button.isEnabled = enable
        
    }
    
    func setLabels() {
        
        self.localLabel.stringValue = Prefs.LocalDestinationFolder.path
        
        self.setURLLabel(self.externalLabel, url: Prefs.ExternalDestinationFolder)
        
        self.setURLLabel(self.backupLabel, url: Prefs.BackupDestinationFolder)
        
        self.setURLLabel(self.libraryLabel, url: Prefs.LibraryDestinationFolder)
    
        
    }
    
    func setURLLabel(_ textField:NSTextField, url:URL?) {
    
        textField.stringValue = url?.path ?? "[No directory selected]"
        
    }
    
    
    
    @IBAction func browseLocalPressed(_ sender: Any) {
        
        Panel.ChooseDirectory(withMessage: "Please a local directory to which your data will be saved if the external is not available", sender: self, openToFolder: Prefs.LocalDestinationFolder) { (selectedURL) in
            
            
            if let url = selectedURL {
                
                Prefs.LocalDestinationFolder = url
                self.setLabels()
            }
            
        }
        
    }
    
    @IBAction func browseExternalPressed(_ sender: Any) {
        
        Panel.ChooseDirectory(withMessage: "Please an external directory to which your data will be saved", sender: self, openToFolder: Prefs.ExternalDestinationFolder ?? Prefs.DefaultFolder) { (selectedURL) in
           
            if let url = selectedURL {
                
                Prefs.ExternalDestinationFolder = url
                
                self.setLabels()
                
            }
            
        }
        
    }
    
    @IBAction func browseBackup(_ sender: Any) {
        
        
        Panel.ChooseDirectory(withMessage: "Please select a backup folder", sender: self, openToFolder: Prefs.BackupDestinationFolder ?? Prefs.LocalDestinationFolder) { (selectedURL) in
            
            if let url = selectedURL {
                
                Prefs.BackupDestinationFolder = url
                
                self.setLabels()
                
            }
            
        }

        
    }
    
    @IBAction func browseLibrary(_ sender: Any) {
        
        Panel.ChooseDirectory(withMessage: "Please select a library catalogue folder", sender: self, openToFolder: Prefs.LibraryDestinationFolder ?? Prefs.LocalDestinationFolder) { (selectedURL) in
            
            if let url = selectedURL {
                
                
                Prefs.LibraryDestinationFolder = url
                
                self.setLabels()
                
            }
            
        }
        
        
    }
    
    @IBAction func createBackupToggled(_ sender: Any) {
        
        Prefs.CreateBackup = self.backupCheckbox.state == .on
        self.enableDisableView(forCheckboxSet: self.checkBoxViews["backup"]!)
        
    }
    
    
    @IBAction func createLibraryToggled(_ sender: Any) {
        
        Prefs.CreateLibrary = self.libraryCheckbox.state == .on
        
        self.enableDisableView(forCheckboxSet: self.checkBoxViews["library"]!)
        
    }
    
}
