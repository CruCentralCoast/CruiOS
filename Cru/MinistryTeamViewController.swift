//
//  MinistryTeamViewController.swift
//  Cru
//
//  Created by Deniz Tumer on 4/21/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class MinistryTeamViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var ministryTeams = [MinistryTeam]()
    var ministryTeamsStorageManager: MapLocalStorageManager<MinistryTeam>!
    var refreshControl: UIRefreshControl!
    var sizingCell: MinistryTeamCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create fake cell used to calculate height for dynamically sizing collection view cells
        self.sizingCell = Bundle.main.loadNibNamed(MinistryTeamCell.className, owner: nil, options: nil)?.first as? MinistryTeamCell
        
        // Configure UICollectionView
        self.collectionView.register(UINib(nibName: MinistryTeamCell.className, bundle: nil), forCellWithReuseIdentifier: MinistryTeamCell.cellReuseIdentifier)
        
        // Setup local storage manager
        self.ministryTeamsStorageManager = MapLocalStorageManager(key: Config.ministryTeamStorageKey)
        
        populateJoinedMinistryTeams()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: #selector(MinistryTeamViewController.refresh(_:)), for: UIControlEvents.valueChanged)
        self.collectionView.refreshControl = self.refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refresh(self)
    }
    
    func refresh(_ sender: AnyObject) {
        self.ministryTeams.removeAll()
        populateJoinedMinistryTeams()
        endRefreshing()
    }
    
    func endRefreshing() {
        if let refresh = self.refreshControl {
            self.collectionView.reloadData()
            refresh.endRefreshing()
        }
    }
    
    func populateJoinedMinistryTeams() {
        for joinedTeamId in self.ministryTeamsStorageManager.keys {
//            var ministryTeam = [String:String]()
//            ministryTeam["id"] = joinedTeamId
//            ministryTeam["name"] = (self.ministryTeamsStorageManager.getElement(joinedTeamId) as! String)
//            self.ministryTeams.append(ministryTeam as NSDictionary)
            
            let ministryTeam = self.ministryTeamsStorageManager.object(forKey: joinedTeamId) as! MinistryTeam
            self.ministryTeams.append(ministryTeam)
        }
    }
    
    @IBAction func showMinistryTeams() {
        let vc = MinistryTeamsCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UICollectionView Methods
extension MinistryTeamViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.collectionView.backgroundColor = (self.ministryTeams.count == 0) ? .white : .extraLightGray
        return self.ministryTeams.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 32
        if let cell = self.sizingCell {
            cell.ministryTeam = self.ministryTeams[indexPath.row]
            cell.layoutSubviews()
            let targetSize = CGSize(width: collectionView.frame.size.width - padding, height: 0)
            return cell.sizeThatFits(targetSize)
        }
        return CGSize(width: collectionView.frame.size.width - padding, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MinistryTeamCell.cellReuseIdentifier, for: indexPath) as! MinistryTeamCell
        cell.ministryTeam = self.ministryTeams[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let ministryTeam = self.ministryTeams[indexPath.item]
        
        let ministryTeamDetailVC = self.storyboard!.instantiateViewController(withIdentifier: "MinistryTeamDetailViewController") as! MinistryTeamDetailViewController
//        ministryTeamDetailVC.ministryTeamDict = ministryTeam
        ministryTeamDetailVC.ministryTeam = ministryTeam
        ministryTeamDetailVC.listVC = self
        
        self.navigationController?.pushViewController(ministryTeamDetailVC, animated: true)
    }
}
