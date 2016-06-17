//
//  MinistryTeamsCollectionViewController.swift
//  Cru
//
//  Created by Deniz Tumer on 3/2/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class MinistryTeamsCollectionViewController: UICollectionViewController {

    var ministryTeams = [MinistryTeam]()
    var ministryTeamsStorageManager: MapLocalStorageManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup local storage manager
        ministryTeamsStorageManager = MapLocalStorageManager(key: Config.ministryTeamStorageKey)
        
        //load ministry teams
        CruClients.getServerClient().getData(.MinistryTeam, insert: insertMinistryTeam, completionHandler: finishInserting)

        //set background color of page and accelleration of cells
        collectionView!.backgroundColor = UIColor.blackColor()
        collectionView!.decelerationRate = UIScrollViewDecelerationRateFast
    }
    
    //inserts individual ministry teams into the collection view
    private func insertMinistryTeam(dict : NSDictionary) {
        self.ministryTeams.insert(MinistryTeam(dict: dict)!, atIndex: 0)
    }
    
    //reload the collection view data and store whether or not the user is in the repsective ministries
    private func finishInserting(success: Bool) {
        //TODO: handle failure
        self.collectionView!.reloadData()
    }

    // MARK: UICollectionViewDataSource
    //tells the collection view how many sections there are
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    //tells the collection view how many cells there are
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ministryTeams.count
    }

    //function for adding scrolling functionality for cells
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Config.ministryTeamReuseIdentifier, forIndexPath: indexPath)
        
        //let ministryTeam = ministryTeams[indexPath.item]
//        cell.ministryTeam = ministryTeam
//        cell.joinButton?.layer.setValue(indexPath.row, forKey: "index")
//        cell.joinButton?.addTarget(self, action: "joinMinistryTeam:", forControlEvents: UIControlEvents.TouchUpInside)
//        cell.ministryTeamImageView.load(cell.ministryTeam!.imageUrl)
        
        return cell
    }
    
    //target action on ministry
    func joinMinistryTeam(sender: UIButton) {
        let index = sender.layer.valueForKey("index") as! Int
        let ministry = ministryTeams[index]
        var user = ministryTeamsStorageManager.getObject(Config.userStorageKey)
        
        //if there is no user pass a fake user
        if user == nil {
            user = ["name": "Deniz Tumer", "phone": "1234567890"]
        }
        
        ministryTeamsStorageManager.addElement(ministry.id, elem: ministry.toDictionary())
        
        //showCompletionAlert()
    }
    
//    //alert box that shows a completion alert
//    func showCompletionAlert() {
//        let alert = UIAlertController(title: "Thank You!", message: "Thank you for signing up for this ministry team. You will be sent the leader's information shortly", preferredStyle: .Alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
//        self.presentViewController(alert, animated: true, completion: nil)
//    }
    
    //completion handler for ministry team response from the server after joining
    private func joinMinistryTeamCompletionHandler(ministryTeam: MinistryTeam, sender: UIButton) -> (NSArray? -> Void) {
        //add ministry team to local storage
//        var leaderInfo = "Leader(s) Info: "
        
        return { (response: NSArray?) in
//            if response != nil {
//                let leaders = response!
//                if leaders.count > 0 {
//                    let leader = leaders[0] as! NSDictionary
//                    let name = leader["name"] as! [String: String]
//                    let leaderName = name["first"]! + " " + name["last"]!
//                    let leaderPhone = leader["phone"] as! String
//                    leaderInfo += leaderName + ", " + leaderPhone
//                    //            for leader in response {
//                    //                print(leader)
//                    //            }
//                }
//                else {
//                    leaderInfo += "None"
//                }
//            } else {
//                //TODO: handle failure here
//            }
//            
//            self.ministryTeamsStorageManager.addElement(ministryTeam.id, elem: leaderInfo)
            self.performSegueWithIdentifier("unwindToMList", sender: self)
        }
    }
    
    //function for adding functionality for clicing of cells
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        let layout = collectionViewLayout as! UltravisualLayout
//        let offset = layout.dragOffset * CGFloat(indexPath.item)
//        if collectionView.contentOffset.y != offset {
//            collectionView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
//        }
    }
}
