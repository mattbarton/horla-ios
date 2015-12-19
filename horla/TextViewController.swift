//
//  TextViewController.swift
//  horla
//
//  Created by matt on 12/11/15.
//  Copyright © 2015 Proper Tea. All rights reserved.
//

import UIKit
import AVFoundation

class TextViewController: UIViewController, AVAudioPlayerDelegate {

    enum PlayMode {
        case BothContinuous // read and listen, stop after each
        case Both // read and listen, stop after each
        case ListenFirst
        case LookFirst
    }
    
    enum PlayState {
        case Pre
        case Playing  // includes paused state
        case Post
    }
    
    var chapter = Chapter()
    
    var audioPlayer: AVAudioPlayer! = nil
    var currentLineNum = 0
    var timer: NSTimer?
    var timeSinceAppeared: NSTimeInterval = 0
    let timerInterval = 0.2
    
    var playMode = PlayMode.BothContinuous
    var playState = PlayState.Playing
    
    @IBOutlet weak var textLabel: UILabel!
    
    @IBOutlet weak var dashboardLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        updateTextLabels(currentLineNum)
        
        showLanguageLabels(languageSelector.selectedSegmentIndex)

        prepareAudioPlayer()
        audioPlayer.currentTime = chapter.marks[0]
        
        timer = NSTimer.scheduledTimerWithTimeInterval(timerInterval, target: self, selector: "timerFired:", userInfo: nil, repeats: true)
        timeSinceAppeared = 0
        
        playMode = .Both
        modeBarButton.title = "Normal"
        
        playState = .Playing
        playBarButton.title = "Play"
        
        updateDashboard(0)


    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        audioPlayer?.pause()
        audioPlayer = nil
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func prepareAudioPlayer() {
        print("prepareAudioPlayer()")
        if let soundPath = NSBundle.mainBundle().pathForResource("lehorla_nointro", ofType: "m4a") {
            let sound = NSURL(fileURLWithPath: soundPath)
            do {
                audioPlayer = try AVAudioPlayer(contentsOfURL: sound)
                audioPlayer.prepareToPlay()
                audioPlayer.delegate = self
                print("audioPlayer ready")
            } catch {
                print(error)
                
            }
        }
    }
    
    @IBOutlet weak var modeBarButton: UIBarButtonItem!
    @IBOutlet weak var transTextLabel: UILabel!
    
    @IBOutlet weak var languageSelector: UISegmentedControl!
    
    func showLanguageLabels(i: Int) {
        switch i {
        case 0:
            textLabelHeightConstraint.active = false
//            transTextLabelAboveConstraint.active = true
            transTextLabelHeightConstraint.active = true
        case 1:
            textLabelHeightConstraint.active = true
//            transTextLabelAboveConstraint.active = false
            transTextLabelHeightConstraint.active = false
        default:
            textLabelHeightConstraint.active = false
//            transTextLabelAboveConstraint.active = true
            transTextLabelHeightConstraint.active = false
            
        }
        view.setNeedsDisplay()
    }
    
    @IBAction func languageSelectAction(sender: UISegmentedControl) {
        showLanguageLabels(sender.selectedSegmentIndex)
    }
    
    @IBOutlet var textLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet var transTextLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet var transTextLabelAboveConstraint: NSLayoutConstraint!
    
    func updateTextLabels(lineNum: Int) {
        textLabel.text = chapter.lines[lineNum]
        transTextLabel.text = chapter.lines_trans[lineNum]
    }
    
    func timerFired(t: NSTimer) {
//        timeSinceAppeared += timerInterval
//        var curTime = timeSinceAppeared
        guard let ap = audioPlayer where ap.playing  else {
            return
        }
        let curTime = ap.currentTime
        let timeInt = Int(curTime)
        let lineNum = chapter.lineAtTime(curTime)
        if lineNum != currentLineNum {
            switch playMode {
            case .BothContinuous:
                currentLineNum = lineNum
                if currentLineNum >= chapter.lines.count {
                    if audioPlayer.playing {
                        audioPlayer.pause()
                        playBarButton.title = "Done"
                    }
                } else {
                    updateTextLabels(lineNum)
                }
            case .Both:
                if playState == .Playing {
                    playState = .Post
                    audioPlayer.pause()
                    playBarButton.title = "Continue"
                } else {
                    playState = .Playing
                    currentLineNum = lineNum
                    updateTextLabels(lineNum)
                }
            case .ListenFirst:
                if playState == .Playing {
                    playState = .Post
                    audioPlayer.pause()
                    playBarButton.title = "Continue"
                    hideTextLabels(false)
                } else {
                    playState = .Playing
                    currentLineNum = lineNum
                    hideTextLabels(true)
                    updateTextLabels(lineNum)
                }
            case .LookFirst:
                if playState == .Playing {
                    playState = .Post
                    audioPlayer.pause()
                    playBarButton.title = "Continue"
                } else if playState == .Post {
                    playState = .Pre
                    currentLineNum = lineNum
                    updateTextLabels(lineNum)
                    audioPlayer.pause()
                    playBarButton.title = "Listen"
                } else {
                    print("LookFirst and Pre??")
                }
            }
        } else {
            if playMode == .LookFirst && playState == .Pre {
                playState = .Playing
            }
        }
        updateDashboard(timeInt)
    }
    
    func updateDashboard(time: Int) {
        dashboardLabel.text = "Line \(currentLineNum) of \(chapter.lines.count) at \(time)s of \(Int(chapter.marks.last!))s"
    }
    
    func hideTextLabels(hide: Bool) {
        textLabel.hidden = hide
        transTextLabel.hidden = hide
    }
    @IBAction func rewindAction(sender: UIBarButtonItem) {
        if currentLineNum > 0 {
            moveTimeToLine(currentLineNum - 1)
        }
    }
    
    func moveTimeToLine(line: Int) {
        let newTime = chapter.marks[line]
        audioPlayer.currentTime = newTime
    }
    
    
    @IBAction func repeatAction(sender: UIBarButtonItem) {
        audioPlayer.currentTime = chapter.marks[currentLineNum]
//        audioPlayer.play()
    }
    
    @IBAction func ForwardAction(sender: UIBarButtonItem) {
        if currentLineNum < chapter.marks.count {
            moveTimeToLine(currentLineNum + 1)
        }
    }
    
    @IBAction func playOrPauseAction(sender: UIBarButtonItem) {
        guard let ap = audioPlayer else {
            print("audioPlayer is nil")
            return
        }
        if (ap.playing) {
            ap.pause()
            sender.title = "Play"
        } else {
            if currentLineNum < chapter.lines.count {
                ap.play()
                sender.title = "Pause"
            }
        }
    }

    @IBAction func changeModeAction(sender: UIBarButtonItem) {
        switch playMode {
        case .BothContinuous:
            playMode = .Both
            sender.title = "Normal"
        case .Both:
            playMode = .ListenFirst
            sender.title = "ListenFirst"
        case .ListenFirst:
            playMode = .LookFirst
            sender.title = "LookFirst"
        case .LookFirst:
            playMode = .BothContinuous
            sender.title = "Continuous"
        }
    }
    @IBOutlet weak var playBarButton: UIBarButtonItem!
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
