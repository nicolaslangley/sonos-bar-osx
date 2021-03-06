//
//  AppDelegate.swift
//  SonosController
//
//  Created by Nicolas Langley on 2/28/15.
//  Copyright (c) 2015 Nicolas Langley. All rights reserved.
//

import Cocoa

@NSApplicationMain
public class AppDelegate: NSObject, NSApplicationDelegate {

    // MARK: Global Variables
    
    var statusBar = NSStatusBar.systemStatusBar()
    var statusBarItem: NSStatusItem? = nil
    var popover: NSPopover = NSPopover()
    var popoverTransiencyMonitor: AnyObject? = nil
    // Context for Key-Value Observer
    private var allDevicesContext: UInt8 = 1
    private var currentDeviceContext: UInt8 = 2
    
    var sonosManager: SonosManager? = nil
    var sonosDevices: [SonosController] = []
    var currentDevice: SonosController? = nil
    var sonosCoordinators: [SonosController] = []
    
    // MARK: Interface Functions
    
    public func applicationWillFinishLaunching(aNotification: NSNotification)
    {
        // Find the available Sonos devices
        sonosManager = SonosManager.sharedInstance() as? SonosManager
        sonosManager!.addObserver(self, forKeyPath: "allDevices", options: NSKeyValueObservingOptions.New, context: &allDevicesContext)
        sonosManager!.addObserver(self, forKeyPath: "currentDevice", options: NSKeyValueObservingOptions.New, context: &currentDeviceContext)
    }

    // MARK: Setup Functions
    
    /**
    Key-Value Observer for allDevices key
    */
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>)
    {
        if (context == &allDevicesContext)
        {
            sonosCoordinators.removeAll(keepCapacity: false)
            sonosCoordinators = sonosManager?.coordinators as! [SonosController]
            if (sonosCoordinators.isEmpty)
            {
                print("No devices found")
                // Set up the menubar
                self.currentDevice = nil
                self.menuBarSetup()
            }
            else
            {
                for coordinator in sonosCoordinators
                {
                    if (coordinator.name != "BRIDGE")
                    {
                        self.currentDevice = coordinator
                        print("Setting default device: \(currentDevice!.name)")
                        break
                    }
                }
            }
            
        }
        else if (context == &currentDeviceContext)
        {
            if (!(sonosManager?.currentDevice!.name == "BRIDGE"))
            {
                self.currentDevice = sonosManager?.currentDevice
                print("Setting current device: \(self.currentDevice!.name)")
                self.menuBarSetup()
            }
        }
    }
    
    /**
    Setup menubar status item
    */
    public func menuBarSetup()
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
        } else if let _ = popover.contentViewController as? NoDevicePopupViewController {
            popover.contentViewController = DevicePopupViewController()
        } else if (popover.contentViewController == nil) {
            popover.contentViewController = DevicePopupViewController()
        }
    }
    
    // MARK: Popover Functions
    
    /**
    Handle opening/closing of popover on button press
    */
    func handlePopover(sender: AnyObject)
    {
        if let _ = statusBarItem!.button {
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
            popoverTransiencyMonitor = NSEvent.addGlobalMonitorForEventsMatchingMask([NSEventMask.LeftMouseDownMask, NSEventMask.RightMouseDownMask],
                handler: {(event) -> Void
                    in
                    self.closePopover(sender)
            })
            popover.showRelativeToRect(NSZeroRect, ofView: statusButton, preferredEdge: NSRectEdge.MinY)
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

