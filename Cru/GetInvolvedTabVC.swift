//
//  GetInvolvedTabVC.swift
//  Cru
//
//  Created by Erica Solum on 8/5/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class GetInvolvedTabVC: ButtonBarPagerTabStripViewController, SWRevealViewControllerDelegate {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //side menu reveal controller
        GlobalUtils.setupViewForSideMenu(self, menuButton: menuButton)

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
        navigationItem.title = "Get Involved"
        self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.white]
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - PagerTabStripDataSource
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let child_1 = UIStoryboard(name: "communitygroups", bundle: nil).instantiateViewController(withIdentifier: "tab1")
        let child_2 = UIStoryboard(name: "MinistryTeam", bundle: nil).instantiateViewController(withIdentifier: "MinistryTeamViewController")
        return [child_1, child_2]
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
