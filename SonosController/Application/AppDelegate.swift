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
    var nextMenuItem: NSMenuItem = NSMenuItem()
    var prevMenuItem: NSMenuItem = NSMenuItem()
    var quitMenuItem: NSMenuItem = NSMenuItem()
    
    var sonosDevices: [SonosController] = []
    
    // Initialization of application
    override init() {
        super.init()
        
        // Add statusBarItem to status bar
        statusBarItem = statusBar.statusItemWithLength(-1)
        statusBarItem.menu = menu
        statusBarItem.image = NSImage(named: "sonos-icon-round")
        
        // Add play option to menu
        playMenuItem.title = "Play"
        playMenuItem.action = "playPressed:"
        menu.addItem(playMenuItem)
        
        // Add pause option to menu
        pauseMenuItem.title = "Pause"
        pauseMenuItem.action = "pausePressed:"
        menu.addItem(pauseMenuItem)
        
        // Add next option to menu
        nextMenuItem.title = "Next"
        nextMenuItem.action = "nextPressed:"
        menu.addItem(nextMenuItem)
        
        // Add previous option to menu
        prevMenuItem.title = "Previous"
        prevMenuItem.action = "prevPressed:"
        menu.addItem(prevMenuItem)
        
        // Add quit option to menu
        quitMenuItem.title = "Quit"
        quitMenuItem.action = "quitPressed:"
        menu.addItem(quitMenuItem)
        
        
    }
    
    func applicationWillFinishLaunching(aNotification: NSNotification)
    {
        // TODO: use SonosManager for discovering and handling devices?
        SonosDiscover.discoverControllers {
            (devices, error) -> Void
            in
            if (devices == nil) {
                println("No devices found")
            } else {
                for device in devices {
                    var controller: SonosController = SonosController.alloc()
                    controller.ip = device["ip"] as! String
                    controller.port = Int32((device["port"] as! String).toInt()!)
                    self.sonosDevices.append(controller)
                }
            }
        }
    }
    
    // MARK: Menu Choice Handling
    
    /**
    Handle pressing of play option in status bar menu
    */
    func playPressed(sender: AnyObject)
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
    
    /**
    Handle pressing of pause option in status bar menu
    */
    func pausePressed(sender: AnyObject)
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
    
    /**
    Handle pressing of next option in status bar menu
    */
    func nextPressed(sender: AnyObject)
    {
        for device in self.sonosDevices {
            device.next({
                (response, error) -> Void
                in
                println(response)
                println(error)
            })
        }
    }
    
    /**
    Handle pressing of previous option in status bar menu
    */
    func prevPressed(sender: AnyObject)
    {
        for device in self.sonosDevices {
            device.previous({
                (response, error) -> Void
                in
                println(response)
                println(error)
            })
        }
    }
    
    /**
    Handle pressing of quit option in status bar menu
    */
    func quitPressed(sender: AnyObject)
    {
        println("Application Shutting Down...")
        NSApplication.sharedApplication().terminate(self)
    }

}

