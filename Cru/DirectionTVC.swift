//
//  DirectionTVC.swift
//  Cru
//
//  Created by Max Crane on 5/8/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

struct Directions{
    static let to = "to event"
    static let from = "from event"
    static let both = "round-trip"
}


class DirectionTVC: UITableViewController {
    let options = [Directions.to, Directions.from, Directions.both]
    var handler: ((String)->())?
    @IBOutlet var table: UITableView!
    
    
    
    override func viewDidLoad() {
       table.isScrollEnabled = true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel!.text = options[indexPath.row]
        cell?.textLabel?.font = UIFont(name: "FreightSans Pro", size: 18)
        cell?.textLabel?.textAlignment = .center
        return cell!
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        handler!((cell!.textLabel?.text)!)
        
        self.dismiss(animated: true, completion: nil)
    }
}
