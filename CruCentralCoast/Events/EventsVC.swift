//
//  EventsTVC.swift
//  CruCentralCoast
//
//  Created by Cam Stocker on 7/1/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit
import RealmSwift

class EventsVC: UITableViewController {
    
    var dataArray: Results<Event>!
    var people: Results<Person>!
    var campuses: Results<Campus>!
    var movements: Results<Movement>!
    var communityGroups: Results<CommunityGroup>!
    var ministryTeams: Results<MinistryTeam>!
    var missions: Results<Mission>!
    var resources: Results<Resource>!
    
    var statusBarIsHidden: Bool = false {
        didSet{
            UIView.animate(withDuration: 0.25) { () -> Void in
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return statusBarIsHidden
        }
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.insertProfileButtonInNavBar()
        self.tableView.registerCell(EventsTableCell.self)
        
        DatabaseManager.instance.subscribeToDatabaseUpdates(self)
//        self.people = DatabaseManager.instance.getPeople()
//        self.campuses = DatabaseManager.instance.getCampuses()
//        self.movements = DatabaseManager.instance.getMovements()
        self.dataArray = DatabaseManager.instance.getEvents()
//        self.communityGroups = DatabaseManager.instance.getCommunityGroups()
//        self.ministryTeams = DatabaseManager.instance.getMinistryTeams()
//        self.missions = DatabaseManager.instance.getMissions()
//        self.resources = DatabaseManager.instance.getResources()

        self.tableView.setContentOffset(tableView.contentOffset, animated: false)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 140
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(EventsTableCell.self, indexPath: indexPath)
        cell.event = dataArray[indexPath.item]
        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(EventDetailsVC.self) as EventDetailsVC
        vc.configure(with: self.dataArray[indexPath.item])
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
}

extension EventsVC: DatabaseListenerProtocol {
    func updatedPeople() {
        print("People were updated - refreshing UI")
    }
    func updatedCampuses() {
        print("Campuses were updated - refreshing UI")
    }
    func updatedMovements() {
        print("Movements were updated - refreshing UI")
    }
    func updatedEvents() {
        print("Events were updated - refreshing UI")
//        for event in self.dataArray {
//            if let imageLink = event.imageLink {
//                UIImage.downloadedFrom(link: imageLink, completion: { (image) in
//                    event.image = image
//                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
//                    }
//                })
//            }
//        }
        self.tableView.reloadData()
    }
    func updatedCommunityGroups() {
        print("CommunityGroups were updated - refreshing UI")
    }
    func updatedMinistryTeams() {
        print("MinistryTeams were updated - refreshing UI")
    }
    func updatedMissions() {
        print("Missions were updated - refreshing UI")
    }
    func updatedResources() {
        print("Resources were updated - refreshing UI")
    }
}
