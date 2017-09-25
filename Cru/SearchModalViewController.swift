//
//  SearchModalViewController.swift
//  Cru
//
//  Created by Erica Solum on 9/8/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class SearchModalViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Properties
    let inactiveGray = UIColor(red: 149/225, green: 147/225, blue: 145/225, alpha: 1.0)
    var parentVC: ResourcesViewController?
    
    @IBOutlet weak var searchField: UITextField?
    @IBOutlet weak var searchLine: UIView?
    @IBOutlet weak var contentView: UIView?
    
    @IBOutlet weak var resetButton: UIButton?
    @IBOutlet weak var resourceTagTable: ResourceTagTableView?
    var tags = [ResourceTag]()
    var filteredTags = [ResourceTag]()
    var prevSearchPhrase = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Set the text field's delegate so we can do stuff to it
        searchField?.delegate = self
        //Set the corner radius of the modal
        contentView?.layer.cornerRadius = 10
        
        //Set the tag table delegate
        resourceTagTable?.delegate = self
        resourceTagTable?.dataSource = self
        
        
        
        //Get tags
        tags = ResourceManager.sharedInstance.getResourceTags()
        if ResourceManager.sharedInstance.isSearchActivated() {
            filteredTags = ResourceManager.sharedInstance.getFilteredTags()
            prevSearchPhrase = ResourceManager.sharedInstance.getSearchPhrase()
        }
        
        //If a search query is still active, set the text field text to match
        searchField?.text = prevSearchPhrase
        
        
        if prevSearchPhrase == "" {
            resetButton?.isHidden = true
        }
        
        //self.view.backgroundColor = UIColor.clear
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Actions
    @IBAction func closeModal(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetSearch(_ sender: UIButton) {
        resetButton?.isHidden = true
        filteredTags = tags
        prevSearchPhrase = ""
        searchField?.text = ""
        resourceTagTable?.reloadData()
        
        parentVC?.searchActivated = false
        parentVC?.searchPhrase = ""
        parentVC?.tableView.reloadData()
    }
    
    
    @IBAction func applyFilters(_ sender: UIButton) {
        //Get chosen tags
        filteredTags = [ResourceTag]()
        let cells = resourceTagTable?.visibleCells as! [ResourceTagTableViewCell]
        
        for cell in cells {
            
            if cell.checkbox.isChecked == true {
                filteredTags.append(cell.resourceTag)
            }
        }
        
        if searchField != nil && searchField!.hasText {
            parentVC?.applyFilters(filteredTags, searchText: searchField!.text)
        }
        else {
            parentVC?.applyFilters(filteredTags, searchText: nil)
        }

        self.dismiss(animated: true, completion: {})
    }
    
    //MARK: Text Field Delegate Functions
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 0.5, animations: {
            self.searchLine?.backgroundColor = CruColors.lightBlue
        })
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 0.5, animations: {
            self.searchLine?.backgroundColor = self.inactiveGray
        })
        return true
    }
    
    /*func adaptivePresentationStyleForPresentationController(_ controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.currentContext
    }*/
    
    //MARK: Table View Delegate Methods
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResourceTagTableViewCell", for: indexPath) as! ResourceTagTableViewCell
        
        let tag = tags[indexPath.row]
        cell.title.text = tag.title
        cell.resourceTag = tag
        
        if ResourceManager.sharedInstance.isSearchActivated() {
            if !filteredTags.contains(where: {tag.id == $0.id}) {
                
                cell.checkbox.isChecked = false
                cell.setUnchecked()
            }
        }
        else {
            cell.setChecked()
            cell.checkbox.isChecked = true
        }
        //Restore the settings from the last search
        /*if filteredTags.count != tags.count {
            if !filteredTags.contains(where: {tag.id == $0.id}) {
                
                cell.checkbox.isChecked = false
                cell.setUnchecked()
            }
        }
        else {
            cell.setChecked()
            cell.checkbox.isChecked = true
        }*/
        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
