//
//  LeaderTabViewController.swift
//  Cru
//
//  Created by Erica Solum on 9/19/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import DZNEmptyDataSet
import MRProgress

class LeaderTabViewController: UITableViewController, IndicatorInfoProvider, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, ResourceDelegate {

    var noResultsString: NSAttributedString!
    var resources = [Resource]()
    var filteredResources = [Resource]()
    var hasConnection = false
    var emptyTableImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Make the line between cells invisible
        tableView.separatorStyle = .none
        tableView.backgroundColor = Colors.googleGray
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        NotificationCenter.default.addObserver(self, selector: #selector(searchRefresh), name: NSNotification.Name.init("searchRefresh"), object: nil)
        
        CruClients.getServerClient().checkConnection(self.finishConnectionCheck)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Leader tab will appear")
        self.resources = ResourceManager.sharedInstance.getLeaderResources()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Connection & Resource Loading
    //Test to make sure there is a connection then load resources
    func finishConnectionCheck(_ connected: Bool){
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
        
        if(!connected){
            hasConnection = false
            self.emptyTableImage = UIImage(named: Config.noConnectionImageName)
            //self.tableView.emptyDataSetDelegate = self
            //self.tableView.emptyDataSetSource = self
            self.tableView.reloadData()
            //hasConnection = false
        }else{
            hasConnection = true
            
            MRProgressOverlayView.showOverlayAdded(to: self.view, animated: true)
            
            self.resources = ResourceManager.sharedInstance.getLeaderResources()
            self.tableView.reloadData()
            MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
        }
        
    }
    
    // MARK: - Pager Tab Whatever Delegate Functions
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "LEADERS")
    }
    
    // MARK: - Empty Data Set Functions
    
    /* Function for the empty data set */
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return emptyTableImage
    }
    
    /* Text for the empty search results data set*/
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        //Set up attribute string for empty search results
        let attributes = [ NSFontAttributeName: UIFont(name: Config.fontName, size: 18)!, NSForegroundColorAttributeName: UIColor.black]
        
        if hasConnection {
            if ResourceManager.sharedInstance.isSearchActivated() && ResourceManager.sharedInstance.getSearchPhrase() != ""{
                noResultsString = NSAttributedString(string: "No leader resources found with the phrase \"\(ResourceManager.sharedInstance.getSearchPhrase())\"", attributes: attributes)
            }
            else {
                noResultsString = NSAttributedString(string: "No leader resources found", attributes: attributes)
            }
        }
        
        return noResultsString
    }
    
    // MARK: - Table View Delegate Functions
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        /*if ResourceManager.sharedInstance.isSearchActivated() {
            return filteredResources.count
        }*/
        return resources.count
    }
    
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dateFormatString = "MMM d, yyyy"
        
        var res: Resource
        /*if ResourceManager.sharedInstance.isSearchActivated() {
            res = filteredResources[indexPath.row]
        }
        else {
            res = resources[indexPath.row]
        }*/
        
        res = resources[indexPath.row]
        
        //Should be refactored to be more efficient
        //Problem for a later dev
        switch (res.type!){
        case .Article:
            // Configure the cell...
            let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleTableViewCell", for: indexPath) as! ArticleTableViewCell
            if let date = res.date {
                cell.date.text = GlobalUtils.stringFromDate(date, format: dateFormatString)
            }
            else {
                cell.date.text = ""
            }
            
            if res.type == .Article && (res.url == nil || res.url.isEmpty) {
                cell.desc.text = ""
            } else {
                cell.desc.text = res.description
            }
            cell.title.text = res.title
            
            //Set up the cell's button for web view controller
            cell.tapAction = {(cell) in
                let vc = CustomWebViewController()
                if res.type == .Article && (res.url == nil || res.url.isEmpty) {
                    vc.html = res.description
                    vc.displayLocalHTML = true
                } else {
                    vc.urlString = res.url
                }
                vc.artTitle = res.title
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            cell.card.layer.shadowColor = UIColor.black.cgColor
            cell.card.layer.shadowOffset = CGSize(width: 0, height: 1)
            cell.card.layer.shadowOpacity = 0.25
            cell.card.layer.shadowRadius = 2
            
            return cell
        case .Video:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideoTableViewCell", for: indexPath) as! VideoTableViewCell
            cell.date.text = GlobalUtils.stringFromDate(res.date, format: dateFormatString)
            cell.desc.text = res.description
            cell.title.text = res.title
            
            
            cell.thumbnailView.image = #imageLiteral(resourceName: "video")
            cell.thumbnailView.contentMode = .scaleAspectFit
            
            cell.card.layer.shadowColor = UIColor.black.cgColor
            cell.card.layer.shadowOffset = CGSize(width: 0, height: 1)
            cell.card.layer.shadowOpacity = 0.25
            cell.card.layer.shadowRadius = 2
            return cell
            
        case .Audio:
            let newAud = Audio(id: res.id, title: res.title, url: res.url, date: res.date, tags: res.tags, restricted: res.restricted)
            newAud.prepareAudioFile()
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "AudioTableViewCell", for: indexPath) as! AudioTableViewCell
            
            cell.date.text = GlobalUtils.stringFromDate(res.date, format: dateFormatString)
            cell.title.text = res.title
            //cell.audioString = aud.url
            cell.audio = newAud
            
            cell.card.layer.shadowColor = UIColor.black.cgColor
            cell.card.layer.shadowOffset = CGSize(width: 0, height: 1)
            cell.card.layer.shadowOpacity = 0.25
            cell.card.layer.shadowRadius = 2
            
            return cell
        }
     }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var res: Resource
        /*if ResourceManager.sharedInstance.isSearchActivated() {
            res = filteredResources[indexPath.row]
        }
        else {
            res = resources[indexPath.row]
        }*/
        res = resources[indexPath.row]
        
        if res.type == .Article || res.type == .Video {
            let vc = CustomWebViewController()
            if res.type == .Article && (res.url == nil || res.url.isEmpty) {
                vc.html = res.description
                vc.displayLocalHTML = true
            } else {
                vc.urlString = res.url
            }
            vc.artTitle = res.title
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
    }
    
    // MARK: - Resource Delegate Functions
    
    func resourcesLoaded(_ loaded: Bool) {
        self.resources = ResourceManager.sharedInstance.getLeaderResources()
        self.tableView.reloadData()
    }
    
    func refreshData() {
        self.resources = ResourceManager.sharedInstance.getLeaderResources()
        self.tableView.reloadData()
    }
    
    //Refresh table when search is done
    func searchRefresh(_ notification: NSNotification) {
        self.resources = ResourceManager.sharedInstance.getLeaderResources()
        self.tableView.reloadData()
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
