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
    var onboarding = false
    
    @IBOutlet var table: UITableView!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Campus Subscriptions"
        
        if self.navigationController != nil{
            self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.white]
        }
        
        CruClients.getServerClient().checkConnection(self.finishConnectionCheck)
        
        
        subbedMinistries = CruClients.getSubscriptionManager().loadMinistries()
        
        //setupSearchBar()
        self.tableView.reloadData()
        
    }
    // MARK: - Connection Check and Inserting Data
    func finishConnectionCheck(_ connected: Bool){
        if(!connected){
            hasConnection = false
            self.tableView.emptyDataSetDelegate = self
            self.tableView.emptyDataSetSource = self
            self.tableView.reloadData()
            //hasConnection = false
        }else{
            hasConnection = true
            CruClients.getServerClient().getData(.Campus, insert: insertCampus, completionHandler: {success in
                
                if (success){
                    self.loadedData = success
                }
                
                
                self.tableView.reloadData()
                
                //TODO: should be handling failure here
            })
        }
        
    }
    
    func refreshSubbedMinistries(){
        subbedMinistries = CruClients.getSubscriptionManager().loadMinistries()
    }
    
    func insertCampus(_ dict : NSDictionary) {
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
            self.tableView.insertRows(at: [IndexPath(item: 0, section: 0)], with: .automatic)
        }
        
        self.tableView.reloadData()
        self.tableView.endUpdates()
    }
    
    // MARK: - Empty Data Set Delegate functions
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        if !onboarding {
            if !hasConnection {
                return UIImage(named: Config.noConnectionImageName)
            }
        }
        return nil
    }
    
    //Set the text to be displayed when either table is empty
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        if onboarding {
            let attributes = [ NSFontAttributeName: UIFont(name: Config.fontName, size: 18)!, NSForegroundColorAttributeName: UIColor.black]
            return NSAttributedString(string: "No connection found. Please try again later.", attributes: attributes)
        }
        return nil
        
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        if(hasConnection == false){
            CruClients.getServerClient().getData(.Campus, insert: insertCampus, completionHandler: {success in

                
                // TODO: handle failure
                self.table.reloadData()
                CruClients.getServerClient().checkConnection(self.finishConnectionCheck)
            })
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.campuses.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "campusCell", for: indexPath)

            let thisCampus = campuses[campuses.index(campuses.startIndex, offsetBy: indexPath.row)]
            
            cell.textLabel?.text = thisCampus.name
            
            //display add-ons
            cell.textLabel?.font = UIFont(name: Config.fontName, size: 20)
            //cell.textLabel?.textColor = Config.introModalContentTextColor
            cell.textLabel?.textColor = UIColor.black
            
            if(thisCampus.feedEnabled == true){
                cell.accessoryType = .checkmark
            }
            else{
                cell.accessoryType = .none
            }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath){
            if(cell.accessoryType == .checkmark){
                let theCampus = campuses[campuses.index(campuses.startIndex, offsetBy: indexPath.row)]
                
                if(!willAffectMinistrySubscription(theCampus, indexPath: indexPath, cell: cell)){
                    cell.accessoryType = .none
                    theCampus.feedEnabled = false
                }
            }
            else{
                cell.accessoryType = .checkmark
                campuses[campuses.index(campuses.startIndex, offsetBy: indexPath.row)].feedEnabled = true
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
            //tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
        
        //TODO - Make is so this doesn't have to be called everytime didSelectRowAtIndexPath is called
        //saveCampusSet()
    }
    
    
    func willAffectMinistrySubscription(_ campus: Campus, indexPath: IndexPath, cell: UITableViewCell)->Bool{
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
            
            let index: String.Index = alertMessage.characters.index(alertMessage.startIndex, offsetBy: alertMessage.characters.count - 2)
            alertMessage = alertMessage.substring(to: index)
            
            let alert = UIAlertController(title: "Are you sure?", message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler:{ action in
                self.handleConfirmUnsubscribe(action, associatedMinistries: associatedMinistries, campus: campus, cell: cell)
            }))
            present(alert, animated: true, completion: nil)
            
            return true
        }
        else{
            return false
        }
    }
    
    //Saves the campuses
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
    
    
    
    func handleConfirmUnsubscribe(_ action: UIAlertAction, associatedMinistries: [Ministry], campus: Campus, cell: UITableViewCell){
        campus.feedEnabled = false
        cell.accessoryType = .none
        
        //Actually unsubscribes the user from the associated ministries
        //subbedMinistries = subbedMinistries.filter{ (minist) in !associatedMinistries.contains(minist)}
        for ministry in subbedMinistries{
            if(associatedMinistries.contains(ministry)){
                ministry.feedEnabled = false
                //print("disabled ministry feed for \(ministry.name)")
            }
        }
        
        //CruClients.getSubscriptionManager().saveMinistries(subbedMinistries, updateFCM: true)
        //saveCampusSet()
    }
    
    func setupSearchBar(){
        self.resultSearchController = UISearchController(searchResultsController: nil)
        self.resultSearchController.searchResultsUpdater = self
        self.resultSearchController.dimsBackgroundDuringPresentation = false
        self.resultSearchController.searchBar.sizeToFit()
        self.resultSearchController.hidesNavigationBarDuringPresentation = false
        self.tableView.tableHeaderView = self.resultSearchController.searchBar
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        self.filteredCampuses.removeAll(keepingCapacity: false)
        let query = searchController.searchBar.text!.lowercased()
        
        for campy in campuses{
            if(campy.name.lowercased().contains(query)){
                filteredCampuses.append(campy)
            }
        }
        
        if(query == ""){
            filteredCampuses = campusAsArray()
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: Actions
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        saveCampusSet()
        self.navigationController?.popViewController(animated: true)
    }
    /*@IBAction func saveToSettings(sender: UIBarButtonItem) {
        saveCampusSet()
        self.navigationController?.popViewControllerAnimated(true)
    }*/
    
    @IBAction func exitToSettings(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}
