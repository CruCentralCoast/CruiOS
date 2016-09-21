//
//  AboutViewController.swift
//  Cru
//
//  Created by Erica Solum on 9/21/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController, SWRevealViewControllerDelegate {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()

        //Set up the menu button and nav button
        GlobalUtils.setupViewForSideMenu(self, menuButton: menuButton)
        
        navigationItem.title = "About"
        
        self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
    //reveal controller function for disabling the current view
    func revealController(revealController: SWRevealViewController!, willMoveToPosition position: FrontViewPosition) {
        
        if position == FrontViewPosition.Left {
            for view in self.view.subviews {
                print("Pisition is left")
                view.userInteractionEnabled = true
            }
        }
        else if position == FrontViewPosition.Right {
            for view in self.view.subviews {
                print("Pisition is right")
                view.userInteractionEnabled = false
            }
        }
    }

}
