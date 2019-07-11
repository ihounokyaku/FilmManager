//
//  AppDelegate.swift
//  FilmManager
//
//  Created by Dylan Southard on 2019/07/03.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func preferencesPressed(_ sender: Any) {
        
        WindowManager.PresentPrefsWindow()
        
    }
    
}

