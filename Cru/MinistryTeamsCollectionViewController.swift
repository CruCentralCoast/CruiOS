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

    var ministryTeamsStorageManager: MapLocalStorageManager<MinistryTeam>!
    var ministryTeams = [MinistryTeam]()
    var ministries = [Ministry]()
    var campusImage: UIImage!
    var sizingCell: MinistryTeamCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Ministry Teams"
        self.setupCollectionView()
        
        // Create fake cell used to calculate height for dynamically sizing collection view cells
        self.sizingCell = Bundle.main.loadNibNamed(MinistryTeamCell.className, owner: nil, options: nil)?.first as? MinistryTeamCell
        
        // Setup local storage manager
        self.ministryTeamsStorageManager = MapLocalStorageManager(key: Config.ministryTeamStorageKey)
        
        // Get ministries from local storage
        self.ministries = CruClients.getSubscriptionManager().loadMinistries()
        
        if !self.ministries.isEmpty {
            let ministryIds = ministries.map{$0.id}
            let params: [String:[String: [String]]] = ["parentMinistry":["$in":ministryIds as! Array<String>]]
            
            // Load ministry teams
            CruClients.getServerClient().getData(.MinistryTeam, insert: insertMinistryTeam, completionHandler: finishInserting, params: params)
        } else {
            print("NO MINISTRIES!!!")
        }
        
        self.campusImage = UIImage(named: Config.campusImage)!
    }
    
    private func setupCollectionView() {
        self.collectionView?.emptyDataSetSource = self
        self.collectionView?.emptyDataSetDelegate = self
        
        self.collectionView?.backgroundColor = .extraLightGray
        
        self.collectionView?.register(UINib(nibName: MinistryTeamCell.className, bundle: nil), forCellWithReuseIdentifier: MinistryTeamCell.cellReuseIdentifier)
    }
    
    // Insert individual ministry teams into the table view
    fileprivate func insertMinistryTeam(_ dict : NSDictionary) {
        let ministryTeam = MinistryTeam(dict: dict)!
        
        if ministryTeamsStorageManager.object(forKey: ministryTeam.id) == nil {
            self.ministryTeams.insert(ministryTeam, at: 0)
        }
    }
    
    // Reload the collection view data and store whether or not the user is in the repsective ministries
    fileprivate func finishInserting(_ success: Bool) {
        // TODO: handle failure
        
        for ministryTeam in ministryTeams {
            ministryTeam.parentMinistryName = ministries.filter{$0.id == ministryTeam.parentMinistry}.first!.name
        }
        
        ministryTeams.sort { $0 < $1 }
        
        self.collectionView?.reloadData()
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension MinistryTeamsCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ministryTeams.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 32
        if let cell = self.sizingCell {
            cell.ministryTeam = ministryTeams[indexPath.row]
            cell.layoutSubviews()
            let targetSize = CGSize(width: collectionView.frame.size.width - padding, height: 0)
            return cell.sizeThatFits(targetSize)
        }
        return CGSize(width: collectionView.frame.size.width - padding, height: 300)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let ministryTeam = ministryTeams[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MinistryTeamCell.cellReuseIdentifier, for: indexPath) as! MinistryTeamCell
        cell.ministryTeam = ministryTeam
        cell.delegate = self
        
        return cell
    }
}

// MARK: - MinistryTeamSignUpDelegate
extension MinistryTeamsCollectionViewController: MinistryTeamSignUpDelegate {
    func signUpForMinistryTeam(_ ministryTeam: MinistryTeam) {
        let signUpVC = UIStoryboard(name: "MinistryTeam", bundle: nil).instantiateViewController(withIdentifier: MinistryTeamSignUpViewController.className) as! MinistryTeamSignUpViewController
        signUpVC.ministryTeam = ministryTeam
        self.present(signUpVC, animated: true, completion: nil)
    }
}

// MARK: - DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
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
