//
//  EditGroupInfoViewController.swift
//  Cru
//
//  Created by Erica Solum on 8/10/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import DropDown

class EditGroupInfoViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var leaderLabel: UILabel!
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var timeButton: UIButton!
    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var ministryButton: UIButton!
    @IBOutlet weak var groupImageLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var groupImage: UIImageView!
    @IBOutlet weak var editImageButton: UIButton!
    
    var group: CommunityGroup!
    
    //MARK: - DropDown's
    
    let chooseDayDropDown = DropDown()
    let chooseTimeDropDown = DropDown()
    let chooseMinistryDropDown = DropDown()
    
    lazy var dropDowns: [DropDown] = {
        return [
            self.chooseDayDropDown,
            self.chooseTimeDropDown,
            self.chooseMinistryDropDown
        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        leaderLabel.text = group.getLeaderString()
        dayButton.setTitle(group.dayOfWeek, for: .normal)
        timeButton.setTitle(group.stringTime, for: .normal)
        ministryButton.setTitle(group.parentMinistryName, for: .normal)
        descriptionView.text = group.desc

        // Set up drop down lists
        setupDropDowns()
        dropDowns.forEach { $0.dismissMode = .onTap }
        dropDowns.forEach { $0.direction = .any }
        
        // Set nav bar title
        navigationItem.title = "Edit Group"
        
        self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.white]
        
        //Add save button
        
        let saveButton = UIButton(type: .custom)
        saveButton.setTitle("Save", for: .normal)
        saveButton.frame = CGRect(x: 0, y: 0, width: 60, height: 30)
        saveButton.setTitleColor(CruColors.orange, for: .normal)
        //saveButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        saveButton.addTarget(self, action: #selector(self.saveGroupInfo), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: saveButton)
            
        self.navigationItem.setRightBarButton(item1, animated: true)
        
    }
    
    func saveGroupInfo() {
        //Get new info
        group.dayOfWeek = dayButton.currentTitle!
        group.stringTime = timeButton.currentTitle!
        group.desc = descriptionView.text
        group.parentMinistryName = ministryButton.currentTitle!
        
        
        
        // Send patch request to database
        //CruClients.getCommunityGroupUtils().patchGroup(group.id, params: params: [CommunityGroupKeys.: ride.passengers, RideKeys.radius: ride.radius, RideKeys.driverName: ride.driverName, RideKeys.direction: ride.direction, RideKeys.driverNumber: ride.driverNumber, RideKeys.time : ride.getTimeInServerFormat(), RideKeys.seats: ride.seats, LocationKeys.loc: [LocationKeys.postcode: ride.postcode, LocationKeys.state : ride.state, LocationKeys.street1 : ride.street, LocationKeys.city: ride.city, LocationKeys.country: ride.country]], handler: handlePostResult)
        
        CruClients.getCommunityGroupUtils().patchGroup(group.id, params: [CommunityGroupKeys.dayOfWeek: group.dayOfWeek, CommunityGroupKeys.description: group.desc], handler: handlePostResult)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func handlePostResult(_ newGroup: CommunityGroup?){

        if(newGroup != nil){
            print("Returned group: ")
            print("id: " + (newGroup?.id)!)
            print("dayOfWeek: " + (newGroup?.dayOfWeek)!)
            print("desc: " + (newGroup?.desc)!)
            print("imgURL: " + (newGroup?.imgURL)!)
            print("meetingTime: " + (newGroup?.stringTime)!)
            
            let alert = UIAlertController(title: "Your community group was updated!", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: {
                //self.navigationController?.popViewControllerAnimated(true)
            })
            saveGroupToLocalStorage()
            //self.ride = ride
            //self.table!.reloadData()
            //rideDetailVC?.ride = ride
            
            //for update in updateFunctions{
                //update()
            //}
        }
        else{
            let alert = UIAlertController(title: "Sorry, your community group could not be updated. Try again later.", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Oh darn", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func saveGroupToLocalStorage() {
        var comGroupArray = [CommunityGroup]()
        
        // Add new group to previously joined groups in local storage
        guard let prevGroupData = UserDefaults.standard.object(forKey: Config.CommunityGroupsStorageKey) as? NSData else {
            print(Config.CommunityGroupsStorageKey + " not found in UserDefaults")
            return
        }
        
        guard let prevGroupArray = NSKeyedUnarchiver.unarchiveObject(with: prevGroupData as Data) as? [CommunityGroup] else {
            print("Could not unarchive from groupData")
            return
        }
        
        for cGroup in prevGroupArray {
            if cGroup.id != group.id {
                comGroupArray.append(group)
            }
        }
        
        comGroupArray.append(group)
        let newGroupData = NSKeyedArchiver.archivedData(withRootObject: comGroupArray)
        UserDefaults.standard.set(newGroupData, forKey: Config.CommunityGroupsStorageKey)

    }
    
    //MARK: - Actions
    
    @IBAction func changeDay(_ sender: AnyObject) {
        chooseDayDropDown.show()
    }
    
    @IBAction func changeTime(_ sender: AnyObject) {
        chooseTimeDropDown.show()
    }
    
    @IBAction func changeMinistry(_ sender: AnyObject) {
        chooseMinistryDropDown.show()
    }
    
    @IBAction func editPressed(_ sender: UIButton) {
    }
    
    //MARK: - DropDowns Setup
    
    func setupDropDowns() {
        setupChooseDayDropDown()
        setupChooseTimeDropDown()
        setupChooseMinistryDropDown()
        customizeDropDown()
    }
    
    func setupChooseDayDropDown() {
        chooseDayDropDown.anchorView = dayButton
        
        // Will set a custom with instead of anchor view width
        //		dropDown.width = 100
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        chooseDayDropDown.bottomOffset = CGPoint(x: 0, y: dayButton.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        chooseDayDropDown.dataSource = [
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday",
            "Saturday",
            "Sunday"
        ]
        
        // Action triggered on selection
        chooseDayDropDown.selectionAction = { [unowned self] (index, item) in
            self.dayButton.setTitle(item, for: .normal)
        }
        
        // Action triggered on dropdown cancelation (hide)
        //		dropDown.cancelAction = { [unowned self] in
        //			// You could for example deselect the selected item
        //			self.dropDown.deselectRowAtIndexPath(self.dropDown.indexForSelectedRow)
        //			self.actionButton.setTitle("Canceled", forState: .Normal)
        //		}
        
        // You can manually select a row if needed
        //		dropDown.selectRowAtIndex(3)
    }
    
    func setupChooseTimeDropDown() {
        chooseTimeDropDown.anchorView = dayButton
        
        // Will set a custom with instead of anchor view width
        //		dropDown.width = 100
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        chooseTimeDropDown.bottomOffset = CGPoint(x: 0, y: timeButton.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        chooseTimeDropDown.dataSource = [
            "6:00 am", "6:30 am", "7:00 am", "7:30 am", "8:00 am", "8:30 am", "9:00 am", "9:30 am", "10:00 am", "10:30 am", "11:00 am", "11:30 am", "12:00 pm", "12:30 pm", "1:00 pm", "1:30 pm", "2:00 pm", "2:30 pm", "3:00 pm", "3:30 pm", "4:00 pm", "4:30 pm", "5:00 pm", "5:30 pm", "6:00 pm", "6:30pm", "7:00 pm", "7:30 pm", "8:00 pm", "8:30 pm", "9:00 pm", "9:30 pm", "10:00 pm"
        ]
        
        // Action triggered on selection
        chooseTimeDropDown.selectionAction = { [unowned self] (index, item) in
            self.timeButton.setTitle(item, for: .normal)
        }
        
        // Action triggered on dropdown cancelation (hide)
        //		dropDown.cancelAction = { [unowned self] in
        //			// You could for example deselect the selected item
        //			self.dropDown.deselectRowAtIndexPath(self.dropDown.indexForSelectedRow)
        //			self.actionButton.setTitle("Canceled", forState: .Normal)
        //		}
        
        // You can manually select a row if needed
        //		dropDown.selectRowAtIndex(3)
    }
    
    func setupChooseMinistryDropDown() {
        chooseMinistryDropDown.anchorView = ministryButton
        
        // Will set a custom with instead of anchor view width
        //		dropDown.width = 100
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
        chooseMinistryDropDown.bottomOffset = CGPoint(x: 0, y: ministryButton.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        chooseMinistryDropDown.dataSource = [
            "Ministry 1",
            "Ministry 2",
            "Ministry 3",
            "Ministry 4"
        ]
        
        // Action triggered on selection
        chooseMinistryDropDown.selectionAction = { [unowned self] (index, item) in
            self.ministryButton.setTitle(item, for: .normal)
        }
        
        // Action triggered on dropdown cancelation (hide)
        //		dropDown.cancelAction = { [unowned self] in
        //			// You could for example deselect the selected item
        //			self.dropDown.deselectRowAtIndexPath(self.dropDown.indexForSelectedRow)
        //			self.actionButton.setTitle("Canceled", forState: .Normal)
        //		}
        
        // You can manually select a row if needed
        //		dropDown.selectRowAtIndex(3)
    }
    
    func customizeDropDown() {
        let appearance = DropDown.appearance()
        
        appearance.cellHeight = 60
        appearance.backgroundColor = UIColor(white: 1, alpha: 1)
        appearance.selectionBackgroundColor = UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2)
        //		appearance.separatorColor = UIColor(white: 0.7, alpha: 0.8)
        appearance.cornerRadius = 10
        appearance.shadowColor = UIColor(white: 0.6, alpha: 1)
        appearance.shadowOpacity = 0.9
        appearance.shadowRadius = 25
        appearance.animationduration = 0.25
        appearance.textColor = .darkGray
        //		appearance.textFont = UIFont(name: "Georgia", size: 14)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
