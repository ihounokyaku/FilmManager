//
//  FolderDropView.swift
//  movieFiler
//
//  Created by Dylan Southard on 2018/01/07.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Cocoa

class FolderDropView: DropView {

    var destination = true
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([NSPasteboard.PasteboardType.URL])
    }
    
    override func setType() { self.dropViewType = .folder }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
    
    override func checkExtension(_ drag: NSDraggingInfo) -> Bool {
        print("going to check extension")
        if let url = self.getUrl(drag) {
            return url.hasDirectoryPath
        }
        return false
    }
    
  
    
    
}
