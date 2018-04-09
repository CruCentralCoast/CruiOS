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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: CustomSegmentedControl!
    @IBOutlet weak var fakeBottomNavBar: UIView!
    private var shadowImageView: UIImageView?
    
    lazy var articlesResources: ArticlesResources = {
        let dataSource = ArticlesResources()
        return dataSource
    }()
    lazy var videosResources: VideosResources = {
        let dataSource = VideosResources()
        return dataSource
    }()
    lazy var audioResources: AudioResources = {
        let dataSource = AudioResources()
        return dataSource
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.insertProfileButtonInNavBar(buttonPressed: #selector(self.pushProfileViewController))
        self.tableView.registerCell(ArticlesResourcesCell.self)
        self.tableView.registerCell(VideosResourcesCell.self)
        self.tableView.registerCell(AudioResourcesCell.self)
        self.tableView.dataSource = self.articlesResources
        self.tableView.delegate = self.articlesResources
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.shadowImageView == nil {
            self.shadowImageView = self.findShadowImage(under: self.navigationController!.navigationBar)
        }
        self.shadowImageView?.isHidden = true

        self.fakeBottomNavBar.addBorders(edges: .bottom, color: .navBarLineGray, thickness: 0.5)
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
    
    @objc func pushProfileViewController(sender: UIButton) {
        print("Profile Button Pressed")
    }
    
    private func showSelectedView(_ index: Int) {
        switch index {
        case 0:
            self.tableView.dataSource = self.articlesResources
            self.tableView.delegate = self.articlesResources
        case 1:
            self.tableView.dataSource = self.videosResources
            self.tableView.delegate = self.videosResources
        case 2:
            self.tableView.dataSource = self.audioResources
            self.tableView.delegate = self.audioResources
        default:
            return
        }
        self.tableView.reloadData()
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: CustomSegmentedControl) {
        self.showSelectedView(sender.selectedSegmentIndex)
    }
}
