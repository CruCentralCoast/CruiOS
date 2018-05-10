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

    @IBOutlet weak var segmentedControlContainerView: UIView!
    var segmentedControlUpdateOnScrollDelegate: UpdateSegmentedControlDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.insertProfileButtonInNavBar()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.registerCell(ResourcesTableViewCollectionViewCell.self)
        self.segmentedControlContainerView.addSubview(self.segmentedControlInNavBarView)
        segmentedControlContainerView.bottomAnchor.constraint(equalTo: segmentedControlInNavBarView.bottomAnchor).isActive = true
        segmentedControlContainerView.rightAnchor.constraint(equalTo: segmentedControlInNavBarView.rightAnchor).isActive = true
        segmentedControlContainerView.leftAnchor.constraint(equalTo: segmentedControlInNavBarView.leftAnchor).isActive = true
        segmentedControlContainerView.topAnchor.constraint(equalTo: segmentedControlInNavBarView.topAnchor).isActive = true
        self.segmentedControlInNavBarView.delegate = self
        self.segmentedControlUpdateOnScrollDelegate = self.segmentedControlInNavBarView
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
        self.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .left, animated: true)
    }
    
}

extension ResourcesVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(ResourcesTableViewCollectionViewCell.self, indexPath: indexPath)
        switch indexPath.item {
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x/self.collectionView.frame.width)
        self.segmentedControlUpdateOnScrollDelegate?.setSegmentedControlValue(index)
    }
}

extension ResourcesVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}

protocol UpdateSegmentedControlDelegate {
    func setSegmentedControlValue(_ index: Int) -> Void
}
