//
//  PresentationManager.swift
//  FilmManager
//
//  Created by Dylan Southard on 2019/07/07.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Foundation
import Cocoa

enum VCIdentifier:String {
    
    case newMovieVC = "NewMovieVC"
    case prefs = "Prefs"
    
}

class WindowManager:NSObject {
    
    static var PrefsPanel:NSWindow?
    
    static let Storyboard = NSStoryboard(name:"Main", bundle: nil)
    
    static func PresentPrefsWindow() {
        
        let vc = Storyboard.instantiateController(withIdentifier: VCIdentifier.prefs.rawValue) as! PrefsVC
        
        if WindowManager.PrefsPanel == nil { WindowManager.PrefsPanel = NSWindow(contentViewController: vc) }
        
        
        if !WindowManager.PrefsPanel!.isVisible {
            
            WindowManager.PresentWindow(WindowManager.PrefsPanel!)
            
        }
   
    }
    
    static func PresentWindow(_ window:NSWindow){
        window.makeKeyAndOrderFront((NSApplication.shared.delegate as! AppDelegate))
        let vc = NSWindowController(window: window)
        vc.showWindow((NSApplication.shared.delegate as! AppDelegate))
    }
    
}
