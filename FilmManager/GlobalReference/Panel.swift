//
//  Panel.swift
//  FilmManager
//
//  Created by Dylan Southard on 2019/07/07.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Cocoa

class Panel: NSObject {
    
    
    static func ChooseDirectory(withMessage message:String, sender:NSViewController, openToFolder initialURL:URL, handler:@escaping (_ url:URL?)-> Void) {
        
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.message = message
        panel.directoryURL = initialURL
        
        panel.beginSheetModal(for: sender.view.window!, completionHandler: {(response) -> Void in
            if response == .cancel {
                
                handler(nil)
                
            } else {
                
               handler(panel.url)
                
            }
        })
    }

}
