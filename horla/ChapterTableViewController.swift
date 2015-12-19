//
//  ChapterTableViewController.swift
//  horla
//
//  Created by matt on 12/11/15.
//  Copyright © 2015 Proper Tea. All rights reserved.
//

import UIKit

class ChapterTableViewController: UITableViewController {
    
    var book = Book()



    
    override func viewDidLoad() {
        super.viewDidLoad()
        book.loadFromNamedTextFile("lehorla")
        tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return book.chapters.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChapterReuse", forIndexPath: indexPath) 
        
        // Configure the cell...
        //cell.label?.text = textBlocks[indexPath.row].joinedTextSpans
        cell.textLabel?.text = book.chapterTitle(indexPath.row)
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! TextViewController
        let row = tableView.indexPathForSelectedRow?.row
        vc.title = book.chapterTitle(row!)
        vc.chapter = book.chapters[row!]
    }
}
