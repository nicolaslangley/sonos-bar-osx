//
//  ViewController.swift
//  SonosController
//
//  Created by Nicolas Langley on 2/28/15.
//  Copyright (c) 2015 Nicolas Langley. All rights reserved.
//

import Cocoa
import AppKit

class DevicePopupViewController: NSViewController {
    
    // MARK: Global Variables
    // Global reference to view components
    var prevButton: NSButton!
    var nextButton: NSButton!
    var playbackButton: NSButton!
    var trackInfoLabel: NSTextField!
    var volumeSlider: NSSlider!
    
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
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 140))
        
        // Create the playback control buttons
        let playbackButton = NSButton()
        self.playbackButton = playbackButton
        playbackButton.title = "Play/Pause"
        playbackButton.target = self
        playbackButton.action = "playbackTogglePressed:"
        playbackButton.image = NSImage(named: "play-button")
        playbackButton.imagePosition = NSCellImagePosition.ImageOnly
        playbackButton.bordered = false
        playbackButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playbackButton)
        
        let nextButton = NSButton()
        self.nextButton = nextButton
        nextButton.title = "Next"
        nextButton.target = self
        nextButton.action = "nextPressed:"
        nextButton.image = NSImage(named: "next-button")
        nextButton.imagePosition = NSCellImagePosition.ImageOnly
        nextButton.bordered = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nextButton)
        
        let prevButton = NSButton()
        self.prevButton = prevButton
        prevButton.title = "Prev"
        prevButton.target = self
        prevButton.action = "prevPressed:"
        prevButton.image = NSImage(named: "prev-button")
        prevButton.imagePosition = NSCellImagePosition.ImageOnly
        prevButton.bordered = false
        prevButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(prevButton)
        
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
        
        // Create volume slider control
        let volumeSlider = NSSlider()
        self.volumeSlider = volumeSlider
        volumeSlider.target = self
        volumeSlider.action = "volumeChanged:"
        volumeSlider.maxValue = 100.0
        volumeSlider.minValue = 0.0
        volumeSlider.continuous = true
        volumeSlider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(volumeSlider)
        
        
        // Add constraints to the view
        // Horizontal
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-(30)-[prevButton(playbackButton)]-[playbackButton]-[nextButton(playbackButton)]-(30)-|",
            options: NSLayoutFormatOptions(0),
            metrics: nil,
            views: ["playbackButton":playbackButton, "prevButton":prevButton, "nextButton":nextButton]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-(20)-[trackInfoLabel]-(20)-|",
            options: NSLayoutFormatOptions(0),
            metrics: nil,
            views: ["trackInfoLabel":trackInfoLabel]))
        
        //Vertical
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-(20)-[trackInfoLabel(20)]-[playbackButton]-[volumeSlider(20)]-(20)-|",
            options: NSLayoutFormatOptions(0),
            metrics: nil,
            views: ["playbackButton":playbackButton, "trackInfoLabel":trackInfoLabel, "volumeSlider":volumeSlider]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-(20)-[trackInfoLabel(20)]-[prevButton]-[volumeSlider(20)]-(20)-|",
            options: NSLayoutFormatOptions(0),
            metrics: nil,
            views: ["prevButton":prevButton, "trackInfoLabel":trackInfoLabel, "volumeSlider":volumeSlider]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-(20)-[trackInfoLabel(20)]-[nextButton]-[volumeSlider(20)]-(20)-|",
            options: NSLayoutFormatOptions(0),
            metrics: nil,
            views: ["nextButton":nextButton, "trackInfoLabel":trackInfoLabel, "volumeSlider":volumeSlider]))
        
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
            "H:|-(25)-[volumeSlider]-[sonosAppButton(20.0)]-(5)-|",
            options: NSLayoutFormatOptions(0),
            metrics: nil,
            views: ["sonosAppButton":sonosAppButton, "volumeSlider":volumeSlider]))
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
        currentDevice!.playbackStatus({
            (playing, response, error)
            in
            if (error != nil) {
                println(error)
                // Check that device is still active
                let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.deviceSetup()
            } else {
                // Playback status was retrieved
                if (playing) {
                    // Set the correct title and icon
                    self.playbackButton.image = NSImage(named: "pause-button")
                    self.displayTrackInfo()
                } else {
                    // Set the correct title and icon
                    self.playbackButton.image = NSImage(named: "play-button")
                    self.trackInfoLabel.stringValue = "Nothing Playing"
                }
                // Sync volume slider
                self.setVolumeSlider()
            }
        })
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
            if (error != nil) {
                println(error)
            } else {
                self.trackInfoLabel.stringValue = "\(title) - \(artist)"
            }
        })
    }
    
    // MARK: Volume Functions

    /**
    Set volume slider position to sync with Sonos volume
    */
    func setVolumeSlider()
    {
        if (currentDevice == nil) {
            return
        }
        currentDevice!.getVolume({
            (volume, response, error) -> Void
            in
            if (error != nil) {
                println(error)
            } else {
                self.volumeSlider.integerValue = volume as Int
            }
        })
    }
    
    /**
    Update Sonos volume according to volume slider
    */
    func volumeChanged(sender: AnyObject)
    {
        if (currentDevice == nil) {
            return
        }
        let sliderVolumeValue = self.volumeSlider.integerValue
        currentDevice!.setVolume(sliderVolumeValue, completion: {
            (response, error)
            in
            if (error != nil) {
                println(error)
            } else {
                println(response)
            }
        })
        
    }
    
    // MARK: View Button Handlers
    
    /**
    Handle pressing of toggle playback in status bar menu
    */
    func playbackTogglePressed(sender: AnyObject)
    {
        if (currentDevice == nil) {
            return
        }
        currentDevice!.playbackStatus({
            (playing, response, error)
            in
            if (error != nil) {
                println(error)
            } else {
                // Playback status was retrieved
                if (playing) {
                    self.currentDevice!.pause({
                        (response, error) -> Void
                        in
                        if (error != nil) {
                            println(error)
                        } else {
                            println(response)
                            // Set the correct title and icon
                            self.playbackButton.image = NSImage(named: "play-button")
                            self.displayTrackInfo()
                        }
                    })
                } else {
                    self.currentDevice!.play(nil, completion: {
                        (response, error) -> Void
                        in
                        if (error != nil) {
                            println(error)
                        } else {
                            println(response)
                            // Set the correct title and icon
                            self.playbackButton.image = NSImage(named: "pause-button")
                            self.displayTrackInfo()
                        }
                    })
                }
            }
        })
    }
    
    /**
    Handle pressing of next option in status bar menu
    */
    func nextPressed(sender: AnyObject)
    {
        if (currentDevice == nil) {
            return
        }
        currentDevice!.next({
            (response, error) -> Void
            in
            if (error != nil) {
                println(error)
            } else {
                self.displayTrackInfo()
                println(response)
            }
        })
    }
    
    /**
    Handle pressing of previous option in status bar menu
    */
    func prevPressed(sender: AnyObject)
    {
        if (currentDevice == nil) {
            return
        }
        currentDevice!.previous({
            (response, error) -> Void
            in
            if (error != nil) {
                println(error)
            } else {
                self.displayTrackInfo()
            }
            println(response)
        })
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

