//
//  EditGroupInfoViewController.swift
//  Cru
//
//  Created by Erica Solum on 8/10/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import DropDown
import ImagePicker
//import AWSS3
import MRProgress

class EditGroupInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    var selectedImage: UIImage?
    var ministries = [Ministry]()
    var stringMinistries = [String]()
    var ministryTable = [String: String]()
    
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
        timeButton.setTitle(group.meetingTime, for: .normal)
        ministryButton.setTitle(group.parentMinistryName, for: .normal)
        descriptionView.text = group.desc
        if group.imgURL != "" {
            groupImage.load.request(with: group.imgURL)
        }
        
        //Get ministries
        createMinistryDictionary()

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
        
        MRProgressOverlayView.showOverlayAdded(to: self.view, animated: true)
        
        //Get new info
        group.dayOfWeek = dayButton.currentTitle!
        group.meetingTime = timeButton.currentTitle!.replacingOccurrences(of: " ", with: "")
        group.desc = descriptionView.text
        //group.parentMinistryID = ministryTable[ministryButton.currentTitle!]!
        group.imgURL = "\(Config.s3ImageURL)/\(Config.s3BucketName)/\(Config.s3ImageFolderURL)/\(group.id)-image.png"
        
        print("New group info: ")
        print("dayOfWeek: " + group.dayOfWeek)
        print("meetingTime: " + group.meetingTime)
        print("desc: " + group.desc)
        print("parentMinistryName: " + group.parentMinistryName)
        print("parentMinistryID: " + group.parentMinistryID)
        
        
        if let image = selectedImage {
            CruClients.getCommunityGroupUtils().patchGroup(self.group.id, params: [CommunityGroupKeys.dayOfWeek: self.group.dayOfWeek, CommunityGroupKeys.meetingTime: self.group.meetingTime ,CommunityGroupKeys.description: self.group.desc, CommunityGroupKeys.imageURL: self.group.imgURL], handler: self.handlePostResult)
            CruClients.getCommunityGroupUtils().uploadImage(self.group.id, image: UIImagePNGRepresentation(image)!, handler: self.handlePostResult)
            //self.uploadImage(with: UIImagePNGRepresentation(image)!)
        }
        else {
            //MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
            CruClients.getCommunityGroupUtils().patchGroup(self.group.id, params: [CommunityGroupKeys.dayOfWeek: self.group.dayOfWeek, CommunityGroupKeys.meetingTime: self.group.meetingTime ,CommunityGroupKeys.description: self.group.desc, CommunityGroupKeys.imageURL: self.group.imgURL, CommunityGroupKeys.ministry: self.group.parentMinistryID], handler: self.handlePostResult)
        }
    }
    
    func uploadImage(with data: Data) {
        //let transferUtility = AWSS3TransferUtility.default()
        //let expression = AWSS3TransferUtilityUploadExpression()
        //expression.progressBlock = progressBlock
        //var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
        
        /*completionHandler = { (task, error) -> Void in
            DispatchQueue.main.async(execute: {
                // Do something e.g. Alert a user for transfer completion.
                // On failed uploads, `error` contains the error object.
                if let error = error {
                    print("completion hander Error: \(error.localizedDescription)")
                }
                else {
                    print("Maybe we're finished?")
                    
                    MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
                    CruClients.getCommunityGroupUtils().patchGroup(self.group.id, params: [CommunityGroupKeys.dayOfWeek: self.group.dayOfWeek, CommunityGroupKeys.meetingTime: self.group.meetingTime ,CommunityGroupKeys.description: self.group.desc, CommunityGroupKeys.imageURL: self.group.imgURL], handler: self.handlePostResult)
                    CruClients.getCommunityGroupUtils().uploadImage(self.group.id, image: data, handler: self.handlePostResult)
                }
            })
        }*/
        
        
        /*transferUtility.uploadData(
            data,
            bucket: Config.s3BucketName,
            key: "\(group.id)-image.png",
            contentType: "image/png",
            expression: nil,
            completionHandler: completionHandler).continueWith { (task) -> AnyObject! in
                if let error = task.error {
                    print("Transfer utility Error: \(error.localizedDescription)")
                    
                    //self.statusLabel.text = "Failed"
                }
                
                if let _ = task.result {
                    //self.statusLabel.text = "Generating Upload File"
                    print("Upload Starting!")
                    // Do something with uploadTask.
                }
                
                return nil;
        }*/
    }
    
    func handlePostResult(_ newGroup: CommunityGroup?){

        if(newGroup != nil){
            print("Returned group: ")
            print("id: " + (newGroup?.id)!)
            print("dayOfWeek: " + (newGroup?.dayOfWeek)!)
            print("desc: " + (newGroup?.desc)!)
            print("imgURL: " + (newGroup?.imgURL)!)
            print("meetingTime: " + (newGroup?.meetingTime)!)
            print("parentMin: " + (newGroup?.parentMinistryID)!)
            
            
            let alert = UIAlertController(title: "Your community group was updated!", message: "", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(alert: UIAlertAction!) in
                self.saveGroupToLocalStorage()
            }))
            self.present(alert, animated: true, completion: nil)
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
        MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
        //self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    //Get ministry list from local storage
    //Create a dictionary with ministry id & name for easy lookup
    fileprivate func createMinistryDictionary() {
        ministries = CruClients.getSubscriptionManager().loadMinistries()
        
        for min in ministries {
            stringMinistries.append(min.name)
            print(min.name)
        }
        
        for ministry in ministries {
            ministryTable[ministry.name] = ministry.id
        }
        print(ministryTable)
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
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
        
        /*let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        present(imagePickerController, animated: true, completion: nil)*/
        
        /*let picker = UIImagePickerController()
        picker.delegate = self*/
    }
    
    
    
    //MARK: - UIImagePickerViewController Delegate Functions
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        //let croppedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        self.selectedImage = image
        self.groupImage.image = image
        
       /* if "public.image" == info[UIImagePickerControllerMediaType] as? String {
            let image: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            self.selectedImage = image
            print("Thingy mcthingerson")
            //self.uploadImage(with: UIImagePNGRepresentation(image)!)
        }*/
        
        
        dismiss(animated: true, completion: nil)
    }
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
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
        
        chooseTimeDropDown.bottomOffset = CGPoint(x: 0, y: timeButton.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        chooseTimeDropDown.dataSource = [
            "6:00 am", "6:30 am", "7:00 am", "7:30 am", "8:00 am", "8:30 am", "9:00 am", "9:30 am", "10:00 am", "10:30 am", "11:00 am", "11:30 am", "12:00 pm", "12:30 pm", "1:00 pm", "1:30 pm", "2:00 pm", "2:30 pm", "3:00 pm", "3:30 pm", "4:00 pm", "4:30 pm", "5:00 pm", "5:30 pm", "6:00 pm", "6:30pm", "7:00 pm", "7:30 pm", "8:00 pm", "8:30 pm", "9:00 pm", "9:30 pm", "10:00 pm"
        ]
        
        // Action triggered on selection
        chooseTimeDropDown.selectionAction = { [unowned self] (index, item) in
            self.timeButton.setTitle(item, for: .normal)
        }
    }
    
    func setupChooseMinistryDropDown() {
        chooseMinistryDropDown.anchorView = ministryButton
        
        chooseMinistryDropDown.bottomOffset = CGPoint(x: 0, y: ministryButton.bounds.height)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        chooseMinistryDropDown.dataSource = stringMinistries
        
        // Action triggered on selection
        chooseMinistryDropDown.selectionAction = { [unowned self] (index, item) in
            self.ministryButton.setTitle(item, for: .normal)
        }
    }
    
    func customizeDropDown() {
        let appearance = DropDown.appearance()
        
        appearance.cellHeight = 60
        appearance.backgroundColor = UIColor(white: 1, alpha: 1)
        appearance.selectionBackgroundColor = UIColor(red: 0.6494, green: 0.8155, blue: 1.0, alpha: 0.2)
        appearance.cornerRadius = 10
        appearance.shadowColor = UIColor(white: 0.6, alpha: 1)
        appearance.shadowOpacity = 0.9
        appearance.shadowRadius = 25
        appearance.animationduration = 0.25
        appearance.textColor = .darkGray
        
    }

}
