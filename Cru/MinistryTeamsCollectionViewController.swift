//
//  MinistryTeamsCollectionViewController.swift
//  Cru
//
//  Created by Deniz Tumer on 3/2/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

class MinistryTeamsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var ministryTeamsStorageManager: MapLocalStorageManager!
    var ministryTeams = [MinistryTeam]()
    var ministries = [Ministry]()
    var signedUpMinistryTeams = [NSDictionary]()
    var selectedMinistryTeam: MinistryTeam!
    var campusImage: UIImage!
    fileprivate let reuseIdentifierPic = "ministryTeamCell"
    fileprivate let reuseIdentifierNoPic = "ministryTeamNoPicCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupCollectionView()
        
        //setup local storage manager
        ministryTeamsStorageManager = MapLocalStorageManager(key: Config.ministryTeamStorageKey)
        
        self.ministries = CruClients.getSubscriptionManager().loadMinistries()
        
        if !self.ministries.isEmpty {
            let ministryIds = ministries.map{$0.id}
            let params: [String:[String: [String]]] = ["parentMinistry":["$in":ministryIds as! Array<String>]]
            
            //load ministry teams
            CruClients.getServerClient().getData(.MinistryTeam, insert: insertMinistryTeam, completionHandler: finishInserting, params: params)
        }
        else {
            print("NO MINISTRIES!!!")
        }
        
        campusImage = UIImage(named: Config.campusImage)!
    }
    
    func setupCollectionView() {
        self.collectionView?.emptyDataSetSource = self
        self.collectionView?.emptyDataSetDelegate = self
        
        self.collectionView?.backgroundColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1)
        
        self.collectionView?.register(UINib(nibName: MinistryTeamCell.className, bundle: nil), forCellWithReuseIdentifier: MinistryTeamCell.cellReuseIdentifier)
    }
    
    //inserts individual ministry teams into the table view
    fileprivate func insertMinistryTeam(_ dict : NSDictionary) {
        let addMinistryTeam = MinistryTeam(dict: dict)!
        
        if ministryTeamsStorageManager.getElement(addMinistryTeam.id) == nil {
            self.ministryTeams.insert(addMinistryTeam, at: 0)
        }
    }
    
    //reload the collection view data and store whether or not the user is in the repsective ministries
    fileprivate func finishInserting(_ success: Bool) {
        //TODO: handle failure
        
        for minTeam in ministryTeams {
            minTeam.parentMinName = ministries.filter{$0.id == minTeam.parentMinistry}.first!.name
        }
        
        ministryTeams.sort()
        
        self.collectionView?.reloadData()
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension MinistryTeamsCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ministryTeams.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let cell = Bundle.main.loadNibNamed(MinistryTeamCell.className, owner: nil, options: nil)?.first as? MinistryTeamCell {
            cell.ministryTeam = ministryTeams[indexPath.row]
            cell.layoutSubviews()
            print(cell.intrinsicContentSize.height)
            print(cell.systemLayoutSizeFitting(CGSize(width: 300, height: 0)))
            return cell.systemLayoutSizeFitting(CGSize(width: 300, height: 0))
        }
//        if let cell = collectionView.cellForItem(at: indexPath) as? MinistryTeamCell {
//            return CGSize(width: 350, height: cell.intrinsicContentSize.height)
//        }
        return CGSize(width: 300, height: 200)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let ministryTeam = ministryTeams[indexPath.row]
        let ministry = ministries.filter{$0.id == ministryTeam.parentMinistry}.first
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MinistryTeamCell.cellReuseIdentifier, for: indexPath) as! MinistryTeamCell
        cell.ministryTeam = ministryTeam
        cell.ministryNameLabel.text = (ministry != nil) ? ministry!.name : "N/A"
        cell.delegate = self
        
        return cell
    }
}

extension MinistryTeamsCollectionViewController: MinistryTeamSignUpDelegate {
    func signUpForMinistryTeam(_ ministryTeam: MinistryTeam) {
        let signUpVC = UIStoryboard(name: "minstryteam", bundle: nil).instantiateViewController(withIdentifier: "MinistryTeamSignUpViewController") as! MinistryTeamSignUpViewController
        signUpVC.ministryTeam = ministryTeam
        self.navigationController?.pushViewController(signUpVC, animated: true)
    }
}

extension MinistryTeamsCollectionViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [ NSFontAttributeName: UIFont(name: Config.fontName, size: 18)!, NSForegroundColorAttributeName: UIColor.black]
        return NSAttributedString(string: "No ministry teams available! Try changing your subscribed campuses.", attributes: attributes)
    }
    
    func spaceHeight(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return 30.0
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return campusImage
    }
    
    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return UIColor.white
    }
}
