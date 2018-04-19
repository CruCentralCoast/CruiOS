//
//  MissionDetails.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 4/8/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

struct MissionCellParameters {
    let titleLabel : String
    let date : String
    let location : String
    let description : String
}

class MissionDetailsVC: UIViewController {
    
    @IBOutlet weak var missionTitleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    
    var titleLabel: String?
    var date: String?
    var location: String?
    var desc: String?
    
    
    
    @IBAction func didTapCloseButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: actually set up all of the view properties you need and set them here
        self.missionTitleLabel.text = self.titleLabel
        self.dateLabel.text = self.date
        self.locationLabel.text = self.location
        self.descriptionText.text = self.description
        
        self.imageView.image = #imageLiteral(resourceName: "placeholder.jpg")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configure(with cellParameters: MissionCellParameters) {
        self.titleLabel = cellParameters.titleLabel
        self.date = cellParameters.date
        self.location = cellParameters.location
        self.desc = cellParameters.description
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    
}

