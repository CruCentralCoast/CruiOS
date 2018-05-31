//
//  MissionCVC.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 2/22/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

private let reuseIdentifier = "MissionCell"

class MissionCVC: UICollectionViewController {
    
    //test data array
    var dataArray: [MissionCellParameters] = [MissionCellParameters(titleLabel: "Oasis", date: "March 17-26", location: "TBD", description: "ACM, the world's largest educational and scientific computing society, delivers resources that advance computing as a science and a profession. ACM provides the computing field's premier Digital Library and serves its members and the computing profession with leading-edge publications, conferences, and career resources."), MissionCellParameters(titleLabel: "test2", date: "date2", location: "location2", description: "description..."), MissionCellParameters(titleLabel: "test3", date: "date3", location: "location3", description: "description..."), MissionCellParameters(titleLabel: "test4", date: "date4", location: "location4", description: "description..."), MissionCellParameters(titleLabel: "test5", date: "date5", location: "location5", description: "description...")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let width = collectionView!.bounds.width - layout.sectionInset.left - layout.sectionInset.right
        layout.itemSize = CGSize(width: width, height: width * 0.55)
        self.collectionView?.registerCell(CommunityCell.self)
        
    }
    
    
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return dataArray.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(CommunityCell.self, indexPath: indexPath)
        
        // Configure the cell
        cell.bigLabel.text = dataArray[indexPath.row].titleLabel
        cell.smallLabel1.text = dataArray[indexPath.row].date
        cell.imageView.image = #imageLiteral(resourceName: "placeholder.jpg")
        cell.smallLabel2.text = dataArray[indexPath.row].location
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = UIStoryboard(name: "MissionDetails", bundle: nil).instantiateViewController(withIdentifier: "MissionDetailsVC") as? MissionDetailsVC else {
            assertionFailure("Probably used the wrong storyboard name or identifier here")
            return
        }
        vc.configure(with: self.dataArray[indexPath.row])
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
    
}

