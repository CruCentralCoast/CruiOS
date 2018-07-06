//
//  MinistryTeamDetailsVC.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 4/16/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

private let reuseIdentifier = "MinistryCell"

struct MinistryCellParameters {
    let teamTitle : String
    let teamMovement: String
    let teamImage : UIImage
    let teamLeaders : [String]
    let teamDescription : String
    
    init(teamTitle: String, teamMovement: String = "Cru Calpoly",teamImage: UIImage = #imageLiteral(resourceName: "placeholder.jpg"), teamLeaders: [String], teamDescription: String) {
        self.teamTitle = teamTitle
        self.teamMovement = teamMovement
        self.teamImage = teamImage
        self.teamDescription = teamDescription
        self.teamLeaders = teamLeaders
    }
}

class MinistryTeamDetailsVC: UIViewController {
    
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var ministyTitleLabel: UILabel!
    @IBOutlet var movementLabel: UILabel!
    @IBOutlet var teamLeaderNamesLabel: UILabel!
    @IBOutlet var ministryDescription: UILabel!
    
    @IBOutlet var joinMinistyTeamButton: UIButton!
    @IBOutlet var closeButton: UIButton!
    
    var ministryTitle: String?
    var movementTitle: String?
    var leaderNames: [String?] = []
    var desc: String?
    
    override var prefersStatusBarHidden: Bool {return true}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ministyTitleLabel.text = ministryTitle
        movementLabel.text = movementTitle
        //teamLeaderNamesLabel.text = leaderNames.compactMap({$0}).joined(separator: " ")
        ministryDescription.text = desc
        
        
        
        self.imageView.image = #imageLiteral(resourceName: "placeholder.jpg")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapCloseButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func configure(with cellParameters: MinistryCellParameters) {
        self.ministryTitle = cellParameters.teamTitle
        self.movementTitle = cellParameters.teamMovement
        self.desc = cellParameters.teamDescription
        self.leaderNames = cellParameters.teamLeaders
        
    }


}
