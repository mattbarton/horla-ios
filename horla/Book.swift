//
//  Created by matt on 12/6/15.
//  Copyright © 2015 Proper Tea. All rights reserved.
//

import Foundation

class Book {
    var marks: [Double] = []
    var text = ""
    var text_trans = ""  // translation
    var lines: [String] = []
    var lines_trans: [String] = []
    var chapters: [Chapter] = []
    
    func chapterTitle(index: Int) -> String {
        return chapters[index].title
    }
    
    func loadFromNamedTextFile(name: String) {
        let textFilePath = NSBundle.mainBundle().pathForResource(name + "_french", ofType: "txt")!
        let transFilePath = NSBundle.mainBundle().pathForResource(name + "_english", ofType: "txt")!
        let markFilePath = NSBundle.mainBundle().pathForResource(name + "_marks", ofType: "txt")!
        do {
            text = try String(contentsOfFile: textFilePath)
            lines = text.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())

            text_trans = try String(contentsOfFile: transFilePath)
            lines_trans = text_trans.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())

            let marksString = try String(contentsOfFile: markFilePath)
            marks = marksString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).componentsSeparatedByString(",").map { Double($0)! }
            
            print("Lines: \(lines.count) Marks: \(marks.count)")
            
            var chapter = Chapter()
            var markIndex = 0  // there are fewer marks than lines, since we have "PARAGRAPH BREAK" and other empty lines
            for i in 0..<lines.count {
                var line = lines[i]
                let trans = lines_trans[i]
                
                if line == "PARAGRAPH BREAK." || line == "" {
                    continue
                }
                
                if line.characters.first == "_" {  // e.g. "_8 mai_"
                    if chapter.lines.count > 0 {
                        chapters.append(chapter)
                    }
                    chapter = Chapter()
                    line = line.replace("_", withString: "")
                    chapter.title = line
                }
                chapter.lines.append(line)
                chapter.marks.append(marks[markIndex])
                markIndex++
                if markIndex >= marks.count {  // FIXME
                    markIndex = 0
                }
                chapter.lines_trans.append(trans)
            }
        } catch {
            print(error)
        }
    }
}

class Chapter {
    var title = ""
    var lines: [String] = []
    var marks: [Double] = []
    var lines_trans: [String] = []
    
    func lineAtTime(time: NSTimeInterval) -> Int {
        for (i, mark) in marks.enumerate() {
            if mark > time {
                return i
            }
        }
        return marks.count
    }
    
}


