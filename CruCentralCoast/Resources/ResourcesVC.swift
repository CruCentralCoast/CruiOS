//
//  ResourcesViewController.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 3/28/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class ResourcesVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: CustomSegmentedControl!
    @IBOutlet weak var fakeBottomNavBar: UIView!
    private var shadowImageView: UIImageView?
    
    lazy var articlesVC: ArticlesResources = {
        let dataSource = ArticlesResources()
        return dataSource
    }()
    lazy var videosVC: VideosResources = {
        let dataSource = VideosResources()
        return dataSource
    }()
    lazy var audioVC: AudioResources = {
        let dataSource = AudioResources()
        return dataSource
    }()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.registerCell(ArticlesResourcesCell.self)
        self.tableView.registerCell(VideosResourcesCell.self)
        self.tableView.registerCell(AudioResourcesCell.self)
        self.tableView.dataSource = self.articlesVC
        self.tableView.delegate = self.articlesVC
        
        self.insertProfileButtonInNavBar(buttonPressed: #selector(self.pushProfileViewController))
        
        if self.shadowImageView == nil {
            self.shadowImageView = self.findShadowImage(under: navigationController!.navigationBar)
        }
        self.shadowImageView?.isHidden = true
        
        self.fakeBottomNavBar.addBorders(edges: .bottom, color: .navBarLineGray, thickness: 1)
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
        print("hi")
    }
    
    private func showSelectedView(_ index: Int) {
        switch index {
        case 0:
            self.tableView.dataSource = self.articlesVC
            self.tableView.delegate = self.articlesVC
        case 1:
            self.tableView.dataSource = self.videosVC
            self.tableView.delegate = self.videosVC
        case 2:
            self.tableView.dataSource = self.audioVC
            self.tableView.delegate = self.audioVC
        default:
            return
        }
        self.tableView.reloadData()
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: CustomSegmentedControl) {
        self.showSelectedView(sender.selectedSegmentIndex)
    }
}

