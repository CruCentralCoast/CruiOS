//
//  VideosTabViewController.swift
//  Cru
//
//  Created by Erica Solum on 9/19/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import DZNEmptyDataSet
import MRProgress

class VideosTabViewController: UITableViewController, ResourceDelegate, IndicatorInfoProvider, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    // MARK: - Properties
    var videos = [Video]()
    var filteredVideos = [Video]()
    var hasConnection = true
    var emptyTableImage: UIImage?
    //var searchActivated = false
    //var searchPhrase: String?
    var noResultsString: NSAttributedString!
    var memoryWarning = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Make the line between cells invisible
        tableView.separatorStyle = .none
        tableView.backgroundColor = Colors.googleGray
        //tableView.rowHeight = UITableViewAutomaticDimension
        //tableView.estimatedRowHeight = 180
        
        CruClients.getServerClient().checkConnection(self.finishConnectionCheck)
        
        //Infinite scroll stuff
        // change indicator view style to white
        self.tableView.infiniteScrollIndicatorStyle = .white
        
        // Add infinite scroll handler
        self.tableView.addInfiniteScroll {(tableView) -> Void in
            
            //Only load if we're on the videos tab and user hasn't received the memory warning
            if !self.memoryWarning{
                ResourceManager.sharedInstance.loadYouTubeVideos(completionHandler: { (numNewVids, newVideos) in
                    let videoCount = self.videos.count
                    let (start, end) = (videoCount, newVideos.count + videoCount)
                    let indexPaths = (start..<end).map { return IndexPath(row: $0, section: 0) }
                    
                    // update data source
                    self.videos.append(contentsOf: newVideos)
                    
                    // make sure you update tableView before calling -finishInfiniteScroll
                    tableView.beginUpdates()
                    tableView.insertRows(at: indexPaths, with: .automatic)
                    tableView.endUpdates()
                    
                    // finish infinite scroll animation
                    tableView.finishInfiniteScroll()
                })
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        memoryWarning = true
    }
    
    // MARK: - Connection & Resource Loading
    //Test to make sure there is a connection then load resources
    func finishConnectionCheck(_ connected: Bool){
        if(!connected){
            hasConnection = false
            self.emptyTableImage = UIImage(named: Config.noConnectionImageName)
            self.tableView.emptyDataSetDelegate = self
            self.tableView.emptyDataSetSource = self
            self.tableView.reloadData()
            //hasConnection = false
        }else{
            hasConnection = true
            
            MRProgressOverlayView.showOverlayAdded(to: self.view, animated: true)
            self.videos = ResourceManager.sharedInstance.getVideos()
            self.tableView.reloadData()
            MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
            
            /*if ResourceManager.sharedInstance.hasAddedVideoDelegate() {
                self.videos = ResourceManager.sharedInstance.getVideos()
                self.tableView.reloadData()
                MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
            }
            else {
                ResourceManager.sharedInstance.addVideoDelegate(self)
            }*/
            
            
        }
        
    }

    // MARK: - Pager Tab Whatever Delegate Functions
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "VIDEOS")
    }
    
    // MARK: - Table View Delegate Functions
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var vid: Video
        if ResourceManager.sharedInstance.isSearchActivated() {
           vid = filteredVideos[indexPath.row]
        }
        else {
            vid = videos[indexPath.row]
        }
        
        let vc = CustomWebViewController()
        vc.urlString = vid.url
        vc.artTitle = vid.title
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ResourceManager.sharedInstance.isSearchActivated() {
            return filteredVideos.count
        }
        return videos.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dateFormatString = "MMM d, yyyy"
        
        var video: Video
        if ResourceManager.sharedInstance.isSearchActivated() {
            video = filteredVideos[indexPath.row]
        }
        else {
            video = videos[indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoTableViewCell", for: indexPath) as! VideoTableViewCell
        cell.date.text = GlobalUtils.stringFromDate(video.date, format: dateFormatString)
        cell.desc.text = video.abstract
        cell.title.text = video.title
        
        if video.videoURL != "" {
            cell.videoURL = video.videoURL
        }
        
        if video.thumbnailURL != "" {
            print("thumbnailURL: \(video.thumbnailURL)")
            let urlRequest = URLRequest(url: URL(string: video.thumbnailURL)!)
                CruClients.getImageUtils().getImageDownloader().download(urlRequest) { response in
                    if let image = response.result.value {
                        cell.thumbnailView.image = image
                    }
                }
            
            
            /*if let imageView = cell.thumbnailView {
                imageView.contentMode = .scaleAspectFit
            }
            if let url = video.thumbnailURL {
                // TODO: Find a way to load thumbnail without it crashing
                //cell.thumbnailView.load.request(with: url)
            }*/
        }
        else {
            //Adjust the spacing for title, date, & desc to be flush with card
            //cell.thumbnailView.isHidden = true
            //cell.stackLeadingSpace.constant = 10.0
            cell.thumbnailView.image = #imageLiteral(resourceName: "video")
            cell.thumbnailView.contentMode = .scaleAspectFit
        }
        
        cell.card.layer.shadowColor = UIColor.black.cgColor
        cell.card.layer.shadowOffset = CGSize(width: 0, height: 1)
        cell.card.layer.shadowOpacity = 0.25
        cell.card.layer.shadowRadius = 2
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
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
                
                noResultsString = NSAttributedString(string: "No videos found with the phrase \(ResourceManager.sharedInstance.getSearchPhrase())", attributes: attributes)
            }
            else {
                noResultsString = NSAttributedString(string: "No video resources found", attributes: attributes)
            }
        }
        return noResultsString
    }
    
    // MARK: - Resource Delegate Function
    func resourcesLoaded(_ loaded: Bool) {
        print("Notified video VC with resources loaded: \(loaded)")
        if loaded {
            self.videos = ResourceManager.sharedInstance.getVideos()
            self.tableView.reloadData()
            MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
        }
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
