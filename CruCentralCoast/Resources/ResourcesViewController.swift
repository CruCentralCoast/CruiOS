//
//  ResourcesViewController.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 3/28/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class ResourcesViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segmentedControl: CustomSegmentedControl!
    
    lazy var articlesVC: ArticlesResourcesViewController = {
        let storyboard = UIStoryboard(name: "Resources", bundle: nil)
        
        var vc = storyboard.instantiateViewController(withIdentifier: String(describing: ArticlesResourcesViewController.self)) as! ArticlesResourcesViewController
        
        self.addViewControllerAsChildViewController(vc)
        
        return vc
    }()
    lazy var videosVC: VideosResourcesViewController = {
        let storyboard = UIStoryboard(name: "Resources", bundle: nil)
        
        var vc = storyboard.instantiateViewController(withIdentifier: String(describing: VideosResourcesViewController.self)) as! VideosResourcesViewController
        
        self.addViewControllerAsChildViewController(vc)
        
        return vc
    }()
    lazy var auidioVC: AudioResourcesViewController = {
        let storyboard = UIStoryboard(name: "Resources", bundle: nil)
        var vc = storyboard.instantiateViewController(withIdentifier: String(describing: AudioResourcesViewController.self)) as! AudioResourcesViewController
        self.addViewControllerAsChildViewController(vc)
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showSelectedView(0)
        
    }
    
    private func showSelectedView(_ index: Int) {
        self.articlesVC.view.isHidden = !(index == 0)
        self.videosVC.view.isHidden = !(index == 1)
        self.auidioVC.view.isHidden = !(index == 2)
    }
    
    private func addViewControllerAsChildViewController(_ childViewController: UIViewController) {
        self.addChildViewController(childViewController)
        self.containerView.addSubview(childViewController.view)
        childViewController.view.frame = self.containerView.bounds
        childViewController.view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: CustomSegmentedControl) {
        self.showSelectedView(sender.selectedSegmentIndex)
    }
}

