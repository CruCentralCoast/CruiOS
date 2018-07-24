//
//  CommunityViewController.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 2/6/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class CommunityViewController: UIViewController {
    
    @IBOutlet weak var communityGroupButton: UIButton!
    @IBOutlet weak var ministryTeamButton: UIButton!
    @IBOutlet weak var missionsButton: UIButton!
    
    // TO-DO changes these names to "didTap" ....
    
    @IBAction func didTapCommunityGroups(_ sender: Any) {
        let vc = UIStoryboard(name: "CommunityGroups", bundle: nil).instantiateViewController(withIdentifier: "CommunityGroups")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func didTapMinistryTeams(_ sender: Any) {
        let vc = UIStoryboard(name: "MinistryTeams", bundle: nil).instantiateViewController(withIdentifier: "MinistryTeams")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func didTapMissions(_ sender: Any) {
        let vc = UIStoryboard(name: "Missions", bundle: nil).instantiateViewController(withIdentifier: "Missions")
        self.navigationController?.pushViewController(vc, animated: true)
    }

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        communityGroupButton.layer.cornerRadius = 15
        ministryTeamButton.layer.cornerRadius = 15
        missionsButton.layer.cornerRadius = 15
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
