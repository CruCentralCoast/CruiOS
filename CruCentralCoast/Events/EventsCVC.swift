//
//  EventsCVC.swift
//  CruCentralCoast
//
//  Created by Cam Stocker on 4/4/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class EventsCVC: UICollectionViewController {
    var selectedCell: UIView?
    var originFrame: CGRect?
    
    //some data for testing
    var dataArray = [Event]()
    
    var statusBarIsHidden: Bool = false {
        didSet{
            UIView.animate(withDuration: 0.25) { () -> Void in
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        get {
            return statusBarIsHidden
        }
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.insertProfileButtonInNavBar()
        self.collectionView?.registerCell(EventCell.self)
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let width = collectionView!.bounds.width - layout.sectionInset.left - layout.sectionInset.right
        layout.itemSize = CGSize(width: width, height: width * 0.55)
        DatabaseManager.instance.getEvents { (events) in
            self.dataArray = events
            for event in self.dataArray {
                UIImage.downloadedFrom(link: event.imageLink, completion: { (image) in
                    event.image = image
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                })
            }
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
        vc.transitioningDelegate = self
        self.selectedCell = collectionView.cellForItem(at: indexPath)
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
}

extension EventsCVC: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let selectedCell = self.selectedCell else {
            return nil
        }
        guard let relativeFrame = selectedCell.superview?.convert((selectedCell.frame), to: nil) else {
            return nil
        }
        self.statusBarIsHidden = true
        self.originFrame = relativeFrame;
        let transition = EventDetailsTransition(originFrame: relativeFrame)
        transition.presenting = true
//        selectedCell.isHidden = true
        
        return transition
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        guard let selectedCell = self.selectedCell else {
//            return nil
//        }
//        guard let relativeFrame = selectedCell.superview?.convert((selectedCell.frame), to: nil) else {
//            return nil
//        }
        
        self.statusBarIsHidden = false
        let transition = EventDetailsTransition(originFrame: self.originFrame!)
        transition.presenting = false
        return transition
    }
}
