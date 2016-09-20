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
        
        //If a search query is still active, set the text field text to match
        searchField?.text = prevSearchPhrase
        
        if prevSearchPhrase == "" {
            resetButton?.hidden = true
        }
        
        self.view.backgroundColor = UIColor.clearColor()
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Actions
    @IBAction func resetSearch(sender: UIButton) {
        resetButton?.hidden = true
        filteredTags = tags
        prevSearchPhrase = ""
        searchField?.text = ""
        resourceTagTable?.reloadData()
        
        parentVC?.searchActivated = false
        parentVC?.searchPhrase = ""
        parentVC?.tableView.reloadData()
    }
    
    
    @IBAction func applyFilters(sender: UIButton) {
        //Get chosen tags
        filteredTags = [ResourceTag]()
        let cells = resourceTagTable?.visibleCells as! [ResourceTagTableViewCell]
        
        for cell in cells {
            
            if cell.checkbox.isChecked == true {
                filteredTags.append(cell.resourceTag)
            }
        }
        
        if searchField != nil && searchField!.hasText() {
            parentVC?.applyFilters(filteredTags, searchText: searchField!.text)
        }
        else {
            parentVC?.applyFilters(filteredTags, searchText: nil)
        }

        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    //MARK: Text Field Delegate Functions
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        UIView.animateWithDuration(0.5, animations: {
            self.searchLine?.backgroundColor = CruColors.lightBlue
        })
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        UIView.animateWithDuration(0.5, animations: {
            self.searchLine?.backgroundColor = self.inactiveGray
        })
        return true
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.OverCurrentContext
    }
    
    //MARK: Table View Delegate Methods
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 30
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ResourceTagTableViewCell", forIndexPath: indexPath) as! ResourceTagTableViewCell
        
        let tag = tags[indexPath.row]
        cell.title.text = tag.title
        cell.resourceTag = tag
        
        //Restore the settings from the last search
        if filteredTags.count != tags.count {
            if !filteredTags.contains({tag.id == $0.id}) {
                
                cell.checkbox.isChecked = false
                cell.setUnchecked()
            }
        }
        else {
            cell.setChecked()
            cell.checkbox.isChecked = true
        }
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
