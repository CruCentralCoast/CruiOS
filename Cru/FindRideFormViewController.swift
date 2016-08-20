//
//  FindRideFormViewController.swift
//  Cru
//
//  Created by Erica Solum on 8/11/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import MRProgress

class FindRideFormViewController: UIViewController {
    
    // MARK: Properties
    
    var ride: Ride!
    var event: Event!
    var rideVC: RidesViewController?
    var eventVC : EventDetailsViewController?
    var numberValue : UITextView!
    var nameValue : UITextView!
    var parsedName = ""
    var parsedNum = ""
    var wasLinkedFromEvents = false
    var wasLinkedFromMap = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = JoinRideConstants.NAME

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
