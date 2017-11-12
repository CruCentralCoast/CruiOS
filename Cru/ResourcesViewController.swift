 //
//  ResourcesViewController.swift
//  Cru
//  Formats and displays the resources in the Cru database as cards. Handles actions for full-screen view.
//
//  Created by Erica Solum on 2/18/15.
//  Copyright © 2015 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire
import HTMLReader
import MRProgress
import DZNEmptyDataSet
import ReadabilityKit

let InitialCount = 20
let PageSize = 8

class ResourcesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, SWRevealViewControllerDelegate, UIViewControllerTransitioningDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UIPopoverPresentationControllerDelegate {
    //MARK: Properties
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectorBar: UITabBar!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    
    var serverClient: ServerProtocol
    var resources = [Resource]()
    var tags = [ResourceTag]()
    var overlayRunning = false
    var currentType = ResourceType.Article
    
    var articles = [Article]()
    var audioFiles = [Audio]()
    var videos = [Video]()
    var newVideos = [Video]()
    var filteredArticles = [Article]()
    var filteredAudioFiles = [Audio]()
    var filteredVideos = [Video]()
    var selectedRow = -1
    var selectedVid: Video?
    
    var filteredResources = [Resource]()
    
    var parser: Readability?
    var audioPlayer:AVAudioPlayer!
    
    var videosArray: Array<Dictionary<NSObject, AnyObject>> = []
    var nextPageToken = ""
    var pageNum = 1
    let dimLevel: CGFloat = 0.1
    let dimSpeed: Double = 0.5
    var searchActivated = false
    var scrolling = false
    var modalActive = false {
        didSet {
            if modalActive == true {
                searchButton.isEnabled = false
            }
            else {
                searchButton.isEnabled = true
            }
        }
    }
    var isLeader = false
    var filteredTags = [ResourceTag]()
    var searchPhrase = ""
    var hasConnection = true
    var emptyTableImage: UIImage!
    var numUploads: Int!
    var numNewVideos: Int! // The number of new youtube videos from infinite scrolling
    var urlString: String!
    var noResultsString: NSAttributedString!
    var verticalContentOffset: CGFloat!
    var videoCardHeight: CGFloat!
    var memoryWarning = false
    
    //Call this constructor in testing with a fake serverProtocol
    init?(serverProtocol: ServerProtocol, _ coder: NSCoder? = nil) {
        //super.init(coder: NSCoder)
        self.serverClient = serverProtocol
    
        if let coder = coder {
            super.init(coder: coder)
        }
        else {
            super.init()
        }
        
    }

    required convenience init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        self.init(serverProtocol: CruClients.getServerClient(), aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        GlobalUtils.setupViewForSideMenu(self, menuButton: menuButton)

        selectorBar.selectedItem = selectorBar.items![0]
        self.tableView.delegate = self
        
        //Make the line between cells invisible
        tableView.separatorColor = UIColor.clear
        
        CruClients.getServerClient().checkConnection(self.finishConnectionCheck)
        
        
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = Colors.googleGray
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        videoCardHeight = 0
        
        //Set the nav title
        navigationItem.title = "Resources"
        
        self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.white]
        
        selectorBar.tintColor = UIColor.white
        
        
        //Infinite scroll stuff
        // change indicator view style to white
        self.tableView.infiniteScrollIndicatorStyle = .white
        
        // Add infinite scroll handler
        self.tableView.addInfiniteScroll {(tableView) -> Void in
            
            //Only load if we're on the videos tab and user hasn't received the memory warning
            if self.currentType == .Video && !self.memoryWarning{
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
            else if self.currentType == .Article {
                self.articles = ResourceManager.sharedInstance.getArticles()
                tableView.reloadData()
                tableView.finishInfiniteScroll()
            }

        }
        
        //log Event view loaded to Firebase Analytics
        Analytics.logEvent("Resource_view_loaded", parameters: nil)
        
        
        // load initial data
        //tableView.beginInfiniteScroll(true)
        
        /* Uncomment this for a later release*/
        //addLeaderTab()

    }
    
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
            overlayRunning = true
            
            // TODO: Call Resource Manager here instead of making call to server directly
            
            ResourceManager.sharedInstance.loadResources({ success in
                /*self.articles = articles
                self.audioFiles = audioFiles
                self.videos = videos
                self.tableView.reloadData()
                MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)*/
            })
            
