//
//  EventsCVC.swift
//  CruCentralCoast
//
//  Created by Cam Stocker on 4/4/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class EventsCVC: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.registerCell(EventCell.self)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(EventCell.self, indexPath: indexPath)
        cell.descriptionLabel.text = "Night at the Oscars"
        cell.dateLabel.text = "Mar 17, 2018"
        cell.imageView.image = #imageLiteral(resourceName: "night-at-the-oscars")
    
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let eventsVC = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "EventsDetailsVC")
        self.show(eventsVC, sender: nil)
    }
}
