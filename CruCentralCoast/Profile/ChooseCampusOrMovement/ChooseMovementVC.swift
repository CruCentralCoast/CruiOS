//
//  ChooseMovementVC.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 7/22/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class ChooseMovementVC: UITableViewController {
    
    var campus: Campus!
    var selectedCampusCell: ChooseCampusCell?
    var movementSubscriptionDelegate: MovementSubscriptionDelegate!
    var chooseMovementObserver: ChooseMovementObserver!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Choose Movement"
        self.configureTableView()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonPressed))
    }
    
    private func configureTableView() {
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.registerCell(ChooseMovementCell.self)
    }
    
    @objc private func doneButtonPressed() {
        self.movementSubscriptionDelegate.finalizeSubsciption()
    }
}

extension ChooseMovementVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.campus.movements.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ChooseMovementCell.self, indexPath: indexPath)
        let movement = self.campus.movements[indexPath.row]
        let isSubscribed = self.movementSubscriptionDelegate.isSubscribed(to: movement.id)
        cell.configure(with: movement, subscriptionStatus: isSubscribed)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let selectedMovement = self.campus.movements[indexPath.row]
        cell?.isSelected = false
        
        if self.movementSubscriptionDelegate.isSubscribed(to: selectedMovement.id) {
            cell?.accessoryType = .none
            self.movementSubscriptionDelegate.unsubscribe(from: selectedMovement.id)
        } else {
            cell?.accessoryType = .checkmark
            self.movementSubscriptionDelegate.subscribe(to: selectedMovement.id)
        }
        self.chooseMovementObserver.movementSubscriptionChanged()
    }
}