            //serverClient.getData(DBCollection.Resource, insert: insertResource, completionHandler: getVideosForChannel)
            //serverClient.getData(DBCollection.Resource, insert: insertResource, completionHandler: finished)
            
            //Also get resource tags and store them
            serverClient.getData(DBCollection.ResourceTags, insert: insertResourceTag, completionHandler: {_ in
                //Hide the community leader tag if the user isn't logged in
                if GlobalUtils.loadString(Config.userID) == "" && GlobalUtils.loadBool(UserKeys.isCommunityGroupLeader){
                    let index = self.tags.index(where: {$0.title == "Leader (login required)"})
                    self.tags.remove(at: index!)
                    
                }
            })
        }
        
    }
    
    /* Don't load anymore youtube resources */
    override func didReceiveMemoryWarning() {
        memoryWarning = true
    }
    
    func doNothing(_ success: Bool) {
        
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
            if searchActivated && searchPhrase != ""{
                switch (currentType){
                case .Article:
                    noResultsString = NSAttributedString(string: "No articles found with the phrase \(searchPhrase)", attributes: attributes)
                case .Audio:
                    noResultsString = NSAttributedString(string: "No audio resources found with the phrase \(searchPhrase)", attributes: attributes)
                case .Video:
                    noResultsString = NSAttributedString(string: "No videos found with the phrase \(searchPhrase)", attributes: attributes)
                }
                
            }
            else {
                switch (currentType){
                case .Article:
                    noResultsString = NSAttributedString(string: "No article resources found", attributes: attributes)
                case .Audio:
                    noResultsString = NSAttributedString(string: "No audio resources found", attributes: attributes)
                case .Video:
                    noResultsString = NSAttributedString(string: "No video resources found", attributes: attributes)
                }
            }
            
            
        }
        
        return noResultsString
    }
    
    
    
    
    // MARK: - Tab Bar Functions
    //Code for the bar at the top of the view for filtering resources
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        var newType: ResourceType
        //var oldTypeCount = 0
        var newTypeCount = 0
        
        //print("Selecting item: \(item.title)")
        
        switch (item.title!){
        case "Articles":
            newType = ResourceType.Article
            newTypeCount = articles.count
        case "Audio":
            newType = ResourceType.Audio
            newTypeCount = audioFiles.count
        case "Videos":
            newType = ResourceType.Video
            newTypeCount = videos.count
        default :
            newType = ResourceType.Article
            newTypeCount = articles.count
        }
        
        /*switch (currentType){
        case .Article:
            oldTypeCount = articles.count
        case .Audio:
            oldTypeCount = audioFiles.count
        case .Video:
            oldTypeCount = videos.count
        }*/
        
        
        if(newType == currentType){
            return
        }
        else{
            currentType = newType
        }
        
        //let indexPath = NSIndexPath(item: 0, section: 0)
        //self.tableView.scrollToRow(at: indexPath as IndexPath, at: UITableViewScrollPosition.middle, animated: true)
        self.tableView.reloadData()
    }
    
    func addLeaderTab() {
        let articleTab = UITabBarItem(title: "Articles", image: UIImage(named: "article"), tag: 0)
        let videoTab = UITabBarItem(title: "Video", image: UIImage(named: "video"), tag: 1)
        let audioTab = UITabBarItem(title: "Audio", image: UIImage(named: "audio"), tag: 2)
        
        let leaderTab = UITabBarItem(title: "Leader", image: UIImage(named: "community-group-icon"), tag: 3)
        selectorBar.setItems([articleTab, videoTab, audioTab, leaderTab], animated: true)
    }
    
    // MARK: - Insert Functions
    
    func insertResourceTag(_ dict : NSDictionary) {
        let tag = ResourceTag(dict: dict)!
        tags.insert(tag, at: 0)
        
        
    }

    func finished(_ success: Bool) {
        if success == false {
            print("Could not finish loading videos")
        }
        
        if self.overlayRunning {
            MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
            self.overlayRunning = false
            
        }
        tableView.reloadData()
        
    }
    
    func performGetRequest(_ targetURL: URL!, completion: @escaping (_ data: Data?, _ HTTPStatusCode: Int, _ error: Error?) -> Void) {
        var request = URLRequest(url: targetURL)
        request.httpMethod = "GET"
        
        let sessionConfiguration = URLSessionConfiguration.default
        
        let session = URLSession(configuration: sessionConfiguration)
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            DispatchQueue.main.async(execute: { () -> Void in
                completion(data, (response as! HTTPURLResponse).statusCode, error)
            })
        })
        
        task.resume()
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //Return the number of cards depending on the type of resource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActivated {
            switch (currentType){
            case .Article:
                return filteredArticles.count
            case .Audio:
                return filteredAudioFiles.count
            case .Video:
                return filteredVideos.count
            }
        }
        else {
            switch (currentType){
            case .Article:
                return articles.count
            case .Audio:
                return audioFiles.count
            case .Video:
                return videos.count
            }
        }
        
        
        
    }
    
    //Configures each cell in the table view as a card and sets the UI elements to match with the Resource data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dateFormatString = "MMM d, yyyy"
        
        //Should be refactored to be more efficient
        //Problem for a later dev
            switch (currentType){
            case .Article:
                var art: Article
                if searchActivated {
                    art = filteredArticles[indexPath.row]
                }
                else {
                    art = articles[indexPath.row]
                }
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleTableViewCell", for: indexPath) as! ArticleTableViewCell
                if let date = art.date {
                    cell.date.text = GlobalUtils.stringFromDate(date, format: dateFormatString)
                }
                else {
                    cell.date.text = ""
                }
                
                cell.desc.text = art.abstract
                cell.title.text = art.title
                
                //Set up the cell's button for web view controller
                cell.tapAction = {(cell) in
                    let vc = CustomWebViewController()
                    vc.urlString = art.url
                    self.navigationController?.pushViewController(vc, animated: true)
                }

                cell.card.layer.shadowColor = UIColor.black.cgColor
                cell.card.layer.shadowOffset = CGSize(width: 0, height: 1)
                cell.card.layer.shadowOpacity = 0.25
                cell.card.layer.shadowRadius = 2
                
                
                return cell
            case .Video:
                var video: Video
                if searchActivated {
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
                    if let imageView = cell.thumbnailView {
                        imageView.contentMode = .scaleAspectFit
                    }
                    if let url = video.thumbnailURL {
                        // TODO: Find a way to load thumbnail without it crashing
                        //cell.thumbnailView.load.request(with: url)
                    }
                }
                else {
                    //Adjust the spacing for title, date, & desc to be flush with card
                    //cell.thumbnailView.isHidden = true
                    //cell.stackLeadingSpace.constant = 10.0
                    if let imageView = cell.thumbnailView {
                        imageView.contentMode = .scaleAspectFit
                    }
                }
                
                if video.abstract == "" {
                    
                }
                
                
                
                cell.card.layer.shadowColor = UIColor.black.cgColor
                cell.card.layer.shadowOffset = CGSize(width: 0, height: 1)
                cell.card.layer.shadowOpacity = 0.25
                cell.card.layer.shadowRadius = 2
                return cell
            
            case .Audio:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AudioTableViewCell", for: indexPath) as! AudioTableViewCell
                
                var aud: Audio
                if searchActivated {
                    aud = filteredAudioFiles[indexPath.row]
                }
                else {
                    aud = audioFiles[indexPath.row]
                }
                
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
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if currentType == .Video {
            
            if searchActivated {
                selectedVid = filteredVideos[indexPath.row]
            }
            else {
                selectedVid = videos[indexPath.row]
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch(currentType) {
        case .Article:
            return 160
        case .Audio:
            return 200
        case .Video:
            return 180
        }
    }
    
    // MARK: Actions
    
    @IBAction func presentSearchModal(_ sender: UIBarButtonItem) {
        
        self.performSegue(withIdentifier: "searchModal", sender: self)
        modalActive = true
        
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.overCurrentContext
    }
    
    //Search modal calls this when "Apply" is tapped
    func applyFilters(_ tags: [ResourceTag], searchText: String?) {
        searchActivated = true
        filteredTags = tags
        modalActive = false
        
        if searchText != nil {
            self.searchPhrase = searchText!
            filterContent(tags, searchText: searchText!)
        }
        else {
            filterContent(tags, searchText: nil)
        }
        
    }
    //Checks if a filtered Resource has a tag the user selected
    func resourceHasTag(_ tags: [String], filteredTags: [ResourceTag]) -> Bool{
        for tag in tags {
            if filteredTags.index(where: {$0.id == tag}) != nil {
                return true
            }
        }
        return false
    }
    
    func resetContent() {
        
    }
    
    func checkTags(_ resTags: [String], filteredTags: [ResourceTag]) -> Bool{
        for tag in resTags {
            for filtTag in filteredTags {
                if tag == filtTag.id! {
                    return true
                }
            }
        }
        return false
    }
    
    func filterContent(_ tags: [ResourceTag], searchText: String?) {
        
        //Filter by tags first
        let taggedAudio = audioFiles.filter { file in
            return checkTags(file.tags!, filteredTags: tags)
        }
        
        let taggedArticles = articles.filter { art in
            return checkTags(art.tags!, filteredTags: tags)
        }
        
        let taggedVideos = videos.filter { vid in
            if (vid.tags != nil) && !vid.tags.isEmpty {
                return checkTags(vid.tags!, filteredTags: tags)
            }
            return false
        }
        
        if searchText != nil {
            filteredAudioFiles = taggedAudio.filter { file in
                return file.title.lowercased().contains(searchText!.lowercased())
            }
            
            filteredArticles = taggedArticles.filter { art in
                return art.title.lowercased().contains(searchText!.lowercased())
            }
            filteredVideos = taggedVideos.filter { vid in
                return vid.title.lowercased().contains(searchText!.lowercased())
            }
        }
        else {
            filteredArticles = taggedArticles
            filteredAudioFiles = taggedAudio
            filteredVideos = taggedVideos
        }
        
        tableView.reloadData()
    }
    
    
    //reveal controller function for disabling the current view
    func revealController(_ revealController: SWRevealViewController!, willMoveTo position: FrontViewPosition) {
        
        if position == FrontViewPosition.left {
            for view in self.view.subviews {
                view.isUserInteractionEnabled = true
            }
        }
        else if position == FrontViewPosition.right {
            for view in self.view.subviews {
                view.isUserInteractionEnabled = false
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchModal" {
            
            let modalVC = segue.destination as! SearchModalViewController
            modalVC.transitioningDelegate = self
            modalVC.preferredContentSize = CGSize(width: UIScreen.main.bounds.width * 0.7, height: UIScreen.main.bounds.height * 0.7)
            modalVC.parentVC = self
            
            
            modalVC.tags = self.tags
            modalVC.filteredTags = self.tags
            if searchActivated {
                modalVC.filteredTags = self.filteredTags
                modalVC.prevSearchPhrase = self.searchPhrase
                
            }
            //dim(.in, alpha: dimLevel, speed: dimSpeed)
            
        }
        else if segue.identifier == "openWebView" {
            let vc = segue.destination as! CustomWebViewController
            
            if let index = tableView.indexPathForSelectedRow {
                if currentType == .Video {
                    
                    if searchActivated {
                        selectedVid = filteredVideos[index.row]
                    }
                    else {
                        selectedVid = videos[index.row]
                    }
                    
                    //let vc = CustomWebViewController()
                    //vc.urlString = selectedVid.url
                    //self.navigationController?.pushViewController(vc, animated: true)
                }
                vc.setUrl(string: (selectedVid?.url)!)
            }
            
            //vc.urlString = selectedVid?.url
        }
        
    }
    
    @IBAction func unwindFromSecondary(_ segue: UIStoryboardSegue) {
        modalActive = false
    }
}

////Code that makes the resources screen go dim when Search modal appears
//enum Direction { case `in`, out }
//
//protocol Dimmable { }
//
//extension Dimmable where Self: UIViewController {
//    
//    func dim(_ direction: Direction, color: UIColor = UIColor.black, alpha: CGFloat = 0.0, speed: Double = 0.0) {
//        
//        switch direction {
//        case .in:
//            
//            // Create and add a dim view
//            let dimView = UIView(frame: view.frame)
//            dimView.backgroundColor = color
//            dimView.alpha = 0.0
//            view.addSubview(dimView)
//            
//            // Deal with Auto Layout
//            dimView.translatesAutoresizingMaskIntoConstraints = false
//            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[dimView]|", options: [], metrics: nil, views: ["dimView": dimView]))
//            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimView]|", options: [], metrics: nil, views: ["dimView": dimView]))
//            
//            // Animate alpha (the actual "dimming" effect)
//            UIView.animate(withDuration: speed, animations: { () -> Void in
//                dimView.alpha = alpha
//            }) 
//            
//        case .out:
//            UIView.animate(withDuration: speed, animations: { () -> Void in
//                self.view.subviews.last?.alpha = alpha
//                }, completion: { (complete) -> Void in
//                    self.view.subviews.last?.removeFromSuperview()
//            })
//        }
//    }
//}
