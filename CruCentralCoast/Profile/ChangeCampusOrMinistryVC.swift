//
//  ChangeCampusOrMinistryVC.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 4/26/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class ChangeCampusOrMinistryVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up collection view
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.registerCell(ChangeCampusOrMinistryCell.self)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension ChangeCampusOrMinistryVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 22
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(ChangeCampusOrMinistryCell.self, indexPath: indexPath)
        cell.campusImage.downloadedFrom(link: "https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/Calpolylogosports.png/614px-Calpolylogosports.png")
        cell.campusNameLabel.text = "Cal Poly SLO"
        return cell
    }
}

extension ChangeCampusOrMinistryVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ChangeCampusOrMinistryCell {
            cell.toggleCheckMark()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfCellsAcross: CGFloat = 3
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize(width: 10, height: 10)
        }
        let cellWidth: Int = Int((collectionView.frame.width - layout.sectionInset.left - layout.sectionInset.right - layout.minimumInteritemSpacing*(numberOfCellsAcross - 1))/numberOfCellsAcross)
        return CGSize(width: cellWidth, height: cellWidth)
    }
}
