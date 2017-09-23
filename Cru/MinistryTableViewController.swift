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
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        subscribedCampuses = CruClients.getSubscriptionManager().loadCampuses()
        
        prevMinistries = CruClients.getSubscriptionManager().loadMinistries()

        navigationItem.title = "Ministry Subscriptions"

        if self.navigationController != nil{
            self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.white]
        }
        
        //Check connection and load ministries
        CruClients.getServerClient().checkConnection(self.finishConnectionCheck)
       
    }
    
    func finishConnectionCheck(_ connected: Bool){
        if(!connected){
            hasConnection = false
            self.table.emptyDataSetDelegate = self
            self.table.emptyDataSetSource = self
            self.tableView.reloadData()
        }
        else{
            CruClients.getServerClient().getData(.Ministry, insert: insertMinistry, completionHandler: {success in
                // TODO: handle failure
                self.table.emptyDataSetDelegate = self
                self.table.emptyDataSetSource = self
                self.reloadData()
                
            })
            //self.emptyTableImage = UIImage(named: Config.noCampusesImage)
            
            hasConnection = true
        }
        
       
    }
    
    func reloadData(){
        //TODO: handler failure
        
        //super.viewDidLoad()
        subscribedCampuses = CruClients.getSubscriptionManager().loadCampuses()
        prevMinistries = CruClients.getSubscriptionManager().loadMinistries()
                
        refreshMinistryMap()
        self.tableView.reloadData()
    }
    
    // MARK: - Empty Data Set Functions
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        if onboarding == false {
            if !hasConnection {
                return UIImage(named: Config.noConnectionImageName)
            }
            else {
                return UIImage(named: Config.noCampusesImage)
            }
        }
        else {
            return nil
        }
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        if onboarding == true {
            if hasConnection == false {
                let attributes = [ NSFontAttributeName: UIFont(name: Config.fontName, size: 18)!, NSForegroundColorAttributeName: UIColor.black]
                return NSAttributedString(string: "No connection found. Please try again later.", attributes: attributes)
            }
            else {
                let attributes = [ NSFontAttributeName: UIFont(name: Config.fontName, size: 18)!, NSForegroundColorAttributeName: UIColor.black]
                return NSAttributedString(string: "You must select a campus in order to subscribe to a ministry.", attributes: attributes)
            }
        }
        else {
            return nil
        }
        
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
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
                        ministryMap[campus]!.insert(ministry, at: 0)
                    }
                    
                }
            }
        }
    }
    
    
    func insertMinistry(_ dict : NSDictionary) {
        let newMinistry = Ministry(dict: dict)
        
        if(prevMinistries.contains(newMinistry)){
            newMinistry.feedEnabled = true
        }
        
        ministries.insert(newMinistry, at: 0)
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
            MRProgressOverlayView.showOverlayAdded(to: self.view, animated: true)
            CruClients.getSubscriptionManager().saveMinistries(subscribedMinistries, updateFCM: true, handler: { (responses) in
                MRProgressOverlayView.dismissOverlay(for: self.view, animated: true, completion: {
                    let success = responses.reduce(true) {(result, cur) in result && cur.1 == true}
                    print("Was actually a success: \(success)")
                    self.leavePage(success)
                })
            })
        } else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func leavePage(_ success: Bool) {
        let title = success ? "Success" : "Failure"
        let message = success ? "Successfully subscribed/unsubscribed!" : "Something may have gone wrong..."
        let updateAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        if title == "Failure" {
            updateAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(thing) in
               _ = self.navigationController?.popViewController(animated: true)
            }))
            present(updateAlert, animated: true, completion: nil)
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table View Delegate Functions
    override func numberOfSections(in tableView: UITableView) -> Int {
        if hasConnection {
            return subscribedCampuses.count
        }
        else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return subscribedCampuses[section].name
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let campus = subscribedCampuses[section]
        return ministryMap[campus] == nil ? 0 : ministryMap[campus]!.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ministryCell", for: indexPath) as! MinistryTableViewCell
        
            let ministry = getMinistryAtIndexPath(indexPath)
            cell.ministry = ministry
        
            if(ministry.feedEnabled == true){
                cell.accessoryType = .checkmark
            }
            else{
                cell.accessoryType = .none
            }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath){
            let ministry = getMinistryAtIndexPath(indexPath)
            
            if(cell.accessoryType == .checkmark){
                cell.accessoryType = .none
                ministry.feedEnabled = false
            }
            else{
                cell.accessoryType = .checkmark
                ministry.feedEnabled = true
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: Config.fontBold, size: 20)!
        header.textLabel?.textColor = UIColor.black
    }
    
    func getMinistryAtIndexPath(_ indexPath: IndexPath)->Ministry{
        let row = indexPath.row
        let section = indexPath.section
        return ministryMap[subscribedCampuses[section]]![row]
    }
    
    
    
    func asyncLoadMinistryImage(_ min: Ministry, imageView: UIImageView){
        //let downloadQueue = dispatch_queue_create("com.cru.downloadImage", nil)
        
        
        DispatchQueue.main.async(execute: {
            
            if(min.imageData == nil){
                //let stream = NSInputStream(URL: NSURL(string: min.imageUrl)!)
                
                let data = try? Data(contentsOf: URL(string: min.imageUrl)!)
                //self.totalMegsUsed += Double(data!.length)/1024.0/1024.0
                //    print("got it .... yiiissss \(Double(data!.length)/1024.0/1024.0)")
                //print("total: \(self.totalMegsUsed)")
                var image : UIImage?
                
                if data != nil{
                    min.imageData = data
                    image = UIImage(data: data!)!
                }
                
                DispatchQueue.main.async(execute: {
                    imageView.contentMode = .scaleAspectFit
                    
                    //alternate method of setting the image
                    //imageView.image = self.smallerImage(image!)
                    if(image != nil){
                        imageView.image = self.resizeImage(image!, newWidth: 150.0)
                    }
                    
                })
            }
        })
        
    }

    
    func smallerImage(_ image: UIImage)->UIImage{
        let size = image.size.applying(CGAffineTransform(scaleX: 0.1, y: 0.1))
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
    
    func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //print("resized image: from \(oldWidth) to \(newWidth)")
        return newImage!
    }
    
    //MARK: Navigation
    
    @IBAction func saveToSettings(_ sender: UIBarButtonItem) {
        saveMinistriesToDevice()
        //dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelToSettings(_ sender: UIBarButtonItem) {
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    
    
    
}
