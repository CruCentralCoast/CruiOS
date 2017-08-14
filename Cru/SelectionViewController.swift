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
        
        if self.allowsMultipleSelections {
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.finishSelection))
            self.navigationItem.rightBarButtonItem = doneButton
        }

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SelectionCell")
    }
    
    @objc fileprivate func finishSelection() {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectionCell", for: indexPath)
        
        let option = self.options[indexPath.row]
        cell.textLabel?.text = option
        cell.accessoryType = self.selectedOptions.contains(option) ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = self.options[indexPath.row]
        
        // Deselect the option if it is already selected
        if self.selectedOptions.contains(option), let selectedOptionIndex = self.selectedOptions.index(of: option) {
            self.selectedOptions.remove(at: selectedOptionIndex)
            tableView.reloadData()
        } else {
            if self.allowsMultipleSelections {
                if !self.selectedOptions.contains(option) {
                    self.selectedOptions.append(option)
                    tableView.reloadData()
                }
            } else {
                self.selectedOptions = [option]
                self.finishSelection()
            }
        }
    }
}

protocol SelectionViewControllerDelegate {
    func selectedOptions(_ selectedOptions: [String])
}
