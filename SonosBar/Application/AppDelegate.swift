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
    var infoMenuItem: NSMenuItem = NSMenuItem()
    var playbackMenuItem: NSMenuItem = NSMenuItem()
    var nextMenuItem: NSMenuItem = NSMenuItem()
    var prevMenuItem: NSMenuItem = NSMenuItem()
    var quitMenuItem: NSMenuItem = NSMenuItem()
    
    var sonosDevices: [SonosController] = []
    var currentDevice: SonosController = SonosController()
    
    // Initialization of application
    override init() {
        super.init()
        
        // Add statusBarItem to status bar
        statusBarItem = statusBar.statusItemWithLength(-1)
        statusBarItem.menu = menu
        statusBarItem.image = NSImage(named: "sonos-icon-round")
        
        // Add track info to menu
        infoMenuItem.title = "Track Info"
        menu.addItem(infoMenuItem)
        
        // Add playback toggle option to menu
        playbackMenuItem.title = "Play"
        playbackMenuItem.action = "playbackTogglePressed:"
        menu.addItem(playbackMenuItem)
        
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
                self.infoMenuItem.title = "No Devices Found"
            } else {
                for device in devices {
                    if ((device["name"] as! String) == "BRIDGE") {
                        // Ignore any BRIDGEs
                        continue
                    }
                    var controller: SonosController = SonosController.alloc()
                    controller.ip = device["ip"] as! String
                    controller.port = Int32((device["port"] as! String).toInt()!)
                    // Set the current playback device
                    controller.playbackStatus({
                        (playing, response, error)
                        in
                        if (playing) {
                            self.currentDevice = controller
                            self.playbackMenuItem.title = "Pause"
                            self.displayTrackInfo()
                        }
                    })
                    self.sonosDevices.append(controller)
                }
            }
        }
        
        // Setup timer to continually update currently playing track
        // Checks every 2 seconds
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.2,
                                                           target: self,
                                                           selector: "displayTrackInfo",
                                                           userInfo: nil,
                                                           repeats: true)
    }
    
    // MARK: Menu Choice Handling
    
    /**
    Update display of current track info*You
    */
    func displayTrackInfo()
    {
        currentDevice.trackInfo({
            (artist, title, album, albumArt, time, duration, queueIndex, trackURI, trackProtocol, error) -> Void
            in
            self.infoMenuItem.title = "\(title) - \(artist)"
        })
    }
    
    /**
    Handle pressing of toggle playback in status bar menu
    */
    func playbackTogglePressed(sender: AnyObject)
    {
        currentDevice.playbackStatus({
            (playing, response, error)
            in
            if (playing) {
                self.currentDevice.pause({
                    (response, error) -> Void
                    in
                    println(response)
                    println(error)
                })
                self.playbackMenuItem.title = "Play"
                self.displayTrackInfo()
            } else {
                self.currentDevice.play(nil, completion: {
                    (response, error) -> Void
                    in
                    println(response)
                    println(error)
                })
                self.playbackMenuItem.title = "Pause"
                self.displayTrackInfo()
            }
        })
    }
    
    /**
    Handle pressing of next option in status bar menu
    */
    func nextPressed(sender: AnyObject)
    {
        currentDevice.next({
            (response, error) -> Void
            in
            println(response)
            println(error)
            self.displayTrackInfo()
        })
    }
    
    /**
    Handle pressing of previous option in status bar menu
    */
    func prevPressed(sender: AnyObject)
    {
        currentDevice.previous({
            (response, error) -> Void
            in
            println(response)
            println(error)
            self.displayTrackInfo()
        })
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

