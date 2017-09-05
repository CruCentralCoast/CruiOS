//
//  CommunityGroupsListTableViewController.swift
//  Cru
//
//  Created by Erica Solum on 7/2/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import MRProgress
import DZNEmptyDataSet

class CommunityGroupsListTableViewController: UITableViewController, DZNEmptyDataSetDelegate,DZNEmptyDataSetSource {
    
    // MARK: - Properties
    var groups = [CommunityGroup]()
    var joinedGroups: [CommunityGroup]!
    var filteredGroups = [CommunityGroup]()
    var hasConnection = true
    var answers = [[String:String]]()
    var ministries = [Ministry]()
    var ministryTable = [String: String]()
    var selectedGroup: CommunityGroup!
    var filterOptions = FilterCommunityGroupsTableViewController.FilterOptions(ministries: [], days: [], time: nil, grades: [], gender: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Community Groups"
        self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.white]
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        let filterButton = UIBarButtonItem(image: #imageLiteral(resourceName: "filter-icon-white"), style: .plain, target: self, action: #selector(self.showFilter))
        self.navigationItem.rightBarButtonItem = filterButton
        
        //Set the cells for automatic cell height
        tableView.rowHeight = UITableViewAutomaticDimension
        
        MRProgressOverlayView.showOverlayAdded(to: self.view, animated: true)
        
        //Load ministries
        createMinistryDictionary()
        
        //Check for connection then load events in the completion function
        CruClients.getServerClient().checkConnection(self.finishConnectionCheck)
        //loadCommunityGroups()

    }
    
    @objc func showFilter() {
        let filterVC = FilterCommunityGroupsTableViewController(options: self.filterOptions)
        filterVC.filterDelegate = self
        let modalNav = ModalNavigationController(rootViewController: filterVC)
        self.present(modalNav, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredGroups.count
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let group = self.filteredGroups[indexPath.row]
        
        if group.imgURL == "" {
            return 193
        } else {
            return 340.0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //TODO: Figure out way to create cells with different classes w/o repeating code
        let group = self.filteredGroups[indexPath.row]
        if group.imgURL != "" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as! CommunityGroupTableViewCell
            //cell.groupImage.load.request(with: group.imgURL)
            //Load image or get from cache
            let urlRequest = URLRequest(url: URL(string: group.imgURL)!)
            CruClients.getImageUtils().getImageDownloader().download(urlRequest) { response in
                if let image = response.result.value {
                    cell.groupImage.image = image
                }
            }
            cell.ministryLabel.text = group.parentMinistryName
            
            cell.typeLabel.text = group.getTypeString()
            cell.meetingTimeLabel.text = group.getMeetingTime()
            
            cell.leaderLabel.text = group.getLeaderString()
            
            //Add drop shadow
            cell.card.layer.shadowColor = UIColor.black.cgColor
            cell.card.layer.shadowOffset = CGSize(width: 0, height: 1)
            cell.card.layer.shadowOpacity = 0.25
            cell.card.layer.shadowRadius = 2
            
            cell.setSignupCallback(jumpBackToGetInvolved)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell2", for: indexPath) as! CommunityGroupNoImageCell
            cell.ministryLabel.text = group.parentMinistryName
            
            cell.typeLabel.text = group.getTypeString()
            cell.meetingTimeLabel.text = group.getMeetingTime()
            
            cell.leaderLabel.text = group.getLeaderString()
            
            //Add drop shadow
            cell.card.layer.shadowColor = UIColor.black.cgColor
            cell.card.layer.shadowOffset = CGSize(width: 0, height: 1)
            cell.card.layer.shadowOpacity = 0.25
            cell.card.layer.shadowRadius = 2
            
            cell.setSignupCallback(jumpBackToGetInvolved)
            return cell
        }
    }
    
    
    // MARK: - Helper Functions
    //Test to make sure there is a connection then load groups
    func finishConnectionCheck(_ connected: Bool){
        self.tableView!.emptyDataSetSource = self
        self.tableView!.emptyDataSetDelegate = self
        
        if(!connected){
            hasConnection = false
            //Display a message if either of the tables are empty
            
            self.tableView!.reloadData()
            MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
            //hasConnection = false
        }else{
            hasConnection = true
            //API call to load groups
            CruClients.getCommunityGroupUtils().loadGroups(insertGroup, completionHandler: finishInserting)
            
            
        }
        
    }
    
    //Get ministry list from local storage
    //Create a dictionary with ministry id & name for easy lookup
    fileprivate func createMinistryDictionary() {
        ministryTable = CruClients.getCommunityGroupUtils().getMinistryTable()
        
    }
    
    //helper function for inserting group data
    //func loadGroups(_ inserter: @escaping (NSDictionary)->Void, completionHandler: @escaping (Bool)->Void) {
        
    fileprivate func insertGroup(_ dict: NSDictionary) {
        //Create group and assign its parent ministry name
        let group = CommunityGroup(dict: dict)
        if let parentMin = ministryTable[group.parentMinistryID] {
            group.parentMinistryName = parentMin
        }
        
        //If group has already been joined or leader is listed as a member, skip it
        for joinedGroup in joinedGroups {
            if group.id == joinedGroup.id {
                return
            }
        }

            
        CruClients.getCommunityGroupUtils().loadLeaders({(dict) -> Void in
            let leader = CommunityGroupLeader(dict)
            if leader != nil {
                print("leader: " + leader.name)
                group.leaders.append(leader)
            }
        }, parentId: group.id, completionHandler: {(success) -> Void in
            self.groups.insert(group, at: 0)
            self.filteredGroups.insert(group, at: 0)
            self.tableView.reloadData()
            if success {
                print("Successfully loaded a leader!")
            }
            else {
                print("Nope, try loading the leader again.")
            }
        })
    }

    
    //helper function for finishing off inserting group data
    fileprivate func finishInserting(_ success: Bool) {
        //self.events.sort(by: {$0.startNSDate.compare($1.startNSDate as Date) == .orderedAscending})
        self.filteredGroups = self.groups.sorted()
        
       //Dismiss overlay here
        MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
        
        self.tableView.reloadData()
        
        /*for group in groups {
            CruClients.getCommunityGroupUtils().loadLeaders(insertLeader, parentId: group.id, completionHandler: finishInsertingLeaders)
        }*/
        
        
    }
    
    //Function to take user back to get involved once they've selected a group
    func jumpBackToGetInvolved() {
        for controller in (self.navigationController?.viewControllers)! {
            if controller.isKind(of: GetInvolvedViewController.self) {
                self.navigationController?.popToViewController(controller, animated: true)
            }
        }
    }
    
    // MARK: Empty Data Set Functions
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        if hasConnection == false {
            return UIImage(named: Config.noConnectionImageName)
        }
        else {
            return UIImage(named: "communityImage")
            
        }
        
    }
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        if hasConnection == false {
            return nil
        }
        else {
            let attributes = [ NSFontAttributeName: UIFont(name: Config.fontName, size: 18)!, NSForegroundColorAttributeName: UIColor.black]
            return NSAttributedString(string: "No community groups available! Try changing your subscribed ministries or campuses in Settings.", attributes: attributes)
        }
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        CruClients.getServerClient().checkConnection(self.finishConnectionCheck)
    }
    
    //opens sign up form for community group
    
    @IBAction func joinGroup(_ sender: UIButton) {
        if let cell = sender.superview?.superview?.superview as? UITableViewCell {
            let indexPath = tableView.indexPath(for: cell)
            let group = self.filteredGroups[indexPath!.row]
            self.selectedGroup = group
        }
        
        let storyboard = UIStoryboard(name: "communitygroups", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "submitDialog") as! SubmitInformationViewController
        controller.comGroup = selectedGroup
        
        self.present(controller, animated: true, completion: nil)
        
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "comGroupSignUp" {
            let vc = segue.destination as! SubmitInformationViewController
            vc.comGroup = self.selectedGroup
        }
    }
    

}

