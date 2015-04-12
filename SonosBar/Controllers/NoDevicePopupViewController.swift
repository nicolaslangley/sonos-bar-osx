//
//  NoDeviceViewController.swift
//  SonosBar
//
//  Created by Nicolas Langley on 4/11/15.
//  Copyright (c) 2015 Nicolas Langley. All rights reserved.
//

import Foundation

import Cocoa
import AppKit

class NoDevicePopupViewController: NSViewController {
    
    // MARK: Global Variables
    // Global reference to view components
    var prevButton: NSButton!
    var nextButton: NSButton!
    var playbackButton: NSButton!
    var trackInfoLabel: NSTextField!
    
    // Global reference to current device
    var currentDevice: SonosController? = nil
    var sonosDevices: [SonosController]?
    
    // MARK: Interface Functions
    
    override func loadView() {
        // Create the view
        view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(
            item: view, attribute: .Width, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 280))
        view.addConstraint(NSLayoutConstraint(
            item: view, attribute: .Height, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 120))
        
        // Create the playback control buttons
        let rescanButton = NSButton()
        rescanButton.title = "Rescan for Devices"
        rescanButton.target = self
        rescanButton.action = "rescanPressed:"
//        rescanButton.image = NSImage(named: "quit-button")
//        rescanButton.imagePosition = NSCellImagePosition.ImageOnly
        rescanButton.bordered = false
        rescanButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rescanButton)
        
        let quitButton = NSButton()
        quitButton.title = "Quit"
        quitButton.target = self
        quitButton.action = "quitPressed:"
        quitButton.image = NSImage(named: "quit-button")
        quitButton.imagePosition = NSCellImagePosition.ImageOnly
        quitButton.bordered = false
        quitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(quitButton)
        
        let sonosAppButton = NSButton()
        sonosAppButton.title = "Sonos App"
        sonosAppButton.target = self
        sonosAppButton.action = "sonosAppPressed:"
        sonosAppButton.image = NSImage(named: "sonos-app-button")
        sonosAppButton.imagePosition = NSCellImagePosition.ImageOnly
        sonosAppButton.bordered = false
        sonosAppButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sonosAppButton)
        
        
        // Create Label
        let trackInfoLabel = NSTextField()
        self.trackInfoLabel = trackInfoLabel
        trackInfoLabel.stringValue = "Track Info"
        trackInfoLabel.alignment = NSTextAlignment.CenterTextAlignment
        trackInfoLabel.editable = false
        trackInfoLabel.selectable = false
        trackInfoLabel.drawsBackground = false
        trackInfoLabel.bezeled = false
        trackInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackInfoLabel)
        
        
        // Add constraints to the view
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-(30)-[rescanButton]-(30)-|",
            options: NSLayoutFormatOptions(0),
            metrics: nil,
            views: ["rescanButton":rescanButton]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-(20)-[trackInfoLabel]-(20)-|",
            options: NSLayoutFormatOptions(0),
            metrics: nil,
            views: ["trackInfoLabel":trackInfoLabel]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-(20)-[trackInfoLabel]-[rescanButton]-(20)-|",
            options: NSLayoutFormatOptions(0),
            metrics: nil,
            views: ["rescanButton":rescanButton, "trackInfoLabel":trackInfoLabel]))
        // Quit button constraints
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:[quitButton(15.0)]-(5)-|",
            options: NSLayoutFormatOptions(0),
            metrics: nil,
            views: ["quitButton":quitButton]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-(5)-[quitButton(15.0)]",
            options: NSLayoutFormatOptions(0),
            metrics: nil,
            views: ["quitButton":quitButton]))
        // Sonos app button constraints
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:[sonosAppButton(20.0)]-(5)-|",
            options: NSLayoutFormatOptions(0),
            metrics: nil,
            views: ["sonosAppButton":sonosAppButton]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[sonosAppButton(20.0)]-(5)-|",
            options: NSLayoutFormatOptions(0),
            metrics: nil,
            views: ["sonosAppButton":sonosAppButton]))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get current device from appDelegate
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        currentDevice = appDelegate.currentDevice
        sonosDevices = appDelegate.sonosDevices
    }
    
    override func viewWillAppear() {
        // View has been load into memory and is about to be added to view hierarchy
        if (currentDevice == nil) {
            // There are no devices
            self.trackInfoLabel.stringValue = "No Devices Found"
            return
        }
    }
    
    // MARK: Display Functions
    
    /**
    Update display of current track info*You
    */
    func displayTrackInfo()
    {
        if (currentDevice == nil) {
            return
        }
        currentDevice!.trackInfo({
            (artist, title, album, albumArt, time, duration, queueIndex, trackURI, trackProtocol, error) -> Void
            in
            self.trackInfoLabel.stringValue = "\(title) - \(artist)"
        })
    }
    
    // MARK: View Button Handlers
    
    /**
    Handle pressing of rescan button
    */
    func rescanPressed(sender: AnyObject)
    {
        // Launch Sonos Controller app
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.deviceSetup()
        currentDevice = appDelegate.currentDevice
        if (currentDevice != nil) {
            println("Devices Found on Rescan")
        }
    }
    
    /**
    Handle pressing of sonos app button
    */
    func sonosAppPressed(sender: AnyObject)
    {
        // Launch Sonos Controller app
        NSWorkspace.sharedWorkspace().launchAppWithBundleIdentifier("com.sonos.macController",
            options: NSWorkspaceLaunchOptions.Default, additionalEventParamDescriptor: nil, launchIdentifier: nil)
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

