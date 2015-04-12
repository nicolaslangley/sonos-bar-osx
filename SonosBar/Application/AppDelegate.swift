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

    // MARK: Global Variables
    
    var statusBar = NSStatusBar.systemStatusBar()
    var statusBarItem: NSStatusItem? = nil
    var popover: NSPopover = NSPopover()
    var popoverTransiencyMonitor: AnyObject? = nil
    
    var sonosDevices: [SonosController] = []
    var currentDevice: SonosController? = nil
    
    // MARK: Interface Functions
    
    func applicationWillFinishLaunching(aNotification: NSNotification)
    {
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
                self.currentDevice = nil
                self.menuBarSetup()
            } else {
                for device in devices {
                    if ((device["name"] as! String) == "BRIDGE") {
                        // Ignore any BRIDGEs
                        continue
                    } else {
                        var controller: SonosController = SonosController.alloc()
                        controller.ip = device["ip"] as! String
                        controller.port = Int32((device["port"] as! String).toInt()!)
                        controller.name = device["name"] as! String
                        // Set the current playback device
                        controller.playbackStatus({
                            (playing, response, error)
                            in
                            if (error != nil) {
                                println(error)
                            } else {
                                if (playing) {
                                    println("Setting current device: \(controller.name)")
                                    self.currentDevice = controller
                                }
                                // Set up the menubar
                                self.menuBarSetup()
                            }
                        })
                        self.sonosDevices.append(controller)
                    }
                }
                if (self.currentDevice == nil) {
                    // Set the current device to be first in list
                    self.currentDevice = self.sonosDevices[0]
                    println("Setting current device: \(self.currentDevice!.name)")
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
        if (statusBarItem == nil) {
            statusBarItem = statusBar.statusItemWithLength(-1)
            statusBarItem!.image = NSImage(named: "sonos-icon-round")
            if let statusButton = statusBarItem!.button {
                statusButton.action = "handlePopover:"
            }
            // Create popup for info and controls
            popover = NSPopover()
            popover.behavior = NSPopoverBehavior.Transient
        }
        // Set view controller depending on if a device is found
        if (self.currentDevice == nil) {
            popover.contentViewController = NoDevicePopupViewController()
        } else {
            popover.contentViewController = DevicePopupViewController()
        }
    }
    
    // MARK: Popover Functions
    
    /**
    Handle opening/closing of popover on button press
    */
    func handlePopover(sender: AnyObject)
    {
        if let statusButton = statusBarItem!.button {
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
        if let statusButton = statusBarItem!.button {
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

