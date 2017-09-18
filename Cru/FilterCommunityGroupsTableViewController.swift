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
        var ministries: [String]
        var days: [String]
        var time: Date?
        var grades: [String]
        var gender: String?
    }
    
    fileprivate enum Row: Int {
        case ministries
        case days
        case time
        case grades
        case gender
        
        var title: String {
            switch self {
            case .ministries: return "Ministries"
            case .days: return "Days Available"
            case .time: return "Time Available"
            case .grades: return "Grade Level"
            case .gender: return "Gender"
            }
        }
        
        var options: [String] {
            switch self {
            case .ministries: return CruClients.getSubscriptionManager().loadMinistries().map { $0.name }
            case .days: return ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
            case .time: return []
            case .grades: return ["Freshman", "Sophomore", "Junior", "Senior+"]
            case .gender: return ["Male", "Female"]
            }
        }
    }
    
    fileprivate let rows: [Row] = [.ministries, .days, /*.time,*/ .grades, .gender]
    fileprivate var selectedRow: Row?
    
    fileprivate var filterOptions: FilterOptions
    var filterDelegate: FilterCommunityGroupsDelegate?
    
    init(options: FilterOptions? = nil) {
        self.filterOptions = options ?? FilterOptions(ministries: [], days: [], time: nil, grades: [], gender: nil)
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure nav bar
        self.title = "Filter"
        self.navigationController?.navigationBar.tintColor = CruColors.yellow
        let filterButton = UIBarButtonItem(title: "Apply", style: .done, target: self, action: #selector(self.applyFilter))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancel))
        self.navigationItem.rightBarButtonItem = filterButton
        self.navigationItem.leftBarButtonItem = cancelButton
        
        // Configure tableView
        self.tableView.registerNib(FilterCell.self)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
    }
    
    @objc func applyFilter() {
        self.dismiss(animated: true, completion: nil)
        self.filterDelegate?.applyFilter(options: self.filterOptions)
    }
    
    @objc func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func presentSelectionViewController(options: [String], selectedOptions: [String] = [], allowsMultipleSelections: Bool = false) {
        let selectionVC = SelectionViewController(options: options, selectedOptions: selectedOptions, allowsMultipleSelections: allowsMultipleSelections)
        selectionVC.delegate = self
        self.navigationController?.pushViewController(selectionVC, animated: true)
    }
    
    func presentTimePicker() {
        TimePicker.pickTime(self)
    }
    
    @objc func datePicked(_ date: Date) {
        self.filterOptions.time = date
        self.tableView.reloadData()
    }
}

extension FilterCommunityGroupsTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return 1//2
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(FilterCell.self, for: indexPath)
        let index = indexPath.section + indexPath.row
//        if indexPath.section >= 2 {
//            index += 1
//        }
        
        let row = self.rows[index]
        var detailText = "All"
        switch row {
        case .ministries:
            if !self.filterOptions.ministries.isEmpty {
                detailText = self.filterOptions.ministries.joined(separator: ", ")
            }
        case .days:
            if !self.filterOptions.days.isEmpty {
                detailText = self.filterOptions.days.joined(separator: ", ")
            }
        case .time:
            if let time = self.filterOptions.time {
                let formatter = DateFormatter()
                formatter.dateFormat = "h:mm a"
                let timeString = formatter.string(from: time)
                detailText = "After \(timeString)"
            }
        case .grades:
            if !self.filterOptions.grades.isEmpty {
                detailText = self.filterOptions.grades.joined(separator: ", ")
            }
        case .gender:
            if let gender = self.filterOptions.gender {
                detailText = gender
            }
        }
        cell.titleLabel.text = row.title
        cell.detailLabel.text = detailText
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.section + indexPath.row
//        if indexPath.section >= 2 {
//            index += 1
//        }
        
        self.selectedRow = self.rows[index]
        
        let options = self.selectedRow?.options ?? []
        var selectedOptions = [String]()
        
        switch self.selectedRow! {
        case .ministries:
            selectedOptions = self.filterOptions.ministries
            let allowsMultipleSelections = selectedOptions.count > 1 ? true : false
            self.presentSelectionViewController(options: options, selectedOptions: selectedOptions, allowsMultipleSelections: allowsMultipleSelections)
        case .days:
            selectedOptions = self.filterOptions.days
            self.presentSelectionViewController(options: options, selectedOptions: selectedOptions, allowsMultipleSelections: true)
        case .time:
            self.presentTimePicker()
        case .grades:
            selectedOptions = self.filterOptions.grades
            self.presentSelectionViewController(options: options, selectedOptions: selectedOptions)
        case .gender:
            if let gender = self.filterOptions.gender {
                selectedOptions = [gender]
            }
            self.presentSelectionViewController(options: options, selectedOptions: selectedOptions)
        }
    }
}

extension FilterCommunityGroupsTableViewController: SelectionViewControllerDelegate {
    func selectedOptions(_ selectedOptions: [String]) {
        switch self.selectedRow! {
        case .ministries:
            self.filterOptions.ministries = selectedOptions
        case .days:
            self.filterOptions.days = selectedOptions
        case .time:
            break
        case .grades:
            self.filterOptions.grades = selectedOptions
        case .gender:
            self.filterOptions.gender = selectedOptions.first ?? nil
        }
        
        self.tableView.reloadData()
    }
}

protocol FilterCommunityGroupsDelegate {
    func applyFilter(options: FilterCommunityGroupsTableViewController.FilterOptions)
}
