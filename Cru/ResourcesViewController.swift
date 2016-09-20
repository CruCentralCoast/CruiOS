//
//  ResourcesViewController.swift
//  Cru
//  Formats and displays the resources in the Cru database as cards. Handles actions for full-screen view.
//
//  Created by Erica Solum on 2/18/15.
//  Copyright © 2015 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import WildcardSDK
import AVFoundation
import Alamofire
import HTMLReader
import MRProgress
import PagedArray
import DZNEmptyDataSet
import NVActivityIndicatorView

let InitialCount = 20
let PageSize = 8

class ResourcesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, CardViewDelegate, SWRevealViewControllerDelegate, UIViewControllerTransitioningDelegate, Dimmable, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, NVActivityIndicatorViewable, UIPopoverPresentationControllerDelegate {
    //MARK: Properties
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectorBar: UITabBar!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    
    var serverClient: ServerProtocol
    var resources = [Resource]()
    var cardViews = [CardView]()
    var tags = [ResourceTag]()
    var overlayRunning = false
    var currentType = ResourceType.Article
    
    var filteredResources = [Resource]()
    var articleViews = [CardView]()
    var audioViews = [CardView]()
    var videoViews = [CardView]()
    var allViews = [CardView]()
    var filteredArticleCards = [ArticleCard]()
    var filteredAudioCards = [SummaryCard]()
    var filteredVideoCards = [VideoCard]()
    var articleCards = [ArticleCard]()
    var audioCards = [SummaryCard]()
    var videoCards = [VideoCard]()
    
    var pagedArray = PagedArray<Resource>(count: InitialCount, pageSize: PageSize)
    var audioPlayer:AVAudioPlayer!
    var apiKey = "AIzaSyDW_36-r4zQNHYBk3Z8eg99yB0s2jx3kpc"
    var cruChannelID = "UCe-RJ-3Q3tUqJciItiZmjdg"
    var cruUploadsID = "UUe-RJ-3Q3tUqJciItiZmjdg"
    var videosArray: Array<Dictionary<NSObject, AnyObject>> = []
    var nextPageToken = ""
    var pageNum = 1
    let dimLevel: CGFloat = 0.5
    let dimSpeed: Double = 0.5
    var searchActivated = false
    var modalActive = false {
        didSet {
            if modalActive == true {
                searchButton.enabled = false
            }
            else {
                searchButton.enabled = true
            }
        }
    }
    var activityIndicatorView: NVActivityIndicatorView
    var isLeader = false
    var filteredTags = [ResourceTag]()
    var searchPhrase = ""
    var hasConnection = true
    var emptyTableImage: UIImage!
    var numUploads: Int!
    var urlString: String!
    var noResultsString: NSAttributedString!
    var verticalContentOffset: CGFloat!
    var videoCardHeight: CGFloat!
    var memoryWarning = false
    
    //Call this constructor in testing with a fake serverProtocol
    init?(serverProtocol: ServerProtocol, _ coder: NSCoder? = nil) {
        //super.init(coder: NSCoder)
        self.serverClient = serverProtocol
        activityIndicatorView = NVActivityIndicatorView(frame: UIScreen.mainScreen().bounds, type: NVActivityIndicatorType.AudioEqualizer, color: CruColors.yellow)
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
        tableView.separatorColor = UIColor.clearColor()
        
        CruClients.getServerClient().checkConnection(self.finishConnectionCheck)
        
        
        
        
        tableView.backgroundColor = Colors.googleGray
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        videoCardHeight = 0
        
        //Set the nav title
        navigationItem.title = "Resources"
        
        self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        selectorBar.tintColor = UIColor.whiteColor()
        
        
        
        /* Uncomment this for a later release*/
        //addLeaderTab()

    }
    
    /* Don't load anymore youtube resources */
    override func didReceiveMemoryWarning() {
        memoryWarning = true
    }
    
    func doNothing(success: Bool) {
        
    }
    
    func addLeaderTab() {
        let articleTab = UITabBarItem(title: "Articles", image: UIImage(named: "article"), tag: 0)
        let videoTab = UITabBarItem(title: "Video", image: UIImage(named: "video"), tag: 1)
        let audioTab = UITabBarItem(title: "Audio", image: UIImage(named: "audio"), tag: 2)
        
        let leaderTab = UITabBarItem(title: "Leader", image: UIImage(named: "community-group-icon"), tag: 3)
        selectorBar.setItems([articleTab, videoTab, audioTab, leaderTab], animated: true)
    }
    
