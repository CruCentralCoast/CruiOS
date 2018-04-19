//
//  CommunityViewController.swift
//  CruCentralCoast
//
//  Created by Landon Gerrits on 2/6/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class CommunityViewController: UIViewController {
    
    // TO-DO changes these names to "didTap" ....
    @IBAction func communityGroupsButton(_ sender: Any) {
        let vc = UIStoryboard(name: "CommunityGroups", bundle: nil).instantiateViewController(withIdentifier: "CommunityGroups")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didTapMissions(_ sender: Any) {
        let vc = UIStoryboard(name: "Missions", bundle: nil).instantiateViewController(withIdentifier: "Missions")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBOutlet weak var communityGroupsView: UIView!
    @IBOutlet weak var ministryTeamsView: UIView!
    @IBOutlet weak var missionsView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.communityGroupsView.layer.cornerRadius = 15
        self.ministryTeamsView.layer.cornerRadius = 15
        self.missionsView.layer.cornerRadius = 15
        
        
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
