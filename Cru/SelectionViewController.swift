//
//  SelectionViewController.swift
//  Cru
//
//  Created by Tyler Dahl on 8/12/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class SelectionViewController: UITableViewController {

    var delegate: SelectionViewControllerDelegate?
    
    let options: [String]
    var selectedOptions: [String]
    
    let allowsMultipleSelections: Bool
    
    init(options: [String], selectedOptions: [String] = [], allowsMultipleSelections: Bool = false) {
        self.options = options
        self.selectedOptions = selectedOptions
        self.allowsMultipleSelections = allowsMultipleSelections
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure nav bar
        self.navigationController?.navigationBar.tintColor = CruColors.yellow
        if self.allowsMultipleSelections {
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.finishSelection))
            self.navigationItem.rightBarButtonItem = doneButton
        }

        // Configure tableview
        self.tableView.registerCell(UITableViewCell.self)
    }
    
    @objc fileprivate func finishSelection() {
        // Sort the selected options by their order in the list of options
        self.selectedOptions.sort { self.options.index(of: $0) ?? 0 < self.options.index(of: $1) ?? 0 }
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        self.delegate?.selectedOptions(self.selectedOptions)
    }
}

// MARK: - UITableViwe Methods
extension SelectionViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.options.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(UITableViewCell.self, for: indexPath)
        
        let option = self.options[indexPath.row]
        cell.textLabel?.text = option
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.accessoryType = self.selectedOptions.contains(option) ? .checkmark : .none
        cell.tintColor = CruColors.orange
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect the option if it is already selected, else select it
        let option = self.options[indexPath.row]
        if self.selectedOptions.contains(option), let selectedOptionIndex = self.selectedOptions.index(of: option) {
            self.selectedOptions.remove(at: selectedOptionIndex)
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            if self.allowsMultipleSelections {
                if !self.selectedOptions.contains(option) {
                    self.selectedOptions.append(option)
                }
            } else {
                self.selectedOptions = [option]
            }
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        // Deselect row if multiple selections allowed, else finish selection
        if self.allowsMultipleSelections {
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            self.finishSelection()
        }
    }
}

protocol SelectionViewControllerDelegate {
    func selectedOptions(_ selectedOptions: [String])
}
