//
//  MissionCVC.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 2/22/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

private let reuseIdentifier = "MissionCell"

struct MissionCellParameters {
    let title : String
    let date : String
    let location : String
    let description : String
}


class MissionCVC: UICollectionViewController {
    
    //test data array
    var array : [MissionCellParameters] = [MissionCellParameters(title: "test", date: "dataaa", location: "blksDBVs", description: "kajsbfio")]
    
    var dataArray: [MissionCellParameters] = [MissionCellParameters(title: "test1", date: "date", location: "location", description: "description"), MissionCellParameters(title: "test2", date: "date", location: "location", description: "description"), MissionCellParameters(title: "test3", date: "date", location: "location", description: "description"), MissionCellParameters(title: "test4", date: "date", location: "location", description: "description"), MissionCellParameters(title: "test5", date: "date", location: "location", description: "description")]

    override func viewDidLoad() {
        super.viewDidLoad()
 
        self.collectionView?.registerCell(MissionCell.self)

    }
    


    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return dataArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(MissionCell.self, indexPath: indexPath)

        // Configure the cell
        cell.missionTitle.text = dataArray[indexPath.row].title
        cell.dateLabel.text = dataArray[indexPath.row].date
        cell.imageView.image = #imageLiteral(resourceName: "placeholder.jpg")
        cell.locationLabel.text = dataArray[indexPath.row].location

        return cell
    }
    
    //switch from Mission Collection View to Mission Detail
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "MissionDetails", bundle: nil).instantiateViewController(withIdentifier: "MissionDetailsVC") as! MissionDetailsVC
        
        
        
        self.navigationController?.present(vc, animated: true, completion: {
            vc.dateLabel.text = self.dataArray[indexPath.row].date
            vc.locationLabel.text = self.dataArray[indexPath.row].location
            vc.descriptionText.text = self.dataArray[indexPath.row].description
        })
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
