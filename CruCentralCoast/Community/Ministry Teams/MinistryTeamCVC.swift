//
//  MinistryTeamCVC.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 4/16/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

private let reuseIdentifier = "CommunityCell"

class MinistryTeamCVC: UICollectionViewController{
    
    //test data array
    var testDataArray: [MinistryCellParameters] = [MinistryCellParameters(teamTitle: "Software Dev Team", teamLeaders: ["Landon Gerrits", "Tyler Dahl"], teamDescription: "description... description... description... description... description... description... description... description... description... description... description... description... description... description... description... description... description... description... description... description... v v description... description... description... description... v description... description...v description... description... description... description... v description... description...vdescription... description...description... description...description... description...description... description...description... description...vdescription... description...vvdescription... description...description... description...cription... description... description... description... description... description... v v description... description... description... description... v description... description...v description... description... description... description... v description... description...vdescription... description...description... description...description... description...description... description...description... description...vdescription... description...vvdescripticription... description... description... description... description... description... v v description... description... description... description... v description... description...v description... description... description... description... v description... description...vdescription... description...description... description...description... description...description... description...description... description...vdescription... description...vvdescripticription... description... description... description... description... description... v v description... description... description... description... v description... description...v description... description... description... description... v description... description...vdescription... description...description... description...description... description...description... description...description... description...vdescription... description...vvdescripticription... description... description... description... description... description... v v description... description... description... description... v description... description...v description... description... description... description... v description... description...vdescription... description...description... description...description... description...description... description...description... description...vdescription... description...vvdescripticription... description... description... description... description... description... v v description... description... description... description... v description... description...v description... description... description... description... v description... description...vdescription... description...description... description...description... description...description... description...description... description...vdescription... description...vvdescripticription... description... description... description... description... description... v v description... description... description... description... v description... description...v description... description... description... description... v description... description...vdescription... description...description... description...description... description...description... description...description... description...vdescription... description...vvdescripti"), MinistryCellParameters(teamTitle: "Graphic Design Team", teamLeaders: ["Annamarie"], teamDescription: "description...")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let width = collectionView!.bounds.width - layout.sectionInset.left - layout.sectionInset.right
        layout.itemSize = CGSize(width: width, height: width * 0.55)
        self.collectionView?.registerCell(CommunityCell.self)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        
        print(testDataArray.count)
        return testDataArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(CommunityCell.self, indexPath: indexPath)
    
        // Configure the cell
        cell.bigLabel.text = testDataArray[indexPath.row].teamTitle
        cell.imageView.image = testDataArray[indexPath.row].teamImage
            //only returning first team name
        cell.smallLabel1.text = testDataArray[indexPath.row].teamLeaders[0]
        
    
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = UIStoryboard(name: "MinistryTeamDetails", bundle: nil).instantiateViewController(withIdentifier: "MinistryTeamDetailsVC") as? MinistryTeamDetailsVC else {
            assertionFailure("Probably used the wrong storyboard name or identifier here")
            return
        }
        
        vc.configure(with: self.testDataArray[indexPath.row])
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
