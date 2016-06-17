//
//  GetInvolvedViewController.swift
//  Cru
//
//  Created by Max Crane on 11/17/15.
//  Copyright © 2015 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

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
        selectorBar.tintColor = UIColor.whiteColor()

        //Set the nav title & font
        navigationItem.title = "Get Involved"
        
        self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
    override func viewWillAppear(animated: Bool) {
        //showCGContainer()
        chosenSection = selectorBar.selectedItem!.title!
        showCorrectContainers()
    }
    
    //tab bar function 
    //TODO figure out how to call this in viewDidLoad
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        chosenSection = item.title!
        showCorrectContainers()
    }
    
    func showCorrectContainers(){
        switch (chosenSection){
            case "Community Group":
                showCGContainer()
                //cgController.
            case "Ministry Teams":
                ministryTeamContainer.hidden = false
                communityGroupContainer.hidden = true
                inCommunityGroupContainer.hidden = true
            default :
                print("")
        }
    }
    
    private func showCGContainer() {
        if (GlobalUtils.loadString(Config.communityGroupKey) == "") {
            communityGroupContainer.hidden = false
            ministryTeamContainer.hidden = true
            inCommunityGroupContainer.hidden = true
        } else {
            ministryTeamContainer.hidden = true
            communityGroupContainer.hidden = true
            inCommunityGroupContainer.hidden = false
        }
    }
    
    //reveal controller function for disabling the current view
    func revealController(revealController: SWRevealViewController!, willMoveToPosition position: FrontViewPosition) {
        
        if position == FrontViewPosition.Left {
            for view in self.view.subviews {
                view.userInteractionEnabled = true
            }
        }
        else if position == FrontViewPosition.Right {
            for view in self.view.subviews {
                view.userInteractionEnabled = false
            }
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "cgDetailSegue"){
            if let cg = segue.destinationViewController as? DisplayCGVC{
                cgController = cg
                cgController!.leaveCallback = showCGContainer
            }
        }
    }
    

}
