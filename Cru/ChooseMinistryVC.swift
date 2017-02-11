//
//  ChooseMinistryVC.swift
//  Cru
//
//  Created by Max Crane on 5/18/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class ChooseMinistryVC: UIViewController, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    let ministries = CruClients.getSubscriptionManager().loadMinistries()
    var selectedMinistry: Ministry!
    var communityImage: UIImage!
    
    @IBOutlet weak var table: UITableView!
    override func viewDidLoad() {
        self.navigationItem.title = "Choose Ministry"
        //Set the empty set delegate and source
        self.table.emptyDataSetSource = self
        self.table.emptyDataSetDelegate = self
        self.table.separatorColor = UIColor.clear
        
        communityImage = UIImage(named: Config.communityImage)!
    }
    
    //Set the text to be displayed when the table is empty
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [ NSFontAttributeName: UIFont(name: Config.fontName, size: 18)!, NSForegroundColorAttributeName: UIColor.black]
        return NSAttributedString(string: "You are not subscribed to any ministries! Subscribe to a ministry to join one of its community groups.", attributes: attributes)
        
    }
    
    //Set the spacer
    func spaceHeight(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return 30.0
    }
    
    //Set the image displayed when the table is empty
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return communityImage
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ministries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        
        cell?.textLabel!.text = ministries[indexPath.row].name
        cell?.textLabel?.font = UIFont(name: Config.fontName, size: 20.0)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMinistry = ministries[indexPath.row]
        self.performSegue(withIdentifier: "showSurvey", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSurvey" {
            let surveyVC = segue.destination as! SurveyViewController
            surveyVC.setMinistry(selectedMinistry)
            
        }
    }
    
}
