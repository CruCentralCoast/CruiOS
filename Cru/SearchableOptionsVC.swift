//
//  SearchableOptionsVC.swift
//  Cru
//
//  Created by Max Crane on 5/17/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class SearchableOptionsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var options: [String]!
    var optionHandler: ((String)->())!
    
    override func viewDidLoad() {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel!.text = options[indexPath.row]
        //print(cgQuestion.options[indexPath.row])
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        optionHandler((cell.textLabel?.text!)!)
        self.dismiss(animated: true, completion: {})
    }
    
}
