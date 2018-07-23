//
//  EventsTVC.swift
//  CruCentralCoast
//
//  Created by Cam Stocker on 7/1/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class EventsTVC: UITableViewController, UIGestureRecognizerDelegate {
    var selectedCell: EventsTableCell?
    var originFrame: CGRect?
    var longPressIndexPath: IndexPath!
    var longPressCancelled: Bool = false
    var longPressFailed: Bool = false
    var longPressGestureRecognizer: UILongPressGestureRecognizer?
    
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
        self.tableView.registerCell(EventsTableCell.self)
        self.tableView.setContentOffset(tableView.contentOffset, animated: false)
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 140
        
        DatabaseManager.instance.getEvents { (events) in
            self.dataArray = events
            for event in self.dataArray {
                UIImage.downloadedFrom(link: event.imageLink, completion: { (image) in
                    event.image = image
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                })
            }
            self.tableView.reloadData()
        }
        createLongPressGesture()
    }
    
    func createLongPressGesture() {
        self.longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(gestureRecognizer:)))
        guard let longPressGestureRecognizer = self.longPressGestureRecognizer else {
            return
        }
        longPressGestureRecognizer.minimumPressDuration = 0.05
        longPressGestureRecognizer.allowableMovement = 0
        longPressGestureRecognizer.delegate = self
        self.tableView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc internal func handleLongPressGesture(gestureRecognizer: UILongPressGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: self.view)
        if gestureRecognizer.state == .began {
            self.longPressCancelled = false
            self.longPressFailed = false
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                self.longPressIndexPath = indexPath
                self.longPressGestureBegan(indexPath: indexPath)
            }
        } else if gestureRecognizer.state == .ended {
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                if indexPath == self.longPressIndexPath {
                    self.longPressGestureEnded(indexPath: indexPath)
                } else {
                    self.longPressGestureCancelled(indexPath: self.longPressIndexPath)
                }
            }
        } else if gestureRecognizer.state == .cancelled {
            self.longPressCancelled = true
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                self.longPressGestureCancelled(indexPath: indexPath)
            }
        }
        else if gestureRecognizer.state == .failed {
            self.longPressFailed = true
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                self.longPressGestureCancelled(indexPath: indexPath)
            }
        }
    }
    
    func longPressGestureBegan(indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        UIView.animate(withDuration: 0.2, animations: {
            cell?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        })
    }
    
    func longPressGestureEnded(indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        guard let vc = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "EventDetailsVC") as? EventDetailsVC else {
            assertionFailure("Probably used the wrong storyboard name or identifier here")
            return
        }
        if self.longPressCancelled == false && self.longPressFailed == false {
            UIView.animate(withDuration: 0.05, animations: {
                cell?.transform = CGAffineTransform.identity
            }, completion: { (finish) in
                vc.configure(with: self.dataArray[indexPath.item])
                vc.transitioningDelegate = self
                self.selectedCell = self.tableView.cellForRow(at: indexPath) as? EventsTableCell
                self.navigationController?.present(vc, animated: true, completion: nil)
            })
        }
    }
    
    func longPressGestureCancelled(indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        UIView.animate(withDuration: 0.2, animations: {
            cell?.transform = CGAffineTransform.identity
        })
    }
    
    //code is commented out for the time being but will be used in the future
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        if gestureRecognizer == self.tableView.panGestureRecognizer && otherGestureRecognizer == self.longPressGestureRecognizer {
//            return true
//        }
//        gestureRecognizer.cancelsTouchesInView = true
//        return false
//    }
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        if gestureRecognizer == self.tableView.panGestureRecognizer && otherGestureRecognizer == self.longPressGestureRecognizer {
//            return true
//        }
//        return false
//    }
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(EventsTableCell.self, indexPath: indexPath)
        cell.event = dataArray[indexPath.item]
        cell.selectionStyle = .none
        return cell
    }
}

extension EventsTVC: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let selectedCell = self.selectedCell else {
            return nil
        }
        guard let relativeFrame = selectedCell.cellMask.superview?.convert((selectedCell.cellMask.frame), to: nil) else {
            return nil
        }
        self.statusBarIsHidden = true
        self.originFrame = relativeFrame
        let transition = EventDetailsTransition(originFrame: relativeFrame)
        transition.presenting = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let originFrame = self.originFrame else {
            return nil
        }
        self.statusBarIsHidden = false
        let transition = EventDetailsTransition(originFrame: originFrame)
        transition.presenting = false
        return transition
    }
}
