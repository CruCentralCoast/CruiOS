//
//  SearchableOptionsVC.swift
//  Cru
//
//  Created by Max Crane on 5/17/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class SearchableOptionsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var options: [String]!
    var optionHandler: ((String)->())!
    
    override func viewDidLoad() {
        print("lol")
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        cell?.textLabel!.text = options[indexPath.row]
        //print(cgQuestion.options[indexPath.row])
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        optionHandler((cell.textLabel?.text!)!)
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
}
