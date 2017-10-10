//
//  AudioTabViewController.swift
//  Cru
//
//  Created by Erica Solum on 9/19/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import DZNEmptyDataSet
import MRProgress

class AudioTabViewController: UITableViewController, ResourceDelegate, IndicatorInfoProvider, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    // MARK: - Properties 
    var audioFiles = [Audio]()
    var filteredAudioFiles = [Audio]()
    var hasConnection = true
    var emptyTableImage: UIImage?
    //var searchActivated = false
    //var searchPhrase: String?
    var noResultsString: NSAttributedString!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Make the line between cells invisible
        tableView.separatorStyle = .none
        tableView.backgroundColor = Colors.googleGray
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        NotificationCenter.default.addObserver(self, selector: #selector(searchRefresh), name: NSNotification.Name.init("searchRefresh"), object: nil)
        
        CruClients.getServerClient().checkConnection(self.finishConnectionCheck)
        
        ResourceManager.sharedInstance.addAudioDelegate(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Audio tab will appear")
        self.reloadAudioFiles()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func reloadAudioFiles() {
        self.audioFiles = ResourceManager.sharedInstance.getAudio()
        self.audioFiles = self.audioFiles.filter { !$0.restricted }
        self.audioFiles.sort { $0.0.date > $0.1.date }
        self.tableView.reloadData()
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
            self.reloadAudioFiles()
            MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
        }
    }
    
    //Refresh table when search is done
    func searchRefresh(_ notification: NSNotification) {
        self.reloadAudioFiles()
    }
    
    // MARK: - Pager Tab Whatever Delegate Functions
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "AUDIO")
    }
    
    // MARK: - Table View Delegate Functions
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioFiles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioTableViewCell", for: indexPath) as! AudioTableViewCell
        
        let dateFormatString = "MMM d, yyyy"
        
        var aud: Audio
        /*if ResourceManager.sharedInstance.isSearchActivated() {
            aud = filteredAudioFiles[indexPath.row]
        }
        else {
            aud = audioFiles[indexPath.row]
        }*/
        
        aud = audioFiles[indexPath.row]
        
        cell.date.text = GlobalUtils.stringFromDate(aud.date, format: dateFormatString)
        cell.title.text = aud.title
        //cell.audioString = aud.url
        cell.audio = aud
        
        cell.card.layer.shadowColor = UIColor.black.cgColor
        cell.card.layer.shadowOffset = CGSize(width: 0, height: 1)
        cell.card.layer.shadowOpacity = 0.25
        cell.card.layer.shadowRadius = 2
     
        return cell
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
                noResultsString = NSAttributedString(string: "No audio resources found with the phrase \"\(ResourceManager.sharedInstance.getSearchPhrase())\"", attributes: attributes)
            }
            else {
                noResultsString = NSAttributedString(string: "No audio resources found", attributes: attributes)
            }
        }
        
        return noResultsString
    }
    
    // MARK: - Resource Delegate Function
    func resourcesLoaded(_ loaded: Bool) {
        print("Notified audio VC with resources loaded: \(loaded)")
        if loaded {
            self.reloadAudioFiles()
            MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
        }
    }

    func refreshData() {
        self.reloadAudioFiles()
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
