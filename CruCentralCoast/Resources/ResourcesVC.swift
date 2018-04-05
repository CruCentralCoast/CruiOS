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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerCell(ArticlesResourcesCell.self)
        self.tableView.registerCell(VideosResourcesCell.self)
        self.tableView.registerCell(AudioResourcesCell.self)
        self.tableView.dataSource = self.articlesVC
        self.tableView.delegate = self.articlesVC
        
        self.insertProfileButtonInNavBar(buttonPressed: #selector(pushProfileViewController))
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

