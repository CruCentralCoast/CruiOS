//
//  GetInvolvedViewController.swift
//  Cru
//
//  Created by Max Crane on 11/17/15.
//  Copyright © 2015 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class GetInvolvedViewController: UIViewController, UITabBarDelegate, SWRevealViewControllerDelegate {
    //MARK: Properties
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    //container views for each section
    @IBOutlet weak var communityGroupContainer: UIView!
    @IBOutlet weak var ministryTeamContainer: UIView!
    @IBOutlet weak var inCommunityGroupContainer: UIView!

    //selector bar
    @IBOutlet weak var selectorBar: UITabBar!
    
    var chosenSection = ""
    var cgController : DisplayCGVC?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showCGContainer()
        
        //side menu reveal controller
        GlobalUtils.setupViewForSideMenu(self, menuButton: menuButton)

        selectorBar.selectedItem = selectorBar.items![0]
        selectorBar.tintColor = UIColor.white

        //Set the nav title & font
        navigationItem.title = "Get Involved"
        
        
        
        self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.white]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //showCGContainer()
        chosenSection = selectorBar.selectedItem!.title!
        showCorrectContainers()
    }
    
    //tab bar function 
    //TODO figure out how to call this in viewDidLoad
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        chosenSection = item.title!
        showCorrectContainers()
    }
    
    func showCorrectContainers(){
        switch (chosenSection){
            case "Community Group":
                showCGContainer()
                //cgController.
            case "Ministry Teams":
                ministryTeamContainer.isHidden = false
                communityGroupContainer.isHidden = true
                inCommunityGroupContainer.isHidden = true
            default :
                print("")
        }
    }
    
    fileprivate func showCGContainer() {
        if (GlobalUtils.loadString(Config.communityGroupKey) == "") {
            communityGroupContainer.isHidden = false
            ministryTeamContainer.isHidden = true
            inCommunityGroupContainer.isHidden = true
        } else {
            ministryTeamContainer.isHidden = true
            communityGroupContainer.isHidden = true
            inCommunityGroupContainer.isHidden = false
        }
    }
    
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "cgDetailSegue"){
            if let cg = segue.destination as? DisplayCGVC{
                cgController = cg
                cgController!.leaveCallback = showCGContainer
            }
        }
    }
    

}
