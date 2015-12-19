//
//  ScrollingTextViewController.swift
//  horla
//
//  Created by matt on 12/6/15.
//  Copyright © 2015 Proper Tea. All rights reserved.
//

import UIKit

class ScrollingTextViewController: UIViewController {

    var text: String = ""
    var nsmas: NSMutableAttributedString!
    
    var spanStarts: [String.CharacterView.Index] = []
//    var spanLengths: [Int] = []
//    var spanEnds: [Int] = []
    
    var scrollSpeed = CGFloat(1.0)
    
    @IBOutlet weak var textView: UITextView!
    
    var autoScrollTimer: NSTimer?
    
    var currentTime = 0.0
    
    
    func autoScrollFired(timer: NSTimer) {
        let scrollPoint = CGPointMake(textView.contentOffset.x, textView.contentOffset.y + scrollSpeed)
//        print("\(scrollPoint)")
        textView.setContentOffset(scrollPoint, animated: false)
        
        currentTime += 35
        let newSpan = Int(currentTime / 2000)
        if newSpan != currentSpan {
            highlightSpan(newSpan)
        }
    }
    
    var currentSpan = 0
    func highlightSpan(span: Int) {
        nsmas.addAttributes([NSForegroundColorAttributeName: UIColor.grayColor()], range: NSMakeRange(currentSpan*25, 25))
        nsmas.removeAttribute(NSBackgroundColorAttributeName, range: NSMakeRange(currentSpan*25, 25))

        print("\(span)")
        nsmas.addAttributes([NSForegroundColorAttributeName: UIColor.blackColor(), NSBackgroundColorAttributeName: UIColor.yellowColor()], range: NSMakeRange(span*25, 25))
        currentSpan = span
        textView.attributedText = nsmas
        textView.setNeedsDisplay()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NSLog("Loading text")
        if let path = NSBundle.mainBundle().pathForResource("out", ofType: "txt") {
            do {
                var data = try String(contentsOfFile: path)
                data = data.replace(".--", withString: "—")
                
                text = ""
                spanStarts = []
                
                let myStrings = data.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
                for var string in myStrings[0..<200] {
                    if string == "PARAGRAPH BREAK." {
                        string = "\n\n"
                    } else {
                        string += " "
                    }
                    spanStarts.append(text.endIndex)
//                    spanLengths.append(string.endIndex)
                    text = text + string
                }

                nsmas = NSMutableAttributedString(string: text, attributes: [NSFontAttributeName: UIFont(name: "Georgia", size: 24.0)!, NSForegroundColorAttributeName: UIColor.grayColor()])
                highlightSpan(0)
                textView.attributedText = nsmas
                textView.setContentOffset(CGPointMake(0, 0), animated: false)
//                text = text.replace("\n", withString: " ")
//                    .replace("PARAGRAPH BREAK.", withString: "\n\n")
//                    .replace(".--", withString: "—")
//                textView.text = text
            } catch {
                print("\(error)")
            }
        }
        NSLog("Finished loading text")
        
        autoScrollTimer = NSTimer.scheduledTimerWithTimeInterval((35.0/1000.0), target: self, selector: "autoScrollFired:", userInfo: nil, repeats: true)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func playOrPauseAction(sender: UIBarButtonItem) {
        if scrollSpeed > CGFloat(0) {
            scrollSpeed = CGFloat(0)
        } else {
            scrollSpeed = CGFloat(1.0)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}