//
//  EventDetailsVC.swift
//  CruCentralCoast
//
//  Created by Cam Stocker on 4/25/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

struct EventCellParameters {
    let titleLabel : String
    let date : String
    let location : String
    let description : String
}

class EventDetailsVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    var titleLabel : String?
    var date: String?
    var location: String?
    var desc: String?
    
    
    @IBAction func dismissDetail(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func FBButton(_ sender: Any) {
        self.presentAlert(title: "Link not set up yet!!", message: "Coming soon")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        let screenWidth = UIScreen.main.bounds.width
        widthConstraint.constant = screenWidth
        
        self.eventTitleLabel.text = self.titleLabel
        self.dateLabel.text = self.date
        self.locationLabel.text = self.location
        self.descriptionText.text = self.description
        
        self.imageView.image = #imageLiteral(resourceName: "night-at-the-oscars")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configure(with cellParameters: EventCellParameters) {
        self.titleLabel = cellParameters.titleLabel
        self.date = cellParameters.date
        self.location = cellParameters.location
        self.desc = cellParameters.description
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
