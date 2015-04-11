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
    var popover: NSPopover = NSPopover()
    
    var sonosDevices: [SonosController] = []
    var currentDevice: SonosController = SonosController()
    
    // Initialization of application
    override init() {
        super.init()
        
        // Add statusBarItem to status bar
        statusBarItem = statusBar.statusItemWithLength(-1)

        statusBarItem.image = NSImage(named: "sonos-icon-round")
        if let statusButton = statusBarItem.button {
            statusButton.action = "handlePopover:"
        }
        
        // Create popup for info and controls
        popover = NSPopover()
        popover.behavior = NSPopoverBehavior.Transient
        popover.contentViewController = PopupViewController()
    }
    
    func applicationWillFinishLaunching(aNotification: NSNotification)
    {
        // Find the available Sonos devices
        SonosDiscover.discoverControllers {
            (devices, error) -> Void
            in
            if (devices == nil || error != nil) {
                println("No devices found")
                println(error)
            } else {
                for device in devices {
                    if ((device["name"] as! String) == "BRIDGE") {
                        // Ignore any BRIDGEs
                        continue
                    } else {
                        var controller: SonosController = SonosController.alloc()
                        controller.ip = device["ip"] as! String
                        controller.port = Int32((device["port"] as! String).toInt()!)
                        // Set the current playback device
                        controller.playbackStatus({
                            (playing, response, error)
                            in
                            if (error != nil) {
                                println(error)
                            } else {
                                if (playing) {
                                    let deviceName = device["name"]
                                    println("Setting current device: \(deviceName)")
                                    self.currentDevice = controller
                                }
                            }
                        })
                        self.sonosDevices.append(controller)
                    }
                }
            }
        }
    }
    
    /**
    Handle opening/closing of popover
    */
    func handlePopover(sender: AnyObject)
    {
        if let statusButton = statusBarItem.button {
            if popover.shown {
                popover.close()
            } else {
                popover.showRelativeToRect(NSZeroRect, ofView: statusButton, preferredEdge: NSMinYEdge)
            }
        }
    }
}

