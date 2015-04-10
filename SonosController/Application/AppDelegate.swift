//
//  AppDelegate.swift
//  SonosController
//
//  Created by Nicolas Langley on 2/28/15.
//  Copyright (c) 2015 Nicolas Langley. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var statusBar = NSStatusBar.systemStatusBar()
    var statusBarItem: NSStatusItem = NSStatusItem()
    var menu: NSMenu = NSMenu()
    var playMenuItem: NSMenuItem = NSMenuItem()
    var pauseMenuItem: NSMenuItem = NSMenuItem()
    var sonosDevices: [SonosController] = []
    
    override func awakeFromNib() {
        // Add statusBarItem to status bar
        statusBarItem = statusBar.statusItemWithLength(-1)
        statusBarItem.menu = menu
        statusBarItem.title = "SC"
        
        // Add menuItem to menu
        playMenuItem.title = "Play"
        playMenuItem.enabled = true
        playMenuItem.action = Selector("playPressed")
        menu.addItem(playMenuItem)
        
        // Add menuItem to menu
        pauseMenuItem.title = "Pause"
        pauseMenuItem.enabled = true
        pauseMenuItem.action = Selector("pausePressed")
        menu.addItem(pauseMenuItem)
        
        // TODO: use SonosManager for discovering and handling devices
        
        SonosDiscover.discoverControllers {
            (devices, error) -> Void
            in
            for device in devices {
                var controller: SonosController = SonosController.alloc()
                controller.ip = device["ip"] as! String
                controller.port = Int32((device["port"] as! String).toInt()!)
                self.sonosDevices.append(controller)
            }
        }
        
    }
    
    @objc func playPressed()
    {
        for device in self.sonosDevices {
            device.play(nil, completion: {
                (response, error) -> Void
                in
                println(response)
                println(error)
            })
        }
    }
    
    @objc func pausePressed()
    {
        for device in self.sonosDevices {
            device.pause({
                (response, error) -> Void
                in
                println(response)
                println(error)
            })
        }
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

