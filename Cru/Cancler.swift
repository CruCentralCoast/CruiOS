//
//  Cancler.swift
//  Cru
//
//  Created by Max Crane on 3/2/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class Cancler {
    
    static func confirmCancel(_ view: UIViewController, handler: @escaping (_ action: UIAlertAction)->()){
        let cancelAlert = UIAlertController(title: "Are you sure you want to cancel this ride?", message: "This action is permanent.", preferredStyle: UIAlertControllerStyle.alert)
        
        cancelAlert.addAction(UIAlertAction(title: "Cancel the ride", style: .destructive, handler: handler))
        cancelAlert.addAction(UIAlertAction(title: "Just kidding", style: .default, handler: nil))
        view.present(cancelAlert, animated: true, completion: nil)
    }
    
    static func showCancelSuccess(_ view: UIViewController, handler: @escaping (UIAlertAction)->()){
        let cancelAlert = UIAlertController(title: "Ride Cancelled Successfully", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        cancelAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: handler))

        view.present(cancelAlert, animated: true, completion: nil)
    }
    
    static func showCancelFailure(_ view: UIViewController){
        let cancelAlert = UIAlertController(title: "Could Not Cancel Ride", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        cancelAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        view.present(cancelAlert, animated: true, completion: nil)
    }
}
