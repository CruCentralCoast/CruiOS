//
//  EventsCVC.swift
//  CruCentralCoast
//
//  Created by Cam Stocker on 4/4/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class EventsCVC: UICollectionViewController {
    
    //some data for testing
    var dataArray = [Event]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.insertProfileButtonInNavBar()
        self.collectionView?.registerCell(EventCell.self)
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let width = collectionView!.bounds.width - layout.sectionInset.left - layout.sectionInset.right
        layout.itemSize = CGSize(width: width, height: width * 0.55)
        DatabaseManager.instance.getEvents { (events) in
            self.dataArray = events
            self.collectionView?.reloadData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(EventCell.self, indexPath: indexPath)
        cell.event = dataArray[indexPath.item]
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "EventDetailsVC") as? EventDetailsVC else {
            assertionFailure("Probably used the wrong storyboard name or identifier here")
            return
        }
        vc.configure(with: self.dataArray[indexPath.item])
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
}
