//
//  CampusesTableViewController.swift
//  Cru
//
//  Created by Max Crane on 11/25/15.
//  Copyright © 2015 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import MRProgress
import DZNEmptyDataSet


class MinistryTableViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource  {
    var ministries = [Ministry]()            //list of ALL ministries
    var subscribedCampuses = [Campus]()      //list of subscribed campuses
    var ministryMap = [Campus: [Ministry]]() //map of all subscribed campsuses to their respective ministries
    var prevMinistries = [Ministry]()        //list of previously subscribed ministries (saved on device)
    var totalMegsUsed = 0.0
    var hasConnection = true
    var emptyTableImage: UIImage!
    var onboarding = false
    @IBOutlet var table: UITableView!
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        if onboarding == false {
            return emptyTableImage
        }
        else {
            return nil
        }
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        if onboarding == true {
            if hasConnection == false {
                let attributes = [ NSFontAttributeName: UIFont(name: Config.fontName, size: 18)!, NSForegroundColorAttributeName: UIColor.blackColor()]
                return NSAttributedString(string: "No connection found. Please try again later.", attributes: attributes)
            }
            else {
                let attributes = [ NSFontAttributeName: UIFont(name: Config.fontName, size: 18)!, NSForegroundColorAttributeName: UIColor.blackColor()]
                return NSAttributedString(string: "You must select a campus in order to subscribe to a ministry.", attributes: attributes)
            }
        }
        else {
            return nil
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        subscribedCampuses = CruClients.getSubscriptionManager().loadCampuses()
        
        prevMinistries = CruClients.getSubscriptionManager().loadMinistries()

        navigationItem.title = "Ministry Subscriptions"
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(MinistryTableViewController.saveMinistriesToDevice))
        self.navigationItem.leftBarButtonItem = newBackButton
        if self.navigationController != nil{
            self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        }
        
        
        CruClients.getServerClient().getData(.Ministry, insert: insertMinistry, completionHandler: {success in
            // TODO: handle failure
            self.reloadData()
            CruClients.getServerClient().checkConnection(self.finishConnectionCheck)
        })
        self.tableView.reloadData()	
    }
    
    func insertRide(dict: NSDictionary){}
    
    func finishConnectionCheck(connected: Bool){
        if(!connected){
            self.emptyTableImage = UIImage(named: Config.noConnectionImageName)
            hasConnection = false
        }
        else{
            self.emptyTableImage = UIImage(named: Config.noCampusesImage)
            
            hasConnection = true
        }
        self.table.emptyDataSetDelegate = self
        self.table.emptyDataSetSource = self
        self.tableView.reloadData()
    }
    
    func reloadData(){
        //TODO: handler failure
        
        //super.viewDidLoad()
        subscribedCampuses = CruClients.getSubscriptionManager().loadCampuses()
        prevMinistries = CruClients.getSubscriptionManager().loadMinistries()
                
        refreshMinistryMap()
        self.tableView.reloadData()
    }
    
    func emptyDataSet(scrollView: UIScrollView!, didTapView view: UIView!) {
        if(hasConnection == false){
            CruClients.getServerClient().checkConnection(self.finishConnectionCheck)
        }
    }
    
    
    func refreshMinistryMap() {
        ministryMap.removeAll()
        for ministry in ministries {
            for campus in subscribedCampuses {
                if(CruClients.getSubscriptionManager().campusContainsMinistry(campus, ministry: ministry)) {
                    if(prevMinistries.contains(ministry)){
                        ministry.feedEnabled = true
                    }
                    else{
                        ministry.feedEnabled = false
                    }
                    
                    
                    if (ministryMap[campus] == nil){
                        ministryMap[campus] = [ministry]
                    }
                    else{
                        ministryMap[campus]!.insert(ministry, atIndex: 0)
                    }
                    
                }
            }
        }
    }
    
    
    func insertMinistry(dict : NSDictionary) {
        let newMinistry = Ministry(dict: dict)
        
        if(prevMinistries.contains(newMinistry)){
            newMinistry.feedEnabled = true
        }
        
        ministries.insert(newMinistry, atIndex: 0)
    }
    
    func saveMinistriesToDevice(){
        var subscribedMinistries = [Ministry]()
        
        for campus in subscribedCampuses{
            let campusMinistries = ministryMap[campus]
            if (campusMinistries != nil) {
                for ministry in campusMinistries! {
                    subscribedMinistries.append(ministry)
                }
            }
        }
        
        let update = CruClients.getSubscriptionManager().didMinistriesChange(subscribedMinistries)
        
        if (update) {
            MRProgressOverlayView.showOverlayAddedTo(self.view, animated: true)
            CruClients.getSubscriptionManager().saveMinistries(subscribedMinistries, updateGCM: true, handler: { (responses) in
                MRProgressOverlayView.dismissOverlayForView(self.view, animated: true, completion: {
                    let success = responses.reduce(true) {(result, cur) in result && cur.1 == true}
                    print("Was actually a success: \(success)")
                    self.leavePage(success)
                })
            })
        } else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func leavePage(success: Bool) {
        let title = success ? "Success" : "Failure"
        let message = success ? "Successfully subscribed/unsubscribed!" : "Something may have gone wrong..."
        let updateAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        updateAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {(thing) in
            self.navigationController?.popViewControllerAnimated(true)
        }))
        
        presentViewController(updateAlert, animated: true, completion: nil)
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return subscribedCampuses.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return subscribedCampuses[section].name
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let campus = subscribedCampuses[section]
        return ministryMap[campus] == nil ? 0 : ministryMap[campus]!.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("ministryCell", forIndexPath: indexPath) as! MinistryTableViewCell
        
            let ministry = getMinistryAtIndexPath(indexPath)
            cell.ministry = ministry
        
            if(ministry.feedEnabled == true){
                cell.accessoryType = .Checkmark
            }
            else{
                cell.accessoryType = .None
            }
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath){
            let ministry = getMinistryAtIndexPath(indexPath)
            
            if(cell.accessoryType == .Checkmark){
                cell.accessoryType = .None
                ministry.feedEnabled = false
            }
            else{
                cell.accessoryType = .Checkmark
                ministry.feedEnabled = true
            }
            
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: Config.fontName, size: 20)!
        header.textLabel?.textColor = UIColor.blackColor()
    }
    
    func getMinistryAtIndexPath(indexPath: NSIndexPath)->Ministry{
        let row = indexPath.row
        let section = indexPath.section
        return ministryMap[subscribedCampuses[section]]![row]
    }
    
    
    
    func asyncLoadMinistryImage(min: Ministry, imageView: UIImageView){
        //let downloadQueue = dispatch_queue_create("com.cru.downloadImage", nil)
        
        
        dispatch_async(dispatch_get_main_queue(), {
            
            if(min.imageData == nil){
                //let stream = NSInputStream(URL: NSURL(string: min.imageUrl)!)
                
                let data = NSData(contentsOfURL: NSURL(string: min.imageUrl)!)
                //self.totalMegsUsed += Double(data!.length)/1024.0/1024.0
                //    print("got it .... yiiissss \(Double(data!.length)/1024.0/1024.0)")
                //print("total: \(self.totalMegsUsed)")
                var image : UIImage?
                
                if data != nil{
                    min.imageData = data
                    image = UIImage(data: data!)!
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    imageView.contentMode = .ScaleAspectFit
                    
                    //alternate method of setting the image
                    //imageView.image = self.smallerImage(image!)
                    if(image != nil){
                        imageView.image = self.resizeImage(image!, newWidth: 150.0)
                    }
                    
                })
            }
        })
        
    }

    
    func smallerImage(image: UIImage)->UIImage{
        let size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.1, 0.1))
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
    
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //print("resized image: from \(oldWidth) to \(newWidth)")
        return newImage
    }
    
    
    
}