extension CommunityGroupsListTableViewController: FilterCommunityGroupsDelegate {
    func applyFilter(options: FilterCommunityGroupsTableViewController.FilterOptions) {
        self.filterOptions = options
        self.filteredGroups = self.groups.filter {
            (self.filterOptions.ministries.isEmpty || self.filterOptions.ministries.contains($0.parentMinistryName)) &&
            (self.filterOptions.days.isEmpty || self.filterOptions.days.contains($0.dayOfWeek)) &&
            // TODO: Filter by time once the CommunityGroup's time has been reformatted in the database.
            // Right now, the meetingTime is not consistent.
//            (self.filterOptions.time == nil || $0.meetingTime.isGreaterThanDate(self.filterOptions.time)) &&
            // TODO: Make the grade level naming convention consistent. Right now, we use Freshmen, Sophomore, etc.
            (self.filterOptions.grades.isEmpty || self.isGradeLevel($0.type, containedIn: self.filterOptions.grades)) &&
            (self.filterOptions.gender == nil || self.filterOptions.gender == $0.gender)
        }.sorted()
        self.tableView.reloadData()
    }
    
    private func isGradeLevel(_ grade: String, containedIn grades: [String]) -> Bool {
        switch grade.lowercased() {
        case "freshman", "freshmen":
            return grades.contains("Freshman")
        case "sophomore", "sophomores":
            return grades.contains("Sophomore")
        case "junior", "juniors":
            return grades.contains("Junior")
        case "senior", "seniors", "senior+", "seniors+":
            return grades.contains("Senior+")
        default:
            return true
        }
    }
}
