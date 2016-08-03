//
//  CampusesTableViewController.swift
//  Cru
//
//  Created by Max Crane on 11/25/15.
//  Copyright © 2015 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import DZNEmptyDataSet


class CampusesTableViewController: UITableViewController, UISearchResultsUpdating, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource   {
    var campuses = Set<Campus>()
    var subbedMinistries = [Ministry]()
    
    var filteredCampuses = [Campus]()
    var resultSearchController: UISearchController!
    var emptyTableImage: UIImage!
    var hasConnection = true
    var loadedData = false
    @IBOutlet var table: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Campus Subscriptions"
        
        if self.navigationController != nil{
            self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        }
        
        
        
        
        CruClients.getServerClient().getData(.Campus, insert: insertCampus, completionHandler: {success in
            
            if (success){
                self.loadedData = success
            }

            
            self.tableView.reloadData()
            CruClients.getServerClient().checkConnection(self.finishConnectionCheck)
            //TODO: should be handling failure here
        })
        subbedMinistries = CruClients.getSubscriptionManager().loadMinistries()
        
        //setupSearchBar()
        self.tableView.reloadData()
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return emptyTableImage
    }
    
    func emptyDataSet(scrollView: UIScrollView!, didTapView view: UIView!) {
        if(hasConnection == false){
            CruClients.getServerClient().getData(.Campus, insert: insertCampus, completionHandler: {success in

                
                // TODO: handle failure
                self.table.reloadData()
                CruClients.getServerClient().checkConnection(self.finishConnectionCheck)
            })
        }
    }
    
    func finishConnectionCheck(connected: Bool){
        if(!connected){
            hasConnection = false
            self.emptyTableImage = UIImage(named: Config.noConnectionImageName)
            self.table.emptyDataSetDelegate = self
            self.table.emptyDataSetSource = self
            self.tableView.reloadData()
            //hasConnection = false
        }else{
            hasConnection = true
        }
        
    }
    
    func refreshSubbedMinistries(){
        subbedMinistries = CruClients.getSubscriptionManager().loadMinistries()
    }
    
    
    
    func insertCampus(dict : NSDictionary) {
        self.tableView.beginUpdates()
        
        let campusName = dict["name"] as! String
        let campusId = dict["_id"] as! String
        
        let curCamp = Campus(name: campusName, id: campusId)
        let enabledCampuses = CruClients.getSubscriptionManager().loadCampuses()
        if(enabledCampuses.contains(curCamp)){
            curCamp.feedEnabled = true
        }
        let preCount = campuses.count
        campuses.insert(curCamp)
        let countChanged = preCount != campuses.count
        
        //campuses.insert(curCamp, atIndex: 0)
        //campuses.sortInPlace()
        if(countChanged){
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)], withRowAnimation: .Automatic)
        }
        
        self.tableView.reloadData()
        self.tableView.endUpdates()
    }
    
    override func viewWillDisappear(animated: Bool) {
        var temp = [Campus]()
        for camp in campuses{
            temp.append(camp)
        }
        
        CruClients.getSubscriptionManager().saveCampuses(temp)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if (self.resultSearchController != nil && self.resultSearchController.active){
//            return self.filteredCampuses.count
//        }
//        else{
            return self.campuses.count
        //}
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("campusCell", forIndexPath: indexPath)

            let thisCampus = campuses[campuses.startIndex.advancedBy(indexPath.row)]
            
            cell.textLabel?.text = thisCampus.name
            
            //display add-ons
            cell.textLabel?.font = UIFont(name: Config.fontName, size: 20)
            //cell.textLabel?.textColor = Config.introModalContentTextColor
            cell.textLabel?.textColor = UIColor.blackColor()
            
            if(thisCampus.feedEnabled == true){
                cell.accessoryType = .Checkmark
            }
            else{
                cell.accessoryType = .None
            }
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath){
            if(cell.accessoryType == .Checkmark){
                let theCampus = campuses[campuses.startIndex.advancedBy(indexPath.row)]
                
                if(!willAffectMinistrySubscription(theCampus, indexPath: indexPath, cell: cell)){
                    cell.accessoryType = .None
                    theCampus.feedEnabled = false
                }
            }
            else{
                cell.accessoryType = .Checkmark
                campuses[campuses.startIndex.advancedBy(indexPath.row)].feedEnabled = true
            }
            
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            //tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        
        //TODO - Make is so this doesn't have to be called everytime didSelectRowAtIndexPath is called
        saveCampusSet()
    }
    
    
    func willAffectMinistrySubscription(campus: Campus, indexPath: NSIndexPath, cell: UITableViewCell)->Bool{
        var associatedMinistries = [Ministry]()
        
        for ministry in subbedMinistries{
            if(CruClients.getSubscriptionManager().campusContainsMinistry(campus, ministry: ministry)){
                associatedMinistries.append(ministry)
            }
        }
        
        if(associatedMinistries.isEmpty == false){
            var alertMessage = "Unsubscribing from " + campus.name + " will also unsubscribe you from the following ministries: "
            
            for ministry in associatedMinistries{
                alertMessage += ministry.name + ", "
            }
            
            let index: String.Index = alertMessage.startIndex.advancedBy(alertMessage.characters.count - 2)
            alertMessage = alertMessage.substringToIndex(index)
            
            let alert = UIAlertController(title: "Are you sure?", message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Confirm", style: .Destructive, handler:{ action in
                self.handleConfirmUnsubscribe(action, associatedMinistries: associatedMinistries, campus: campus, cell: cell)
            }))
            presentViewController(alert, animated: true, completion: nil)
            
            return true
        }
        else{
            return false
        }
    }
    
    func saveCampusSet(){
        CruClients.getSubscriptionManager().saveCampuses(campusAsArray())
    }
    
    
    func campusAsArray() -> [Campus]{
        var temp = [Campus]()
        
        for camp in campuses{
            temp.append(camp)
        }
        
        return temp
    }
    
    
    
    func handleConfirmUnsubscribe(action: UIAlertAction, associatedMinistries: [Ministry], campus: Campus, cell: UITableViewCell){
        campus.feedEnabled = false
        cell.accessoryType = .None
        
        //Actually unsubscribes the user from the associated ministries
        //subbedMinistries = subbedMinistries.filter{ (minist) in !associatedMinistries.contains(minist)}
        for ministry in subbedMinistries{
            if(associatedMinistries.contains(ministry)){
                ministry.feedEnabled = false
                //print("disabled ministry feed for \(ministry.name)")
            }
        }
        
        CruClients.getSubscriptionManager().saveMinistries(subbedMinistries, updateGCM: true)
        saveCampusSet()
    }
    
    func setupSearchBar(){
        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController.searchResultsUpdater = self
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.resultSearchController.searchBar.sizeToFit()
        self.resultSearchController.hidesNavigationBarDuringPresentation = false
        self.tableView.tableHeaderView = self.resultSearchController.searchBar
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.filteredCampuses.removeAll(keepCapacity: false)
        let query = searchController.searchBar.text!.lowercaseString
        
        for campy in campuses{
            if(campy.name.lowercaseString.containsString(query)){
                filteredCampuses.append(campy)
            }
        }
        
        if(query == ""){
            filteredCampuses = campusAsArray()
        }
        
        self.tableView.reloadData()
    }
}
