//
//  ChooseMinistryVC.swift
//  Cru
//
//  Created by Max Crane on 5/18/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class ChooseMinistryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let ministries = CruClients.getSubscriptionManager().loadMinistries()
    var selectedMinistry: Ministry!
    
    override func viewDidLoad() {
        self.navigationItem.title = "Choose Ministry"
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ministries.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        
        cell?.textLabel!.text = ministries[indexPath.row].name
        cell?.textLabel?.font = UIFont(name: Config.fontName, size: 20.0)
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedMinistry = ministries[indexPath.row]
        self.performSegueWithIdentifier("showSurvey", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSurvey" {
            let surveyVC = segue.destinationViewController as! SurveyViewController
            surveyVC.setMinistry(selectedMinistry)
            
        }
    }
    
}
