//
//  EventsTVC.swift
//  CruCentralCoast
//
//  Created by Cam Stocker on 7/1/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit
import RealmSwift

class EventsTVC: UITableViewController {
    var selectedCell: EventsTableCell?
    var originFrame: CGRect?
    
    var dataArray: Results<Event>!
    var campuses: Results<Campus>!
    var movements: Results<Movement>!
    
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
        
        DatabaseManager.instance.subscribeToDatabaseUpdates(self)
        self.campuses = DatabaseManager.instance.getCampuses()
        self.movements = DatabaseManager.instance.getMovements()
        self.dataArray = DatabaseManager.instance.getEvents()
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(gestureRecognizer:)))
        longPressGestureRecognizer.minimumPressDuration = 0.3
        longPressGestureRecognizer.delegate = self
        self.tableView.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc internal func handleLongPressGesture(gestureRecognizer: UILongPressGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: self.view)
        if gestureRecognizer.state == .began {
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let cell = tableView.cellForRow(at: indexPath)
                UIView.animate(withDuration: 0.2, animations: {
                    cell?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                })
            }
        } else if gestureRecognizer.state == .ended {
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let cell = tableView.cellForRow(at: indexPath)
                guard let vc = UIStoryboard(name: "Events", bundle: nil).instantiateViewController(withIdentifier: "EventDetailsVC") as? EventDetailsVC else {
                    assertionFailure("Probably used the wrong storyboard name or identifier here")
                    return
                }
                UIView.animate(withDuration: 0.05, animations: {
                    cell?.transform = CGAffineTransform.identity
                }, completion: { (finish) in
                    vc.configure(with: self.dataArray[indexPath.item])
                    vc.transitioningDelegate = self
                    self.selectedCell = self.tableView.cellForRow(at: indexPath) as? EventsTableCell
                    self.navigationController?.present(vc, animated: true, completion: nil)
                })
            }
        } else if gestureRecognizer.state == .cancelled {
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let cell = tableView.cellForRow(at: indexPath)
                UIView.animate(withDuration: 0.2, animations: {
                    cell?.transform = CGAffineTransform.identity
                })
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240
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

extension EventsTVC: UIGestureRecognizerDelegate {
    //used so scrolling and longPressGesture can be detected simultaneously
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension EventsTVC: DatabaseListenerProtocol {
    func updatedCampuses() {
        print("updated campuses")
    }
    func updatedMovements() {
        print("updated movements")
    }
    func updatedEvents() {
        print("Events were updated - refreshing UI")
        for event in self.dataArray {
            if let imageLink = event.imageLink {
                UIImage.downloadedFrom(link: imageLink, completion: { (image) in
                    event.image = image
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                })
            }
        }
        self.tableView.reloadData()
    }
}
