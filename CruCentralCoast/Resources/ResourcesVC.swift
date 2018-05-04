//
//  ResourcesViewController.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 3/28/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

@IBDesignable
class ResourcesVC: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    private var shadowImageView: UIImageView?
    var segmentedControlInNavBarView: SegmentedControlInNavBarView = UINib(nibName: "SegmentedControlInNavBarView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! SegmentedControlInNavBarView
    private var segmentedControlIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.insertProfileButtonInNavBar()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.registerCell(ResourcesTableViewCollectionViewCell.self)
        self.collectionView.register(UINib(nibName: "SegmentedControlInNavBarView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "SegmentedControlInNavBarView")
        self.segmentedControlInNavBarView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.shadowImageView == nil {
            self.shadowImageView = self.findShadowImage(under: self.navigationController!.navigationBar)
        }
        self.shadowImageView?.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.shadowImageView?.isHidden = false
    }
    
    private func findShadowImage(under view: UIView) -> UIImageView? {
        if view is UIImageView && view.bounds.size.height <= 1 {
            return (view as! UIImageView)
        }
        
        for subview in view.subviews {
            if let imageView = self.findShadowImage(under: subview) {
                return imageView
            }
        }
        return nil
    }
    
}

extension ResourcesVC: SegmentedControlInNavBarViewProtocol {
    func segmentedControlValueChanged(_ index: Int) {
        self.segmentedControlIndex = index
        self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .left, animated: true)
    }
    
}

extension ResourcesVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(ResourcesTableViewCollectionViewCell.self, indexPath: indexPath)
        
        switch self.segmentedControlIndex {
        case 0:
            cell.type = .articles
        case 1:
            cell.type = .videos
        case 2:
            cell.type = .audio
        default:
            break
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SegmentedControlInNavBarView", for: indexPath)
    }
}

extension ResourcesVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 100)
    }
    
}
