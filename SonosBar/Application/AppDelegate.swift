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
    var popoverTransiencyMonitor: AnyObject? = nil
    
    var sonosDevices: [SonosController] = []
    var currentDevice: SonosController?
    
    func applicationWillFinishLaunching(aNotification: NSNotification)
    {
        println("Application will finish launching started")
        // Find the available Sonos devices
        self.deviceSetup()
    }
    
    // MARK: Setup Functions
    
    /**
    Search for Sonos devices and perform setup
    */
    func deviceSetup()
    {
        println("Searching for Sonos devices")
        SonosDiscover.discoverControllers {
            (devices, error) -> Void
            in
            if (devices == nil) {
                println("No devices found")
                // Set up the menubar
                self.menuBarSetup()
                self.currentDevice = nil
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
                                // Set up the menubar
                                self.menuBarSetup()
                            }
                        })
                        self.sonosDevices.append(controller)
                    }
                }
            }
        }
    }
    
    /**
    Setup menubar status item
    */
    func menuBarSetup()
    {
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
    
    // MARK: Popover Functions
    
    /**
    Handle opening/closing of popover on button press
    */
    func handlePopover(sender: AnyObject)
    {
        if let statusButton = statusBarItem.button {
            if popover.shown {
                popover.close()
            } else {
                self.openPopover(sender)
            }
        }
    }
    
    /**
    Open popover and add transiency monitor
    */
    func openPopover(sender: AnyObject)
    {
        if let statusButton = statusBarItem.button {
            popoverTransiencyMonitor = NSEvent.addGlobalMonitorForEventsMatchingMask(NSEventMask.LeftMouseDownMask|NSEventMask.RightMouseDownMask,
                handler: {(event) -> Void
                    in
                    self.closePopover(sender)
            })
            popover.showRelativeToRect(NSZeroRect, ofView: statusButton, preferredEdge: NSMinYEdge)
        }
    }
    
    /**
    Closing of popover and remove transiency monitor
    */
    func closePopover(sender: AnyObject)
    {
        if (popoverTransiencyMonitor != nil) {
            NSEvent.removeMonitor(popoverTransiencyMonitor!)
            popoverTransiencyMonitor = nil
        }
        self.popover.close()
    }
}

