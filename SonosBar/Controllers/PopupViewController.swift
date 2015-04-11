//
//  ViewController.swift
//  SonosController
//
//  Created by Nicolas Langley on 2/28/15.
//  Copyright (c) 2015 Nicolas Langley. All rights reserved.
//

import Cocoa

class PopupViewController: NSViewController {
    
    // Global reference to view components
    var prevButton: NSButton!
    var nextButton: NSButton!
    var playbackButton: NSButton!
    var trackInfoLabel: NSTextField!
    
    // Global reference to current device
    var currentDevice: SonosController!

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
            "H:|-(30)-[prevButton(playbackButton)]-[playbackButton]-[nextButton(playbackButton)]-(30)-|",
            options: NSLayoutFormatOptions(0),
            metrics: nil,
            views: ["playbackButton":playbackButton, "prevButton":prevButton, "nextButton":nextButton]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-(20)-[trackInfoLabel]-(20)-|",
            options: NSLayoutFormatOptions(0),
            metrics: nil,
            views: ["trackInfoLabel":trackInfoLabel]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-(20)-[trackInfoLabel]-[playbackButton]-(20)-|",
            options: NSLayoutFormatOptions(0),
            metrics: nil,
            views: ["playbackButton":playbackButton, "trackInfoLabel":trackInfoLabel]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-(20)-[trackInfoLabel]-[prevButton]-(20)-|",
            options: NSLayoutFormatOptions(0),
            metrics: nil,
            views: ["prevButton":prevButton, "trackInfoLabel":trackInfoLabel]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-(20)-[trackInfoLabel]-[nextButton]-(20)-|",
            options: NSLayoutFormatOptions(0),
            metrics: nil,
            views: ["nextButton":nextButton, "trackInfoLabel":trackInfoLabel]))
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the current device reference from the appdelegate
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        currentDevice = appDelegate.currentDevice
        
    }
    
    override func viewWillAppear() {
        // View has been load into memory and is about to be added to view hierarchy
        currentDevice.playbackStatus({
            (playing, response, error)
            in
            if (error != nil) {
                println(error)
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
            }
        })
    }
    
    // MARK: Handling of view buttons
    
    /**
    Update display of current track info*You
    */
    func displayTrackInfo()
    {
        currentDevice.trackInfo({
            (artist, title, album, albumArt, time, duration, queueIndex, trackURI, trackProtocol, error) -> Void
            in
            self.trackInfoLabel.stringValue = "\(title) - \(artist)"
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
            if (error != nil) {
                println(error)
            } else {
                // Playback status was retrieved
                if (playing) {
                    self.currentDevice.pause({
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
                    self.currentDevice.play(nil, completion: {
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
        currentDevice.next({
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
        currentDevice.previous({
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
    Handle pressing of quit option in status bar menu
    */
    func quitPressed(sender: AnyObject)
    {
        println("Application Shutting Down...")
        NSApplication.sharedApplication().terminate(self)
    }

    

}

