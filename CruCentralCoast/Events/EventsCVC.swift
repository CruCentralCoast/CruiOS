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
    var dataArray: [EventCellParameters] = [EventCellParameters(title: "Oasis", date: "March 17-26", location: "TBD", description: "ACM, the world's largest educational and scientific computing society, delivers resources that advance computing as a science and a profession. ACM provides the computing field's premier Digital Library and serves its members and the computing profession with leading-edge publications, conferences, and career resources."), EventCellParameters(title: "test2", date: "date", location: "location", description: "description"), EventCellParameters(title: "test3", date: "date", location: "location", description: "description"), EventCellParameters(title: "test4", date: "date", location: "location", description: "description"), EventCellParameters(title: "test5", date: "date", location: "location", description: "description")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.insertProfileButtonInNavBar()
        self.collectionView?.registerCell(EventCell.self)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(EventCell.self, indexPath: indexPath)
        
        //set the cells
        cell.dateLabel.text = dataArray[indexPath.item].date
        cell.titleLabel.text = dataArray[indexPath.item].title
        cell.imageView.image = #imageLiteral(resourceName: "night-at-the-oscars")
    
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

extension EventsCVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.bounds.width - 20.0
        return CGSize(width: width, height: width*0.55)
    }
}
