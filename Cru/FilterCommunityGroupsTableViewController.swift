//
//  FilterCommunityGroupsTableViewController.swift
//  Cru
//
//  Created by Tyler Dahl on 8/13/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class FilterCommunityGroupsTableViewController: UITableViewController {
    
    struct FilterOptions {
        var ministry: String?
        var days: [String]
        var hours: (Int, Int)
        var grade: String?
        var gender: String?
    }
    
    fileprivate enum Section: Int {
        case ministry
        case days
        case hours
        case grade
        case gender
        
        var rowCount: Int {
            switch self {
            case .ministry: return 1
            case .days: return 1
            case .hours: return 2
            case .grade: return 1
            case .gender: return 1
            }
        }
        
        var title: String {
            switch self {
            case .ministry: return "Ministry"
            case .days: return "Days Available"
            case .hours: return "Hours Available"
            case .grade: return "Grade"
            case .gender: return "Gender"
            }
        }
    }
    
    fileprivate let sections: [Section] = [.ministry, .days, .hours, .grade, .gender]
    fileprivate var selectedSection: Section?
    
    var filterOptions: FilterOptions?
    
    init(options: FilterOptions? = nil) {
        self.filterOptions = options
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
    }
}

extension FilterCommunityGroupsTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].rowCount
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section].title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        
        cell.accessoryType = .disclosureIndicator
        
        switch Section(rawValue: indexPath.section)! {
        case .ministry:
            cell.textLabel?.text = self.filterOptions?.ministry ?? "Select ministry"
        case .days:
            if let filterOptions = self.filterOptions, filterOptions.days.count > 0 {
                cell.textLabel?.text = filterOptions.days.joined(separator: ", ")
            } else {
                cell.textLabel?.text = "Select available days"
            }
        case .hours:
            break
        case .grade:
            cell.textLabel?.text = self.filterOptions?.grade ?? "Select grade level"
        case .gender:
            cell.textLabel?.text = self.filterOptions?.gender ?? "Select gender"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedSection = Section(rawValue: indexPath.section)!
        
        var options = [String]()
        var selectedOptions = [String]()
        var allowsMultipleSelections = false
        
        switch self.selectedSection! {
        case .ministry:
            options = ["Cru Cal Poly"]
            if let ministry = self.filterOptions?.ministry {
                selectedOptions = [ministry]
            }
        case .days:
            options = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
            if let days = self.filterOptions?.days {
                selectedOptions = days
            }
            allowsMultipleSelections = true
        case .hours:
            break
        case .grade:
            options = ["Freshman", "Sophomore", "Junior", "Senior+"]
            if let grade = self.filterOptions?.grade {
                selectedOptions = [grade]
            }
        case .gender:
            options = ["Male", "Female"]
            if let gender = self.filterOptions?.gender {
                selectedOptions = [gender]
            }
        }
        
        let selectionVC = SelectionViewController(options: options, selectedOptions: selectedOptions, allowsMultipleSelections: allowsMultipleSelections)
        self.present(selectionVC, animated: true, completion: nil)
    }
}

extension FilterCommunityGroupsTableViewController: SelectionViewControllerDelegate {
    func selectedOptions(_ selectedOptions: [String]) {
        switch self.selectedSection! {
        case .ministry:
            self.filterOptions?.ministry = selectedOptions.first!
        case .days:
            self.filterOptions?.days = selectedOptions
        case .hours:
            break
        case .grade:
            self.filterOptions?.grade = selectedOptions.first!
        case .gender:
            self.filterOptions?.gender = selectedOptions.first!
        }
        
        self.tableView.reloadData()
    }
}

