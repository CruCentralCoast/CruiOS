//
//  IntroViewController.swift
//  Cru
//
//  Description: View controller for showing the introduction modals. It only shows up once when the app first launches.
//
//  Created by Deniz Tumer on 1/14/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController {
    // MARK: Properties
    // all of the introduction modals
    var introModals = [UIView]()
    // background view outlet for modal window
    @IBOutlet weak var backgroundModal: UIView!
    // modal for displaying the description of cru
    @IBOutlet weak var descriptionModal: UIView!
    // modal for displaying the campuses
    @IBOutlet weak var campusesModal: UIView!
    // modal for displaying ministries
    @IBOutlet weak var ministriesModal: UIView!
    
    // the reference to the current modal window that is open
    var currentModal: UIView!
    
    // reference to title label
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var modalHeight: NSLayoutConstraint!
    // reference to buttons on a modal
    var modalButtons = [UIButton]()
    
    // reference to the main view controller
    var mainViewController: MainViewController!
    // reference to ministry table view controller
    var embeddedMinistryViewController: MinistryTableViewController!
    // reference to campus table view controller
    var embeddedCampusesViewController: CampusesTableViewController!

    // MARK: Overriden UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Tell the controllers that this is during initial launch
        embeddedMinistryViewController.onboarding = true
        embeddedCampusesViewController.onboarding = true

        // Do any additional setup after loading the view.
        initializeProperties()
        initializeBackgroundViewProperties()
        hideAllModals()
    }
    
    //Actions to take after the view of the application completely loads and appears onscreen
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        print(self.parentViewController)
        displayModal(descriptionModal, fromModal: nil)
    }
    
    // MARK: Initialization Methods
    //function for initializing the background variables
    private func initializeProperties() {
        introModals.append(descriptionModal)
        introModals.append(campusesModal)
        introModals.append(ministriesModal)
    }
    
    // function for initializing properties about the background and the background modal view
    private func initializeBackgroundViewProperties() {
        self.view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(Config.backgroundViewOpacity)
        backgroundModal.layer.cornerRadius = Config.modalBackgroundRadius
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        modalHeight.constant = screenSize.height * 0.75
    }
    
    // function for initializing programmatically a button for next or back
    private func initializeButton(buttonText: String, buttonWidth: CGFloat, buttonX: CGFloat) {
        let buttonHeight: CGFloat = 50.0
        let buttonY = (backgroundModal.frame.size.height) - buttonHeight
        let button = UIButton(type: UIButtonType.System) as UIButton
        button.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight)
        button.backgroundColor = UIColor.clearColor()
        button.setTitleColor(Config.textColor, forState: UIControlState.Normal)
        button.titleLabel!.font = UIFont(name: Config.fontBold, size: 18)
        button.setTitle(buttonText, forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(IntroViewController.presentModal(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.backgroundModal.addSubview(button)
        self.modalButtons.append(button)
    }
    
    // function for configuring the current modal window
    // goes through sublayers and sets the corner radius to the specified corner radius
    private func configureModal(currentModal: UIView!) {
        
        //create the corner radius for all sub views
        for sublayer in currentModal.layer.sublayers! {
            sublayer.backgroundColor = Config.introModalContentColor.CGColor
        }
        
        //add next and back buttons
        if (currentModal == descriptionModal) {
            let nextButtonWidth = currentModal.frame.size.width
            let nextButtonX = (backgroundModal.frame.size.width / 2) - (nextButtonWidth / 2)
            initializeButton("Next", buttonWidth: nextButtonWidth, buttonX: nextButtonX)
            
            titleLabel.text = " "
        }
        else if (currentModal == campusesModal) {
            let backButtonWidth = currentModal.frame.size.width / 2
            let backButtonX = (backgroundModal.frame.size.width / 4) - (backButtonWidth / 2)
            initializeButton("Back", buttonWidth: backButtonWidth, buttonX: backButtonX)
            
            let nextButtonWidth = backButtonWidth
            let nextButtonX = (backgroundModal.frame.size.width * (3 / 4)) - (nextButtonWidth / 2)
            initializeButton("Next", buttonWidth: nextButtonWidth, buttonX: nextButtonX)
            
            titleLabel.text = "Pick your campuses:"
        }
        else {
            let backButtonWidth = currentModal.frame.size.width / 2
            let backButtonX = (backgroundModal.frame.size.width / 4) - (backButtonWidth / 2)
            initializeButton("Back", buttonWidth: backButtonWidth, buttonX: backButtonX)
            
            let nextButtonWidth = backButtonWidth
            let nextButtonX = (backgroundModal.frame.size.width * (3 / 4)) - (nextButtonWidth / 2)
            initializeButton("Done", buttonWidth: nextButtonWidth, buttonX: nextButtonX)
            
            titleLabel.text = "Pick your ministries:"
        }
    }
    
    // function for hiding all modal windows (initialization)
    private func hideAllModals() {
        descriptionModal.hidden = true
        campusesModal.hidden = true
        ministriesModal.hidden = true
        
        currentModal = nil
    }
    
    // MARK: Helper Methods
    
    /* Function for displaying a specific modal window. Also closes the previous modal */
    private func displayModal(toModal: UIView, fromModal: UIView?) {
        //remove buttons from the previous modal
        for button in modalButtons {
            button.removeFromSuperview()
        }
        modalButtons.removeAll()
        
        // If there is a modal we're coming from hide it
        if fromModal != nil {
            fromModal!.hidden = true
        }
        
        toModal.hidden = false
        currentModal = toModal
        configureModal(currentModal)
    }
    
    // MARK: Actions
    
    // action for presenting a new modal if a next button or back button is pressed
    @IBAction func presentModal(sender: UIButton) {
        //get index of current modal
        //check if we're going forward or backward
        //display the modal before or after it
        
        let currentNdx = introModals.indexOf(currentModal)
        var nextNdx = 0
        
        //we're going forward one modal
        if (sender.titleLabel!.text == "Next") {
            nextNdx = currentNdx! + 1
        }
        //we're going backwards one modal
        else if (sender.titleLabel!.text == "Back") {
            nextNdx = currentNdx! - 1
        }
        else {
            //close modals completely
            self.mainViewController.navigationItem.leftBarButtonItem?.enabled = true
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        if(introModals[nextNdx] == ministriesModal){
            embeddedMinistryViewController.reloadData()
        }
        else if(introModals[nextNdx] == campusesModal){
            embeddedMinistryViewController.saveMinistriesToDevice()
            embeddedCampusesViewController.refreshSubbedMinistries()
        }
        
        displayModal(introModals[nextNdx], fromModal: currentModal)
        
    }
    
    //sets view controllers when certain segues are called
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? MinistryTableViewController where segue.identifier == "ministrySegue" {
            embeddedMinistryViewController = vc
        }
        if let vc = segue.destinationViewController as? CampusesTableViewController where segue.identifier == "campusSegue" {
            embeddedCampusesViewController = vc
        }
    }
}
