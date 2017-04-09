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

class ResourcesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, SWRevealViewControllerDelegate, UIViewControllerTransitioningDelegate, Dimmable, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, UIPopoverPresentationControllerDelegate {
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
        
        
        
        
        tableView.backgroundColor = Colors.googleGray
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
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
                self.loadYouTubeVideos(completionHandler: { (numNewVids) in
                    let videoCount = self.videos.count
                    let (start, end) = (videoCount, self.newVideos.count + videoCount)
                    let indexPaths = (start..<end).map { return IndexPath(row: $0, section: 0) }
                    
                    // update data source
                    self.videos.append(contentsOf: self.newVideos)
                    
                    // make sure you update tableView before calling -finishInfiniteScroll
                    tableView.beginUpdates()
                    tableView.insertRows(at: indexPaths, with: .automatic)
                    tableView.endUpdates()
                    
                    // finish infinite scroll animation
                    tableView.finishInfiniteScroll()
                })
            }

        }
        // load initial data
        //tableView.beginInfiniteScroll(true)
        
        /* Uncomment this for a later release*/
        //addLeaderTab()

    }
    
    /* Don't load anymore youtube resources */
    override func didReceiveMemoryWarning() {
        memoryWarning = true
    }
    
    func doNothing(_ success: Bool) {
        
    }
    
    func addLeaderTab() {
        let articleTab = UITabBarItem(title: "Articles", image: UIImage(named: "article"), tag: 0)
        let videoTab = UITabBarItem(title: "Video", image: UIImage(named: "video"), tag: 1)
        let audioTab = UITabBarItem(title: "Audio", image: UIImage(named: "audio"), tag: 2)
        
        let leaderTab = UITabBarItem(title: "Leader", image: UIImage(named: "community-group-icon"), tag: 3)
        selectorBar.setItems([articleTab, videoTab, audioTab, leaderTab], animated: true)
    }
    
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
            serverClient.getData(DBCollection.Resource, insert: insertResource, completionHandler: getVideosForChannel)
            //serverClient.getData(DBCollection.Resource, insert: insertResource, completionHandler: finished)
            
            //Also get resource tags and store them
            serverClient.getData(DBCollection.ResourceTags, insert: insertResourceTag, completionHandler: {_ in
                //Hide the community leader tag if the user isn't logged in
                if GlobalUtils.loadString(Config.leaderApiKey) == "" {
                    let index = self.tags.index(where: {$0.title == "Leader (password needed)"})
                    self.tags.remove(at: index!)
                    
                }
            })
        }
        
    }
    
    func insertResourceTag(_ dict : NSDictionary) {
        let tag = ResourceTag(dict: dict)!
        tags.insert(tag, at: 0)
        
        
    }
    
    
    //Code for the bar at the top of the view for filtering resources
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        var newType: ResourceType
        var oldTypeCount = 0
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
        
        switch (currentType){
        case .Article:
            oldTypeCount = articles.count
        case .Audio:
            oldTypeCount = audioFiles.count
        case .Video:
            oldTypeCount = videos.count
        }
        
        
        if(newType == currentType){
            return
        }
        else{
            currentType = newType
        }
        self.tableView.reloadData()
    }
    
    //Get resources from database
    func insertResource(_ dict : NSDictionary) {
        let resource = Resource(dict: dict)!
        resources.insert(resource, at: 0)
        
        if (resource.type == ResourceType.Article) {
            //Can't pass in nil to completion so pass instead print confirmation
            insertArticle(resource, completionHandler: {_ in
                print("done inserting articles")
            })
            
        }
            
        else if (resource.type == ResourceType.Video) {
            insertVideo(resource, completionHandler: {_ in
                print("done inserting videos")
            })
        
        }
            
        else if (resource.type == ResourceType.Audio) {
            insertAudio(resource, completionHandler: {_ in
                print("done inserting audio")
            })
        }
    }
    
    /* Creates new Audio object and inserts into table if necessary*/
    fileprivate func insertAudio(_ resource: Resource, completionHandler: (Bool) -> Void) {
        let newAud = Audio(id: resource.id, title: resource.title, url: resource.url, date: resource.date, tags: resource.tags, restricted: resource.restricted)!
        audioFiles.append(newAud)
        self.tableView.reloadData()
    }
    
    
    /* Helper function to insert an article resource */
    fileprivate func insertArticle(_ resource: Resource,completionHandler: (Bool) -> Void) {
        let resUrl = URL(string: resource.url)
        guard let url = resUrl else {
            return
        }
        
        //Use Readability to scrape article for description
        Readability.parse(url: url) { data in
            let description = data?.description ?? ""
            let imageUrl = data?.topImage ?? ""
            
            let newArt = Article(id: resource.id, title: resource.title, url: resource.url, date: resource.date, tags: resource.tags, abstract: description, imgURL: imageUrl, restricted: resource.restricted)
            self.articles.append(newArt!)
            self.tableView.reloadData()
            
        }
        
        
    }
    
    //Inserts a video resource
    fileprivate func insertVideo(_ resource: Resource, completionHandler: (Bool) -> Void) {
        let resUrl = URL(string: resource.url)
        guard let url = resUrl else {
            return
        }
        
        Readability.parse(url: url) { data in
            
            let description = data?.description ?? ""
            let videoUrl = data?.topVideo ?? ""
            
            //If Readability doesn't find video URL, scrape HTML and get source from iFrame
            if videoUrl == "" {
                Alamofire.request(resource.url, method: .get)
                    .responseString { responseString in
                        guard responseString.result.error == nil else {
                            //completionHandler(responseString.result.error!)
                            return
                            
                        }
                        guard let htmlAsString = responseString.result.value else {
                            //Future problem: impement better error code with Alamofire 4
                            print("Error: Could not get HTML as String")
                            return
                        }
                        
                        var vidURL: String!
                        
                        let doc = HTMLDocument(string: htmlAsString)
                        let content = doc.nodes(matchingSelector: "iframe")
                        
                        for vidEl in content {
                            let vidNode = vidEl.firstNode(matchingSelector: "iframe")!
                            vidURL = vidNode.objectForKeyedSubscript("src") as? String
                        }
                        
                        let youtubeID = self.getYoutubeID(vidURL)
                        //let embedUrl = URL(string: vidURL)!
                        //let vidwebUrl = URL(string: vidURL)!
                        
                        let newVid = Video(id: resource.id, title: resource.title, url: resource.url, date: resource.date, tags: resource.tags, abstract: description, videoURL: vidURL, thumbnailURL: "", restricted: resource.restricted)
                        
                        self.videos.append(newVid!)
                        self.tableView.reloadData()
                }
            }
            else {
                let newVid = Video(id: resource.id, title: resource.title, url: resource.url, date: resource.date, tags: resource.tags, abstract: description, videoURL: videoUrl, thumbnailURL: "", restricted: resource.restricted)
                self.videos.append(newVid!)
                self.tableView.reloadData()
            }
            
            
            
        }
        
        
    }
    
    //Get the id of the youtube video by searching within the URL
    fileprivate func getYoutubeID(_ url: String) -> String {
        let start = url.range(of: "embed/")
        if(start != nil) {
            let end = url.range(of: "?")
            
            if(end != nil) {
                return url.substring(with: (start!.upperBound ..< end!.lowerBound))
            }
        }
        return String("")
    }
    
    fileprivate func insertYoutubeFromChannel(_ resource: Resource, description: String, completionHandler: (Bool) -> Void) {
        
        
        
        /*var videoCard:VideoCard!
        
        let newUrl = URL(string: "http://www.youtube.com")
        
        print("embedUrl: https://www.youtube.com/embed/\(resource.id!)?rel=0")
        let embedUrl = URL(string: "https://www.youtube.com/embed/\(resource.id!)?rel=0")
        let vidwebUrl = URL(string: String("https://www.youtube.com/watch?v=\(resource.id!)"))
        
        
        let youtube = Creator(name:"Youtube", url: newUrl!, favicon:URL(string:"http://coopkanicstang-development.s3.amazonaws.com/brandlogos/logo-youtube.png"), iosStore:nil)
        
        
        let videoData:NSMutableDictionary = NSMutableDictionary()
        let videoMedia:NSMutableDictionary = NSMutableDictionary()
        videoMedia["description"] =  description
        videoMedia["posterImageUrl"] = "http://i1.ytimg.com/vi/\(resource.id)/mqdefault.jpg"
        
        
        videoData["media"] = videoMedia
        videoData["tags"] = []
        videoCard = VideoCard(title: resource.title, embedUrl: embedUrl!, url: vidwebUrl!, creator: youtube, data: videoData)
        
        self.videoCards.append(videoCard)
        self.resources.append(resource)
         */
    }
    
    // MARK: Cru CC Youtube Video Retrieval
    //Get the data from Cru Central Coast's youtube channel
    func getVideosForChannel(_ success: Bool) {
        if !overlayRunning {
            MRProgressOverlayView.showOverlayAdded(to: self.view, animated: true)
            overlayRunning = true
        }
        
        //let request = Search(.fromChannel(Config.cruChannelID, [.snippet, .contentDetails]), limit: )
        // Get the selected channel's playlistID value from the channelsDataArray array and use it for fetching the proper video playlst.
        
        // Form the request URL string.
        //self.urlString = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=\(PageSize)&playlistId=\(Config.cruUploadsID)&key=\(Config.youtubeApiKey)"
        //self.urlString = "https://www.googleapis.com/youtube/v3/playlists?part=snippet&channelId=\(Config.cruChannelID)&key=\(Config.youtubeApiKey)"
        self.urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=\(Config.cruChannelID)&maxResults=\(PageSize)&order=date&type=video&key=\(Config.youtubeApiKey)"
        
        if nextPageToken != "" {
            self.urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=\(Config.cruChannelID)&maxResults=\(PageSize)&order=date&pageToken=\(nextPageToken)&type=video&key=\(Config.youtubeApiKey)"
            //self.urlString = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=\(PageSize)&pageToken=\(nextPageToken)&playlistId=\(Config.cruUploadsID)&key=\(Config.youtubeApiKey)"
            
        }
        
        // Fetch the playlist from Google.
        performGetRequest(URL(string: self.urlString), completion: { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
                // Convert the JSON data into a dictionary.
                do {
                    let resultsDict = try JSONSerialization.jsonObject(with: data!, options: []) as? Dictionary<String, AnyObject>
                    
                    
                    //Get next page token
                    self.nextPageToken = resultsDict?["nextPageToken"] as! String
                    self.numUploads = (resultsDict?["pageInfo"] as! Dictionary<String, AnyObject>)["totalResults"] as! Int
                    
                    // Get all playlist items ("items" array).
                    
                    let items: Array<Dictionary<String, AnyObject>> = resultsDict!["items"] as! Array<Dictionary<String, AnyObject>>
                    
                    // Use a loop to go through all video items.
                    for i in 0 ..< items.count {
                        let idDict = (items[i] as Dictionary<String, AnyObject>)["id"] as! Dictionary<String, AnyObject>
                        let videoID = idDict["videoId"] as! String
                        
                        
                        let snippetDict = (items[i] as Dictionary<String, AnyObject>)["snippet"] as! Dictionary<String, AnyObject>
                        
                        // Initialize a new dictionary and store the data of interest.
                        //var thumbnailsDict = Dictionary<String, AnyObject>()
                        
                        
                        let thumbnailURL = ((snippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["default"] as! Dictionary<String, AnyObject>)["url"]
                        //desiredPlaylistItemDataDict["videoID"] = (snippetDict["resourceId"] as! Dictionary<String, AnyObject>)["videoId"]
                        //desiredPlaylistItemDataDict["date"] = snippetDict["publishedAt"]
                       
                        // Append the desiredPlaylistItemDataDict dictionary to the videos array.
                        self.videosArray.append(snippetDict as [NSObject : AnyObject])
                        //print("\n\(resultsDict)\n")
                        let resource = Resource(id: videoID, title: snippetDict["title"] as! String, url: "https://www.youtube.com/watch?v=\(videoID)", type: "video", date: snippetDict["publishedAt"] as! String, tags: nil)!
                        
                        let newVid = Video(id: videoID, title: snippetDict["title"] as! String, url: resource.url, date: resource.date, tags: nil, abstract: snippetDict["description"] as! String, videoURL: resource.url, thumbnailURL: thumbnailURL as! String?,restricted: false)
                        
                        self.resources.append(resource)
                        self.videos.append(newVid!)
                        
                        // Reload the tableview.
                        //self.tblVideos.reloadData()
                        //self.insertYoutubeFromChannel(resource!, description: snippetDict["description"] as! String, completionHandler: self.finished)
                        
                        
                        
                    }
                    self.pageNum = self.pageNum + 1
                    self.tableView.reloadData()
                    
                    if self.overlayRunning {
                        MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
                        self.overlayRunning = false
                        
                    }
                    
                    self.tableView.emptyDataSetSource = self
                    self.tableView.emptyDataSetDelegate = self
                    self.tableView.tableFooterView = UIView()
                }
                catch {
                    print("Error loading videos")
                }
                
            }
                
            else {
                print("HTTP Status Code = \(HTTPStatusCode)\n")
                print("Error while loading channel videos: \(error)\n")
            }
            
            
        })
    }
    
    
    //Yes, this is similar to the function above but this one has a completion handler
    //Load youtube videos for infinite scrolling
    func loadYouTubeVideos(completionHandler: @escaping (_ numVideos: Int) -> Void) {
        self.urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=\(Config.cruChannelID)&maxResults=\(PageSize)&order=date&pageToken=\(nextPageToken)&type=video&key=\(Config.youtubeApiKey)"
        
        self.newVideos = [Video]() //Clear the new videos array
        // Fetch the playlist from Google.
        performGetRequest(URL(string: self.urlString), completion: { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
                // Convert the JSON data into a dictionary.
                do {
                    let resultsDict = try JSONSerialization.jsonObject(with: data!, options: []) as? Dictionary<String, AnyObject>
                    
                    //Get next page token
                    self.nextPageToken = resultsDict?["nextPageToken"] as! String
                    self.numUploads = (resultsDict?["pageInfo"] as! Dictionary<String, AnyObject>)["totalResults"] as! Int
                    self.numNewVideos = (resultsDict?["pageInfo"] as! Dictionary<String, AnyObject>)["resultsPerPage"] as! Int
                    
                    // Get all playlist items ("items" array).
                    
                    let items: Array<Dictionary<String, AnyObject>> = resultsDict!["items"] as! Array<Dictionary<String, AnyObject>>
                    
                    // Use a loop to go through all video items.
                    for i in 0 ..< items.count {
                        let idDict = (items[i] as Dictionary<String, AnyObject>)["id"] as! Dictionary<String, AnyObject>
                        let videoID = idDict["videoId"] as! String
                        
                        
                        let snippetDict = (items[i] as Dictionary<String, AnyObject>)["snippet"] as! Dictionary<String, AnyObject>
                        
                        // Initialize a new dictionary and store the data of interest.
                        
                        
                        let thumbnailURL = ((snippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["default"] as! Dictionary<String, AnyObject>)["url"]
                        
                        // Append the desiredPlaylistItemDataDict dictionary to the videos array.
                        self.videosArray.append(snippetDict as [NSObject : AnyObject])

                        let resource = Resource(id: videoID, title: snippetDict["title"] as! String, url: "https://www.youtube.com/watch?v=\(videoID)", type: "video", date: snippetDict["publishedAt"] as! String, tags: nil)!
                        
                        let newVid = Video(id: videoID, title: snippetDict["title"] as! String, url: resource.url, date: resource.date, tags: nil, abstract: snippetDict["description"] as! String, videoURL: resource.url, thumbnailURL: thumbnailURL as! String?,restricted: false)
                        
                        self.resources.append(resource)
                        self.newVideos.append(newVid!)
                    }
                    self.pageNum = self.pageNum + 1
                    
                    self.tableView.tableFooterView = UIView()
                    completionHandler(self.numNewVideos)
                }
                catch {
                    print("Error loading videos")
                }
                
            }
                
            else {
                print("HTTP Status Code = \(HTTPStatusCode)\n")
                print("Error while loading channel videos: \(error)\n")
            }
            
            
        })
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
    
   
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell,forRowAt indexPath: IndexPath) {
        
        if currentType == .Video{
            let vidCell = cell as! VideoTableViewCell
        }
        
        //print("Number of videoViews: \(videoViews.count)")
        
        /*let visiblePaths = tableView.indexPathsForVisibleRows
        let lastVisPath = visiblePaths![visiblePaths!.count - 1]
        print("Last visible row: \(lastVisPath.row)")*/
        
        /*verticalContentOffset = tableView.contentOffset.y
        print("Vertical Content offset: \(verticalContentOffset)")*/
        
        
        //Set the height if videoCardHeight hasn't been set yet or there's a smaller card
        /*if (videoCardHeight - cell.bounds.height > 0 || videoCardHeight == 0) && currentType == .Video{
            videoCardHeight = cell.bounds.height
        }
        
        if !memoryWarning && currentType == .Video && searchActivated == false
            && (videosArray.count < numUploads)
            && tableView.contentOffset.y > (((CGFloat)(videoCards.count-3))*videoCardHeight - videoCardHeight) {
            //verticalContentOffset = tableView.contentOffset.y
            print("Should get videos for channel")
            getVideosForChannel(true)
        }*/
        
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
                cell.date.text = GlobalUtils.stringFromDate(art.date, format: dateFormatString)
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
                    cell.thumbnailView.load.request(with: video.thumbnailURL)
                    
                }
                else {
                    //Adjust the spacing for title, date, & desc to be flush with card
                    cell.thumbnailView.isHidden = true
                    cell.stackLeadingSpace.constant = 10.0
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
                cell.audioString = aud.url
                
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
        print("Bro?")
    }
    
    // MARK: Actions
    
    @IBAction func presentSearchModal(_ sender: UIBarButtonItem) {
        
        /*let searchModal = SearchModalViewController()
        searchModal.modalPresentationStyle = UIModalPresentationStyle.Popover
        //self.performSegueWithIdentifier("searchModal", sender: self)
        let popoverMenuViewController = searchModal.popoverPresentationController
        popoverMenuViewController!.permittedArrowDirections = .Unknown
        popoverMenuViewController!.delegate = self
        popoverMenuViewController!.sourceView = self.view
        presentViewController(searchModal,
            animated: true,
            completion: nil)*/
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
            if !(vid.tags?.isEmpty)! {
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
            dim(.in, alpha: dimLevel, speed: dimSpeed)
            
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
        dim(.out, speed: dimSpeed)
        modalActive = false
    }
}

//Code that makes the resources screen go dim when Search modal appears
enum Direction { case `in`, out }

protocol Dimmable { }

extension Dimmable where Self: UIViewController {
    
    func dim(_ direction: Direction, color: UIColor = UIColor.black, alpha: CGFloat = 0.0, speed: Double = 0.0) {
        
        switch direction {
        case .in:
            
            // Create and add a dim view
            let dimView = UIView(frame: view.frame)
            dimView.backgroundColor = color
            dimView.alpha = 0.0
            view.addSubview(dimView)
            
            // Deal with Auto Layout
            dimView.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[dimView]|", options: [], metrics: nil, views: ["dimView": dimView]))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimView]|", options: [], metrics: nil, views: ["dimView": dimView]))
            
            // Animate alpha (the actual "dimming" effect)
            UIView.animate(withDuration: speed, animations: { () -> Void in
                dimView.alpha = alpha
            }) 
            
        case .out:
            UIView.animate(withDuration: speed, animations: { () -> Void in
                self.view.subviews.last?.alpha = alpha ?? 0
                }, completion: { (complete) -> Void in
                    self.view.subviews.last?.removeFromSuperview()
            })
        }
    }
}
