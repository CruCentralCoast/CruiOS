//
//  ConfirmJoinGroupViewController.swift
//  Cru
//
//  Created by Erica Solum on 8/20/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class ConfirmJoinGroupViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func confirmPressed(_ sender: Any) {
        //navigate back to get involved
        dismissToGetInvolved()
    }

    func dismissToGetInvolved() {
        let nav = self.presentingViewController as! UINavigationController
        dismiss(animated: true, completion: { () -> Void in
            nav.popViewController(animated: true)
        })
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
