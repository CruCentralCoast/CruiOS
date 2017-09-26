//
//  ResourcesTabVC.swift
//  Cru
//
//  Created by Erica Solum on 9/19/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import DZNEmptyDataSet
import MRProgress

class ResourcesTabVC: ButtonBarPagerTabStripViewController, SWRevealViewControllerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var searchButton: UIBarButtonItem!

    // MARK: - Properties 
    var hasConnection = true
    var searchActivated = false
    /*var modalActive = false {
        didSet {
            if modalActive == true {
                searchButton.isEnabled = false
            }
            else {
                searchButton.isEnabled = true
            }
        }
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //side menu reveal controller
        GlobalUtils.setupViewForSideMenu(self, menuButton: menuButton)
        
        //Check Connection
        CruClients.getServerClient().checkConnection(self.finishConnectionCheck)
        
        //Set up Tab Bar controller look
        buttonBarView.selectedBar.backgroundColor = CruColors.lightBlue
        buttonBarView.backgroundColor = CruColors.gray
        
        settings.style.buttonBarItemTitleColor = UIColor.white
        settings.style.buttonBarItemBackgroundColor = CruColors.gray
        settings.style.buttonBarItemFont = UIFont(name: Config.fontBold, size: 16)!
        
        //Changes the font color of the selected tab
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .white
            newCell?.label.textColor = CruColors.lightBlue
        }
        
        //Set the nav title & font
        navigationItem.title = "Resources"
        self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.white]
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }

    
    // MARK: - Connection & Resource Loading
    //Test to make sure there is a connection then load resources
    func finishConnectionCheck(_ connected: Bool){
        if(!connected){
            hasConnection = false
            //hasConnection = false
        }else{
            hasConnection = true
            
            //MRProgressOverlayView.showOverlayAdded(to: self.view, animated: true)
            
            // TODO: Call Resource Manager here instead of making call to server directly
            
            ResourceManager.sharedInstance.loadResources({ resSuccess, youtubeSuccess in
                //self.articles = articles
                //self.audioFiles = audioFiles
                //self.videos = videos
                //self.tableView.reloadData()
                if !resSuccess {
                    print("Could not load resources")
                    
                }
                if !youtubeSuccess {
                    print("Could not load youtube videos")
                }
                //MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
            })
            
            //Also get resource tags and store them
            ResourceManager.sharedInstance.loadResourceTags()
        }
        
    }
    
    // MARK: - PagerTabStripDataSource
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let child_1 = UIStoryboard(name: "resources", bundle: nil).instantiateViewController(withIdentifier: "articleTab")
        let child_2 = UIStoryboard(name: "resources", bundle: nil).instantiateViewController(withIdentifier: "audioTab")
        let child_3 = UIStoryboard(name: "resources", bundle: nil).instantiateViewController(withIdentifier: "videoTab")
        
        //GlobalUtils.saveBool(UserKeys.isCommunityGroupLeader, value: leader)
        if GlobalUtils.loadBool(UserKeys.isCommunityGroupLeader) {
            let child_4 = UIStoryboard(name: "resources", bundle: nil).instantiateViewController(withIdentifier: "leaderTab")
            return [child_1, child_2, child_3, child_4]
        }
        else {
            
            return [child_1, child_2, child_3]
        }
        
    }
    
    // MARK: - Menu View Controller Functions
    
    //reveal controller function for disabling the current view
    func revealController(_ revealController: SWRevealViewController!, willMoveTo position: FrontViewPosition) {
        
        if position == FrontViewPosition.left {
            for view in self.view.subviews {
                view.isUserInteractionEnabled = true
            }
        }
        else if position == FrontViewPosition.right {
            for view in self.view.subviews {
                view.isUserInteractionEnabled = false
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func presentSearchModal(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "resources", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "searchModal") as! SearchModalViewController
        //controller.parentVC = self
        
        
        //controller.tags = self.tags
        //controller.filteredTags = self.tags
        /*if ResourceManager.sharedInstance.isSearchActivated() {
            controller.filteredTags = ResourceManager
            controller.prevSearchPhrase = self.searchPhrase
            
        }*/
        
        let curVCs = self.viewControllers(for: self)
        //let curIndex = self.currentIndex
        print("Current controller index: \(self.currentIndex)")
        print("search delegate set to \(self.currentIndex)")
        ResourceManager.sharedInstance.searchDelegate = curVCs[currentIndex] as? ResourceDelegate
        
        //controller.delegate = curVCs[currentIndex] as? SearchDelegate
        
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        
        self.present(controller, animated: true, completion: nil)
        
        //modalActive = true
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        /*if segue.identifier == "searchDialog" {
            
            let modalVC = segue.destination as! SearchModalViewController
            modalVC.transitioningDelegate = self
            modalVC.preferredContentSize = CGSize(width: UIScreen.main.bounds.width * 0.7, height: UIScreen.main.bounds.height * 0.7)
            modalVC.parentVC = self
            
            
            modalVC.tags = self.tags
            modalVC.filteredTags = self.tags
            if searchActivated {
                modalVC.filteredTags = self.filteredTags
                modalVC.prevSearchPhrase = self.searchPhrase
                
            }
            //dim(.in, alpha: dimLevel, speed: dimSpeed)
            
        }*/
    }
    

}
