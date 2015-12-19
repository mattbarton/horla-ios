//
//  ReaderTableViewController.swift
//  horla
//
//  Created by matt on 12/5/15.
//  Copyright © 2015 Proper Tea. All rights reserved.
//

import UIKit
import AVFoundation

class TextBlock {
    var spanOffset = 0
    var textSpans: [String] = []
    func joinedAttributedTextSpans(highlightSpan: Int) -> NSMutableAttributedString {
        let result = NSMutableAttributedString()
        for (i, span) in textSpans.enumerate() {
            let isHighlighted = spanOffset + i == highlightSpan
            let attr = NSAttributedString(string: span, attributes: [NSForegroundColorAttributeName: isHighlighted ? UIColor.blueColor() : UIColor.blackColor()])
            result.appendAttributedString(attr)
        }
        return result // textSpans.joinWithSeparator("")
    }
    var joinedTextSpans: String {
        return textSpans.joinWithSeparator("")
    }
    
}

class ReaderTableViewController: UITableViewController, AVAudioPlayerDelegate {

    var textBlocks: [TextBlock] = []
    var audioPlayer: AVAudioPlayer! = nil
    var marks: [NSTimeInterval] = [2,4,6,8,10,12,14,16,18,20,22,24,26,28,30]
//    var marks: [NSTimeInterval] = [27.15,29.22,30.08,32.35,34.13,36,39.01,41.49,44.42,47.05,48.95,50.39,51.56,52.79,54.03]
    var currentSpanIndex = 0
    
    var timer: NSTimer?
    
    var timeSinceAppeared: NSTimeInterval = 0
    
    let timerInterval = 0.2
    
    var scrollSpeed = CGFloat(5)
    
    
    @IBAction func playOrPause(sender: UIBarButtonItem) {
        scrollSpeed += 5
        if (audioPlayer.playing) {
            audioPlayer.pause()
        } else {
            audioPlayer.play()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        if let path = NSBundle.mainBundle().pathForResource("out", ofType: "txt") {
            do {
                let data = try String(contentsOfFile: path)
                let myStrings = data.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
                var block = TextBlock()
                for string in myStrings[0..<200] {
                    if string == "PARAGRAPH BREAK." {
                        textBlocks.append(block)
                        let nextSpanOffset = block.spanOffset + block.textSpans.count
                        block = TextBlock()
                        block.spanOffset = nextSpanOffset
                    } else {
                        block.textSpans.append(string + " ")
                    }
                }
                if block.textSpans.count > 0 {
                    textBlocks.append(block)
                }
            } catch {
                print(error)
            }
        }
        
        if let soundPath = NSBundle.mainBundle().pathForResource("horla_extract", ofType: "mp3") {
            let sound = NSURL(fileURLWithPath: soundPath)
            do {
                audioPlayer = try AVAudioPlayer(contentsOfURL: sound)
                audioPlayer.prepareToPlay()
                audioPlayer.delegate = self
                //audioPlayer.play()
            } catch {
                print(error)
                
            }
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(timerInterval, target: self, selector: "timerFired:", userInfo: nil, repeats: true)
        timeSinceAppeared = 0
        
        tableView.reloadData()
        animateScroll()
    }
    
    func timeToSpan(time: NSTimeInterval) -> Int {
        for (i, mark) in marks.enumerate() {
            if mark > time {
                return i
            }
        }
        return marks.count
    }
    
    func timeToTextblock(time: NSTimeInterval) -> TextBlock {
        return textBlocks[timeToSpan(time)]
    }
    
    func animateScroll() {
        UIView.animateWithDuration(0.5, delay: 0, options: .Repeat,
            animations: {
                let height = self.tableView.contentSize.height
                let newPos = CGFloat(self.tableView.contentOffset.y + self.scrollSpeed)
                self.tableView.contentOffset.y = newPos
                print("\(newPos) \(height)")
            },
            completion:   { finished in
                print("animateScroll finished")
            }
        )
    }
    
    func timerFired(t: NSTimer) {
        timeSinceAppeared += timerInterval
        var curTime = timeSinceAppeared
        if let ap = audioPlayer where ap.playing {
            curTime = ap.currentTime
        }
        let timeInt = Int(curTime)
        //tableView.contentOffset.y = CGFloat(timeInt * 10)
//        UIView.animateWithDuration(timerInterval, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
//            self.tableView.contentOffset.y = CGFloat(timeInt * 10)
//            }, completion: nil)
        let span = timeToSpan(curTime)
        title = "\(span) \(timeInt)"
        if span != currentSpanIndex {
            currentSpanIndex = span
//            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: currentSpanIndex, inSection: 0), atScrollPosition: .Top, animated: true)
//            tableView.reloadData()
        }
        //            let textBlock = timeToTextblock(ap.currentTime)
        //            textBlock.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textBlocks.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("textBlockCell", forIndexPath: indexPath) as! TextBlockTableViewCell

        // Configure the cell...
        //cell.label?.text = textBlocks[indexPath.row].joinedTextSpans
        cell.label?.attributedText = textBlocks[indexPath.row].joinedAttributedTextSpans(currentSpanIndex)

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