    /* Function for the empty data set */
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return emptyTableImage
    }
    
    /* Text for the empty search results data set*/
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        //Set up attribute string for empty search results
        let attributes = [ NSFontAttributeName: UIFont(name: Config.fontName, size: 18)!, NSForegroundColorAttributeName: UIColor.blackColor()]
        
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
    func finishConnectionCheck(connected: Bool){
        if(!connected){
            hasConnection = false
            self.emptyTableImage = UIImage(named: Config.noConnectionImageName)
            self.tableView.emptyDataSetDelegate = self
            self.tableView.emptyDataSetSource = self
            self.tableView.reloadData()
            //hasConnection = false
        }else{
            hasConnection = true
            
            MRProgressOverlayView.showOverlayAddedTo(self.view, animated: true)
            overlayRunning = true
            serverClient.getData(DBCollection.Resource, insert: insertResource, completionHandler: getVideosForChannel)
            
            //Also get resource tags and store them
            serverClient.getData(DBCollection.ResourceTags, insert: insertResourceTag, completionHandler: {_ in
                //Hide the community leader tag if the user isn't logged in
                if GlobalUtils.loadString(Config.leaderApiKey) == "" {
                    let index = self.tags.indexOf({$0.title == "Leader (password needed)"})
                    self.tags.removeAtIndex(index!)
                    
                }
            })
        }
        
    }
    
    func insertResourceTag(dict : NSDictionary) {
        let tag = ResourceTag(dict: dict)!
        tags.insert(tag, atIndex: 0)
        
        
    }
    
    
    //Code for the bar at the top of the view for filtering resources
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        var newType: ResourceType
        var oldTypeCount = 0
        var newTypeCount = 0
        
        //print("Selecting item: \(item.title)")
        
        switch (item.title!){
        case "Articles":
            newType = ResourceType.Article
            newTypeCount = articleCards.count
        case "Audio":
            newType = ResourceType.Audio
            newTypeCount = audioCards.count
        case "Videos":
            newType = ResourceType.Video
            newTypeCount = videoCards.count
        default :
            newType = ResourceType.Article
            newTypeCount = articleCards.count
        }
        
        switch (currentType){
        case .Article:
            oldTypeCount = articleCards.count
        case .Audio:
            oldTypeCount = audioCards.count
        case .Video:
            oldTypeCount = videoCards.count
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
    func insertResource(dict : NSDictionary) {
        let resource = Resource(dict: dict)!
        resources.insert(resource, atIndex: 0)
        
        if (resource.type == ResourceType.Article) {
            insertArticle(resource, completionHandler: {_ in 
                print("done inserting articles")
            })
        }
            
        else if (resource.type == ResourceType.Video) {
            if(resource.url.rangeOfString("youtube") != nil) {
                insertYoutube(resource, completionHandler: doNothing)
            }
            else {
                insertGeneric(resource, completionHandler: doNothing)
            }
        }
            
        else if (resource.type == ResourceType.Audio) {
            insertAudio(resource, completionHandler: doNothing)
        }
    }
    
    /* Implement when tools support is requested */
    private func insertAudio(resource: Resource, completionHandler: (Bool) -> Void) {
    
        var card: SummaryCard!
       
        let media:NSMutableDictionary = NSMutableDictionary()
        let data:NSMutableDictionary = NSMutableDictionary()
        media["type"] = "audio"
        data["tags"] = resource.tags
        
        let audioUrl = NSURL(string: resource.url)!
        card = SummaryCard(url:audioUrl, description: "This is where a description would go.", title: resource.title, media:media, data: data)
        
        self.audioCards.append(card)
    }
    
    /* Helper function to get and insert an article card */
    private func insertArticle(resource: Resource,completionHandler: (Bool) -> Void) {
        Alamofire.request(.GET, resource.url)
            .responseString { responseString in
                guard responseString.result.error == nil else {
                    //completionHandler(responseString.result.error!)
                    return
                    
                }
                guard let htmlAsString = responseString.result.value else {
                    let error = Error.errorWithCode(.StringSerializationFailed, failureReason: "Could not get HTML as String")
                    //completionHandler(error)
                    return
                }
                
                
                let doc = HTMLDocument(string: htmlAsString)
                var abstract = ""
                var filteredContent = ""

                var articleCard:ArticleCard!
                var creator: Creator!
                
                let imgurUrl = NSURL(string: "https://unsplash.com/photos/rivAqXQNves")!
                
                let everyStudent = Creator(name:"everystudent.com", url:imgurUrl, favicon:NSURL(string:"https://pbs.twimg.com/profile_images/471735874497941504/EjyLnH9D.jpeg"), iosStore:nil)
                
                let cru = Creator(name:"cru.org", url:imgurUrl, favicon:NSURL(string:"http://www.boomeranggmail.com/img/cru_logo.jpg"), iosStore:nil)
                
                let generic = Creator(name:"", url: NSURL(string:"")!, favicon:NSURL(string:"http://icons.iconarchive.com/icons/iconsmind/outline/512/Open-Book-icon.png"), iosStore:nil)
                
                //Use the right creator with the right favicon
                if(resource.url.rangeOfString("cru") != nil) {
                    creator = cru
                    
                    
                    let absContent = doc.nodesMatchingSelector("p")
                    
                    abstract = absContent[0].textContent
                    
                    
                    
                    let shareIcons = doc.firstNodeMatchingSelector(".listInline")
                    //doc.removeChild(deleteThis!)
                    
                    
                    let content = doc.nodesMatchingSelector(".postContent")
                    //let content = doc.nodesMatchingSelector(".textImage")
                    
                    
                    
                    //Removes the share icons on the top of Cru's articles
                    filteredContent = content[0].innerHTML
                    let listStart = "<ul class=\"listInline"
                    let listEnd = "<!-- The component"
 
                    let startIndex = filteredContent.rangeOfString(listStart)
                    let start = startIndex?.startIndex
                    
                    let firstPart = filteredContent.substringToIndex(start!)
                    
                    var endIndex = filteredContent.rangeOfString(listEnd)
                    var end = endIndex?.startIndex
                    
                    if end == nil {
                        endIndex = filteredContent.rangeOfString("<div class=\"parsys post-body-parsys\"")
                        end = endIndex?.startIndex
                    }
                    
                    if end != nil {
                        let lastPart = filteredContent.substringFromIndex(end!)
                        
                        let newContent = firstPart + lastPart
                        filteredContent = newContent
                    }
                    
                    //filteredContent.removeRange(Range<String.Index>(start: start!, end: end!))
                    
                    
                    //filteredContent = content[0].textContent
                    
                    
                }
                else if(resource.url.rangeOfString("everystudent") != nil) {
                    creator = everyStudent
                    
                    let absContent = doc.nodesMatchingSelector(".subhead")
                    
                    for el in absContent {
                        let subhead = el.firstNodeMatchingSelector("em")!
                        //vidURL = vidNode.objectForKeyedSubscript("src") as? String
                        let child = subhead.childAtIndex(0)
                        
                        abstract = child.textContent
                    }
                    
                    let content = doc.nodesMatchingSelector(".contentpadding")
                    
                    filteredContent = content[0].innerHTML
                    
                    
                }
                else {
                    creator = generic
                }
                
                
                let articleData:NSMutableDictionary = NSMutableDictionary()
                let articleBaseData:NSMutableDictionary = NSMutableDictionary()
                
                articleData["htmlContent"] = filteredContent
                articleData["publicationDate"] = NSNumber(longLong: 1429063354000)
                let articleMedia:NSMutableDictionary = NSMutableDictionary()
                articleMedia["imageUrl"] =  "https://images.unsplash.com/photo-1458170143129-546a3530d995?ixlib=rb-0.3.5&q=80&fm=jpg&crop=entropy&s=82cec66525b351900022cf11428dad4a"
                articleMedia["type"] = "image"
                articleData["media"] = articleMedia
                articleBaseData["article"] = articleData
                articleBaseData["tags"] = resource.tags
                
                
                articleCard = ArticleCard(title: resource.title, abstractContent: abstract, url: NSURL(string: resource.url)!, creator: creator, data: articleBaseData)
                
                self.articleCards.append(articleCard)
                self.tableView.reloadData()
        }
    }
    
    /* Inserts a video from a generic source */
    private func insertGeneric(resource: Resource,completionHandler: (Bool) -> Void) {
        Alamofire.request(.GET, resource.url)
            .responseString { responseString in
                guard responseString.result.error == nil else {
                    //completionHandler(responseString.result.error!)
                    return
                    
                }
                guard let htmlAsString = responseString.result.value else {
                    let error = Error.errorWithCode(.StringSerializationFailed, failureReason: "Could not get HTML as String")
                    //completionHandler(error)
                    return
                }
                
                var vidURL: String!
                
                let doc = HTMLDocument(string: htmlAsString)
                let content = doc.nodesMatchingSelector("iframe")
                
                for vidEl in content {
                    let vidNode = vidEl.firstNodeMatchingSelector("iframe")!
                    vidURL = vidNode.objectForKeyedSubscript("src") as? String
                    
                    
                }
                
                var videoCard: VideoCard!
                
                let creator = Creator(name:"", url: NSURL(string:"")!, favicon:NSURL(string:"http://icons.iconarchive.com/icons/iconsmind/outline/512/Open-Book-icon.png"), iosStore:nil)
              
                let youtubeID = self.getYoutubeID(vidURL)
                let embedUrl = NSURL(string: vidURL)!
                let vidwebUrl = NSURL(string: vidURL)!
                
                
                let videoData:NSMutableDictionary = NSMutableDictionary()
                let videoMedia:NSMutableDictionary = NSMutableDictionary()
                videoMedia["description"] =  ""
                videoMedia["posterImageUrl"] = "http://i1.ytimg.com/vi/\(youtubeID)/mqdefault.jpg"
                
                videoData["media"] = videoMedia
                videoData["tags"] = resource.tags
                
                videoCard = VideoCard(title: resource.title, embedUrl: embedUrl, url: vidwebUrl, creator: creator, data: videoData)
                self.videoCards.append(videoCard)
                
        }
    }
    
    //Get the id of the youtube video by searching within the URL
    private func getYoutubeID(url: String) -> String {
        let start = url.rangeOfString("embed/")
        if(start != nil) {
            let end = url.rangeOfString("?")
            
            if(end != nil) {
                return url.substringWithRange(Range(start: start!.endIndex,
                    end: end!.startIndex))
            }
        }
        return String("")
    }
    
    private func insertYoutube(resource: Resource,completionHandler: (Bool) -> Void) {
        var videoCard:VideoCard!
        
        let newUrl = NSURL(string: "http://www.youtube.com")!
        let embedUrl = NSURL(string: resource.url)!
        let vidwebUrl = NSURL(string: resource.url)!
        
        
        let youtube = Creator(name:"Youtube", url: newUrl, favicon:NSURL(string:"http://coopkanicstang-development.s3.amazonaws.com/brandlogos/logo-youtube.png"), iosStore:nil)
        
        
        let videoData:NSMutableDictionary = NSMutableDictionary()
        let videoMedia:NSMutableDictionary = NSMutableDictionary()
        videoMedia["description"] = ""
        videoMedia["posterImageUrl"] = "http://i1.ytimg.com/vi/\(getYoutubeID(resource.url))/mqdefault.jpg"
        
        videoData["media"] = videoMedia
        videoData["tags"] = resource.tags
        videoCard = VideoCard(title: resource.title, embedUrl: embedUrl, url: vidwebUrl, creator: youtube, data: videoData)
        
        self.videoCards.append(videoCard)
        
        
    }
    
    private func insertYoutubeFromChannel(resource: Resource, description: String, completionHandler: (Bool) -> Void) {
        var videoCard:VideoCard!
        
        let newUrl = NSURL(string: "http://www.youtube.com")!
        
        let embedUrl = NSURL(string: "https://www.youtube.com/embed/\(resource.id)?rel=0")!
        let vidwebUrl = NSURL(string: String("https://www.youtube.com/watch?v=\(resource.id)"))!
        
        
        let youtube = Creator(name:"Youtube", url: newUrl, favicon:NSURL(string:"http://coopkanicstang-development.s3.amazonaws.com/brandlogos/logo-youtube.png"), iosStore:nil)
        
        
        let videoData:NSMutableDictionary = NSMutableDictionary()
        let videoMedia:NSMutableDictionary = NSMutableDictionary()
        videoMedia["description"] =  description
        videoMedia["posterImageUrl"] = "http://i1.ytimg.com/vi/\(resource.id)/mqdefault.jpg"
        
        
        videoData["media"] = videoMedia
        videoData["tags"] = []
        videoCard = VideoCard(title: resource.title, embedUrl: embedUrl, url: vidwebUrl, creator: youtube, data: videoData)
        
        self.videoCards.append(videoCard)
        self.resources.append(resource)
    }
    
    // MARK: Cru CC Youtube Video Retrieval
    //Get the data from Cru Central Coast's youtube channel
    func getVideosForChannel(success: Bool) {
        if !overlayRunning {
            MRProgressOverlayView.showOverlayAddedTo(self.view, animated: true)
            overlayRunning = true
        }
        
        // Get the selected channel's playlistID value from the channelsDataArray array and use it for fetching the proper video playlst.
        
        // Form the request URL string.
        self.urlString = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=\(PageSize)&playlistId=\(cruUploadsID)&key=\(apiKey)"
        
        if nextPageToken != "" {
            self.urlString = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=\(PageSize)&pageToken=\(nextPageToken)&playlistId=\(cruUploadsID)&key=\(apiKey)"
            
        }
        
        // Fetch the playlist from Google.
        performGetRequest(NSURL(string: self.urlString), completion: { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
                // Convert the JSON data into a dictionary.
                do {
                    let resultsDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! Dictionary<NSObject, AnyObject>
                    
                    
                    //Get next page token
                    self.nextPageToken = resultsDict["nextPageToken"] as! String
                    self.numUploads = (resultsDict["pageInfo"] as! Dictionary<NSObject, AnyObject>)["totalResults"] as! Int
                    
                    // Get all playlist items ("items" array).
                    
                    let items: Array<Dictionary<NSObject, AnyObject>> = resultsDict["items"] as! Array<Dictionary<NSObject, AnyObject>>
                    
                    // Use a loop to go through all video items.
                    for i in 0 ..< items.count {
                        let playlistSnippetDict = (items[i] as Dictionary<NSObject, AnyObject>)["snippet"] as! Dictionary<NSObject, AnyObject>
                        
                        // Initialize a new dictionary and store the data of interest.
                        var desiredPlaylistItemDataDict = Dictionary<NSObject, AnyObject>()
                        
                        desiredPlaylistItemDataDict["title"] = playlistSnippetDict["title"]
                        desiredPlaylistItemDataDict["description"] = playlistSnippetDict["description"]
                        desiredPlaylistItemDataDict["thumbnail"] = ((playlistSnippetDict["thumbnails"] as! Dictionary<NSObject, AnyObject>)["medium"] as! Dictionary<NSObject, AnyObject>)["url"]
                        desiredPlaylistItemDataDict["videoID"] = (playlistSnippetDict["resourceId"] as! Dictionary<NSObject, AnyObject>)["videoId"]
                        desiredPlaylistItemDataDict["date"] = playlistSnippetDict["publishedAt"]
                       
                        // Append the desiredPlaylistItemDataDict dictionary to the videos array.
                        self.videosArray.append(desiredPlaylistItemDataDict)
                        //print("\n\(resultsDict)\n")
                        let resource = Resource(id: desiredPlaylistItemDataDict["videoID"] as! String, title: desiredPlaylistItemDataDict["title"] as! String, url: "https://www.youtube.com/embed/\(desiredPlaylistItemDataDict["videoID"])?rel=0", type: "video", date: desiredPlaylistItemDataDict["date"] as! String, tags: nil)
                        // Reload the tableview.
                        //self.tblVideos.reloadData()
                        self.insertYoutubeFromChannel(resource!, description: desiredPlaylistItemDataDict["description"] as! String, completionHandler: self.finished)
                        
                        
                        
                    }
                    self.pageNum = self.pageNum + 1
                    self.tableView.reloadData()
                    
                    
                    
                    if self.overlayRunning {
                        MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
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
    
    func finished(success: Bool) {
        if success == false {
            print("Could not finish loading videos")
        }
        
    }
    
    func performGetRequest(targetURL: NSURL!, completion: (data: NSData?, HTTPStatusCode: Int, error: NSError?) -> Void) {
        let request = NSMutableURLRequest(URL: targetURL)
        request.HTTPMethod = "GET"
        
        let sessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        let session = NSURLSession(configuration: sessionConfiguration)
        
        let task = session.dataTaskWithRequest(request, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completion(data: data, HTTPStatusCode: (response as! NSHTTPURLResponse).statusCode, error: error)
            })
        })
        
        task.resume()
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
   
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,forRowAtIndexPath indexPath: NSIndexPath) {
        
        //print("Number of videoViews: \(videoViews.count)")
        
        /*let visiblePaths = tableView.indexPathsForVisibleRows
        let lastVisPath = visiblePaths![visiblePaths!.count - 1]
        print("Last visible row: \(lastVisPath.row)")*/
        
        /*verticalContentOffset = tableView.contentOffset.y
        print("Vertical Content offset: \(verticalContentOffset)")*/
        
        
        //Set the height if videoCardHeight hasn't been set yet or there's a smaller card
        if (videoCardHeight - cell.bounds.height > 0 || videoCardHeight == 0) && currentType == .Video{
            videoCardHeight = cell.bounds.height
        }
        
        if !memoryWarning && currentType == .Video && searchActivated == false
            && (videosArray.count < numUploads)
            && tableView.contentOffset.y > (((CGFloat)(videoCards.count-3))*videoCardHeight - videoCardHeight) {
            //verticalContentOffset = tableView.contentOffset.y
            print("Should get videos for channel")
            getVideosForChannel(true)
        }
        
    }
    
    //Return the number of cards depending on the type of resource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActivated {
            switch (currentType){
            case .Article:
                return filteredArticleCards.count
            case .Audio:
                return filteredAudioCards.count
            case .Video:
                return filteredVideoCards.count
            }
        }
        else {
            switch (currentType){
            case .Article:
                return articleCards.count
            case .Audio:
                return audioCards.count
            case .Video:
                return videoCards.count
            }
        }
        
        
        
    }
    
    //Configures each cell in the table view as a card and sets the UI elements to match with the Resource data
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "CardTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! CardTableViewCell
        let cardView: CardView?
        
        if searchActivated {
            switch (currentType){
            case .Article:
                cardView = CardView.createCardView(filteredArticleCards[indexPath.row], layout: .ArticleCardNoImage)!
            //cardView = articleViews[indexPath.row]
            case .Audio:
                cardView = CardView.createCardView(filteredAudioCards[indexPath.row], layout: .SummaryCardNoImage)!
            //cardView = audioViews[indexPath.row]
            case .Video:
                cardView = CardView.createCardView(filteredVideoCards[indexPath.row], layout: .VideoCardShortFull)!
                //cardView = videoViews[indexPath.row]
            }
        }
        else {
            switch (currentType){
            case .Article:
                cardView = CardView.createCardView(articleCards[indexPath.row], layout: .ArticleCardNoImage)!
            //cardView = articleViews[indexPath.row]
            case .Audio:
                cardView = CardView.createCardView(audioCards[indexPath.row], layout: .SummaryCardNoImage)!
            //cardView = audioViews[indexPath.row]
            case .Video:
                cardView = CardView.createCardView(videoCards[indexPath.row], layout: .VideoCardShortFull)!
                //cardView = videoViews[indexPath.row]
            }
        }
        
        cardView?.delegate = self
        
        //Add the newl card view to the cell
        cell.contentView.subviews.forEach({ $0.removeFromSuperview() }) // this gets things done
        cell.contentView.addSubview(cardView!)
        cell.contentView.backgroundColor = Colors.googleGray
        
        //Set the constraints
        self.constrainView(cardView!, row: indexPath.row)
        return cell
    }
    
    //Sets the constraints for the cards so they float in the middle of the table
    private func constrainView(cardView: CardView, row: Int) {
        cardView.delegate = self
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.horizontallyCenterToSuperView(0)
        
        cardView.constrainTopToSuperView(15)
        cardView.constrainBottomToSuperView(15)
        cardView.constrainRightToSuperView(15)
        cardView.constrainLeftToSuperView(15)
    }
    
    // MARK: Actions
    
    @IBAction func presentSearchModal(sender: UIBarButtonItem) {
        
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
        self.performSegueWithIdentifier("searchModal", sender: self)
        modalActive = true
        
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.OverCurrentContext
    }
    
    //Search modal calls this when "Apply" is tapped
    func applyFilters(tags: [ResourceTag], searchText: String?) {
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
    func resourceHasTag(tags: [String], filteredTags: [ResourceTag]) -> Bool{
        for tag in tags {
            if filteredTags.indexOf({$0.id == tag}) != nil {
                return true
            }
        }
        return false
    }
    
    func resetContent() {
        
    }
    
    func checkTags(resTags: [String], filteredTags: [ResourceTag]) -> Bool{
        for tag in resTags {
            for filtTag in filteredTags {
                print("comparing \(tag) to \(filtTag.id)")
                if tag == filtTag.id {
                    return true
                }
            }
        }
        return false
    }
    
    func filterContent(tags: [ResourceTag], searchText: String?) {
        
        //Filter by tags first
        let taggedAudio = audioCards.filter { card in
            return checkTags(card.tags!, filteredTags: tags)
        }
        
        let taggedArticles = articleCards.filter { card in
            return checkTags(card.tags!, filteredTags: tags)
        }
        let taggedVideos = videoCards.filter { card in
            if !(card.tags?.isEmpty)! {
                return checkTags(card.tags!, filteredTags: tags)
            }
            return false
        }
        
        if searchText != nil {
            filteredAudioCards = taggedAudio.filter { card in
                return card.title.lowercaseString.containsString(searchText!.lowercaseString)
            }
            
            filteredArticleCards = taggedArticles.filter { card in
                return card.title.lowercaseString.containsString(searchText!.lowercaseString)
            }
            filteredVideoCards = taggedVideos.filter { card in
                return card.title.lowercaseString.containsString(searchText!.lowercaseString)
            }
        }
        else {
            filteredArticleCards = taggedArticles
            filteredAudioCards = taggedAudio
            filteredVideoCards = taggedVideos
        }
        
        tableView.reloadData()
    }
    
    func cardViewRequestedAction(cardView: CardView, action: CardViewAction) {
        
        handleCardAction(cardView, action: action)
    }
    
    //reveal controller function for disabling the current view
    func revealController(revealController: SWRevealViewController!, willMoveToPosition position: FrontViewPosition) {
        
        if position == FrontViewPosition.Left {
            for view in self.view.subviews {
                view.userInteractionEnabled = true
            }
        }
        else if position == FrontViewPosition.Right {
            for view in self.view.subviews {
                view.userInteractionEnabled = false
            }
        }
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "searchModal" {
            
            let modalVC = segue.destinationViewController as! SearchModalViewController
            modalVC.transitioningDelegate = self
            modalVC.preferredContentSize = CGSizeMake(UIScreen.mainScreen().bounds.width * 0.7, UIScreen.mainScreen().bounds.height * 0.7)
            modalVC.parentVC = self
            
            
            
            
            modalVC.tags = self.tags
            modalVC.filteredTags = self.tags
            if searchActivated {
                modalVC.filteredTags = self.filteredTags
                modalVC.prevSearchPhrase = self.searchPhrase
                
            }
            dim(.In, alpha: dimLevel, speed: dimSpeed)
            
        }
    }
    
    @IBAction func unwindFromSecondary(segue: UIStoryboardSegue) {
        dim(.Out, speed: dimSpeed)
        modalActive = false
    }
}

//Code that makes the resources screen go dim when Search modal appears
enum Direction { case In, Out }

protocol Dimmable { }

extension Dimmable where Self: UIViewController {
    
    func dim(direction: Direction, color: UIColor = UIColor.blackColor(), alpha: CGFloat = 0.0, speed: Double = 0.0) {
        
        switch direction {
        case .In:
            
            // Create and add a dim view
            let dimView = UIView(frame: view.frame)
            dimView.backgroundColor = color
            dimView.alpha = 0.0
            view.addSubview(dimView)
            
            // Deal with Auto Layout
            dimView.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[dimView]|", options: [], metrics: nil, views: ["dimView": dimView]))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[dimView]|", options: [], metrics: nil, views: ["dimView": dimView]))
            
            // Animate alpha (the actual "dimming" effect)
            UIView.animateWithDuration(speed) { () -> Void in
                dimView.alpha = alpha
            }
            
        case .Out:
            UIView.animateWithDuration(speed, animations: { () -> Void in
                self.view.subviews.last?.alpha = alpha ?? 0
                }, completion: { (complete) -> Void in
                    self.view.subviews.last?.removeFromSuperview()
            })
        }
    }
}