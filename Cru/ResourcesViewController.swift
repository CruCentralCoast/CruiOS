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

let InitialCount = 20
let PageSize = 5

class ResourcesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, CardViewDelegate, SWRevealViewControllerDelegate {
    //MARK: Properties
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectorBar: UITabBar!
    
    var serverClient: ServerProtocol
    var resources = [Resource]()
    var cardViews = [CardView]()
 
    var currentType = ResourceType.Article
    var filteredResources = [Resource]()
    var articleViews = [CardView]()
    var audioViews = [CardView]()
    var videoViews = [CardView]()
    var allViews = [CardView]()
    var pagedArray = PagedArray<Resource>(count: InitialCount, pageSize: PageSize)
    var audioPlayer:AVAudioPlayer!
    var apiKey = "AIzaSyDW_36-r4zQNHYBk3Z8eg99yB0s2jx3kpc"
    var cruChannelID = "UCe-RJ-3Q3tUqJciItiZmjdg"
    var cruUploadsID = "UUe-RJ-3Q3tUqJciItiZmjdg"
    var videosArray: Array<Dictionary<NSObject, AnyObject>> = []
    var nextPageToken = ""
    var pageNum = 1
    
    
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
        tableView.separatorColor = UIColor.clearColor()
        
       
        //If the user is logged in, view special resources. Otherwise load non-restricted resources.
        MRProgressOverlayView.showOverlayAddedTo(self.view, animated: true)
        serverClient.getData(DBCollection.Resource, insert: insertResource, completionHandler: getVideosForChannel)
        
        tableView.backgroundColor = Colors.googleGray
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        
        //Set the nav title
        navigationItem.title = "Resources"
        
        self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        selectorBar.tintColor = UIColor.whiteColor()
        
        //Set up the fluent pagination

    }
    
    func completion(success: Bool) {
        if( success) {
            
        }
        MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
    }
    
    func doNothing(success: Bool) {
        
    }
    
    //Code for the bar at the top of the view for filtering resources
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        var newType: ResourceType
        var oldTypeCount = 0
        var newTypeCount = 0
        
        switch (item.title!){
        case "Articles":
            newType = ResourceType.Article
            newTypeCount = articleViews.count
        case "Audio":
            newType = ResourceType.Audio
            newTypeCount = audioViews.count
        case "Videos":
            newType = ResourceType.Video
            newTypeCount = videoViews.count
        default :
            newType = ResourceType.Article
            newTypeCount = articleViews.count
        }
        
        switch (currentType){
        case .Article:
            oldTypeCount = articleViews.count
        case .Audio:
            oldTypeCount = audioViews.count
        case .Video:
            oldTypeCount = videoViews.count
        }
        
        
        if(newType == currentType){
            return
        }
        else{
            currentType = newType
        }
        
        let numNewCells = newTypeCount - oldTypeCount
        
        self.tableView.beginUpdates()
        if(numNewCells < 0){
            let numCellsToRemove = -numNewCells
            for i in 0...(numCellsToRemove - 1){
                self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forItem: i, inSection: 0)], withRowAnimation: .Automatic)
            }
        }
        else if(numNewCells > 0){
            for i in 0...(numNewCells - 1){
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forItem: i, inSection: 0)], withRowAnimation: .Automatic)
            }
        }
        self.tableView.endUpdates()
        self.tableView.reloadData()
    }
    
    //Get resources from database
    func insertResource(dict : NSDictionary) {
        let resource = Resource(dict: dict)!
        resources.insert(resource, atIndex: 0)
        
        if (resource.type == ResourceType.Article) {
            insertArticle(resource, completionHandler: doNothing)
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
    
        var cardView: CardView! = nil
        var card: SummaryCard!
       
        let media:NSMutableDictionary = NSMutableDictionary()
        media["type"] = "audio"
        
        let audioUrl = NSURL(string: resource.url)!
        card = SummaryCard(url:audioUrl, description: "This is where a description would go.", title: resource.title, media:media, data:nil)
        
        // Make the view that is put into the table
        cardView = CardView.createCardView(card!, layout: .SummaryCardNoImage)!
        
        
        self.audioViews.insert(cardView, atIndex: 0)
        
        if (cardView != nil) {
            cardView.delegate = self
            self.resources.insert(resource, atIndex: 0)
            if(self.currentType == .Audio){
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)], withRowAnimation: .Automatic)
            }
        }
        
        
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
                    
                    let endIndex = filteredContent.rangeOfString(listEnd)
                    let end = endIndex?.startIndex
                    
                    let lastPart = filteredContent.substringFromIndex(end!)
                    
                    let newContent = firstPart + lastPart
                    
                    //filteredContent.removeRange(Range<String.Index>(start: start!, end: end!))
                    filteredContent = newContent
                    
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
                
                
                
                articleCard = ArticleCard(title: resource.title, abstractContent: abstract, url: NSURL(string: resource.url)!, creator: creator, data: articleBaseData)
                
                var cardView : CardView! = nil
                cardView = CardView.createCardView(articleCard!, layout: .ArticleCardNoImage)!
                
                
                self.articleViews.insert(cardView, atIndex: 0)
                
                if (cardView != nil) {
                    cardView.delegate = self
                    self.resources.insert(resource, atIndex: 0)
                    if(self.currentType == .Article){
                        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)], withRowAnimation: .Automatic)
                    }
                }
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
                var cardView: CardView! = nil
                
                let creator = Creator(name:"", url: NSURL(string:"")!, favicon:NSURL(string:"http://icons.iconarchive.com/icons/iconsmind/outline/512/Open-Book-icon.png"), iosStore:nil)
              
                let youtubeID = self.getYoutubeID(vidURL)
                let embedUrl = NSURL(string: vidURL)!
                let vidwebUrl = NSURL(string: vidURL)!
                
                
                let videoData:NSMutableDictionary = NSMutableDictionary()
                let videoMedia:NSMutableDictionary = NSMutableDictionary()
                videoMedia["description"] =  ""
                videoMedia["posterImageUrl"] = "http://i1.ytimg.com/vi/\(youtubeID)/mqdefault.jpg"
                
                videoData["media"] = videoMedia
                videoCard = VideoCard(title: resource.title, embedUrl: embedUrl, url: vidwebUrl, creator: creator, data: videoData)
                
                
                cardView = CardView.createCardView(videoCard!, layout: .VideoCardShortFull)!
                
                self.videoViews.insert(cardView, atIndex: 0)
                
                if (cardView != nil) {
                    cardView.delegate = self
                    self.resources.insert(resource, atIndex: 0)
                    if(self.currentType == .Video){
                        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)], withRowAnimation: .Automatic)
                    }
                }
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
        var cardView : CardView! = nil
        
        let newUrl = NSURL(string: "http://www.youtube.com")!
        let embedUrl = NSURL(string: resource.url)!
        let vidwebUrl = NSURL(string: resource.url)!
        
        
        let youtube = Creator(name:"Youtube", url: newUrl, favicon:NSURL(string:"http://coopkanicstang-development.s3.amazonaws.com/brandlogos/logo-youtube.png"), iosStore:nil)
        
        
        let videoData:NSMutableDictionary = NSMutableDictionary()
        let videoMedia:NSMutableDictionary = NSMutableDictionary()
        videoMedia["description"] = ""
        videoMedia["posterImageUrl"] = "http://i1.ytimg.com/vi/\(getYoutubeID(resource.url))/mqdefault.jpg"
        
        videoData["media"] = videoMedia
        videoCard = VideoCard(title: resource.title, embedUrl: embedUrl, url: vidwebUrl, creator: youtube, data: videoData)
        
        
        cardView = CardView.createCardView(videoCard!, layout: .VideoCardShortFull)!
        
        self.videoViews.insert(cardView, atIndex: 0)
        
        if (cardView != nil) {
            cardView.delegate = self
            self.resources.insert(resource, atIndex: 0)
            if(self.currentType == .Video){
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)], withRowAnimation: .Automatic)
            }
        }
        
    }
    
    private func insertYoutubeFromChannel(resource: Resource, description: String, completionHandler: (Bool) -> Void) {
        var videoCard:VideoCard!
        var cardView : CardView! = nil
        
        let newUrl = NSURL(string: "http://www.youtube.com")!
        
        let embedUrl = NSURL(string: "https://www.youtube.com/embed/\(resource.id)?rel=0")!
        let vidwebUrl = NSURL(string: String("https://www.youtube.com/watch?v=\(resource.id)"))!
        
        
        let youtube = Creator(name:"Youtube", url: newUrl, favicon:NSURL(string:"http://coopkanicstang-development.s3.amazonaws.com/brandlogos/logo-youtube.png"), iosStore:nil)
        
        
        let videoData:NSMutableDictionary = NSMutableDictionary()
        let videoMedia:NSMutableDictionary = NSMutableDictionary()
        videoMedia["description"] =  description
        videoMedia["posterImageUrl"] = "http://i1.ytimg.com/vi/\(resource.id)/mqdefault.jpg"
        
        
        videoData["media"] = videoMedia
        videoCard = VideoCard(title: resource.title, embedUrl: embedUrl, url: vidwebUrl, creator: youtube, data: videoData)
        
        
        cardView = CardView.createCardView(videoCard!, layout: .VideoCardShortFull)!
        
        //self.videoViews.insert(cardView, atIndex: 0)
        self.videoViews.append(cardView)
        
        if (cardView != nil) {
            cardView.delegate = self
            //self.resources.insert(resource, atIndex: 0)
            self.resources.append(resource)
            if(self.currentType == .Video){
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forItem: videoViews.count-1, inSection: 0)], withRowAnimation: .Automatic)
            }
        }
    }
    
    // MARK: Cru CC Youtube Video Retrieval
    //Get the data from Cru Central Coast's youtube channel
    func getVideosForChannel(success: Bool) {
        // Get the selected channel's playlistID value from the channelsDataArray array and use it for fetching the proper video playlst.
        
        // Form the request URL string.
        var urlString = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=\(PageSize)&playlistId=\(cruUploadsID)&key=\(apiKey)"
        
        if nextPageToken != "" {
            urlString = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=\(PageSize)&pageToken=\(nextPageToken)&playlistId=\(cruUploadsID)&key=\(apiKey)"
        }
        
        // Create a NSURL object based on the above string.
        let targetURL = NSURL(string: urlString)
        
        // Fetch the playlist from Google.
        performGetRequest(targetURL, completion: { (data, HTTPStatusCode, error) -> Void in
            if HTTPStatusCode == 200 && error == nil {
                // Convert the JSON data into a dictionary.
                do {
                    let resultsDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! Dictionary<NSObject, AnyObject>
                    
                    //Get next page token
                    self.nextPageToken = resultsDict["nextPageToken"] as! String
                    
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
                }
                catch {
                    print("Error loading videos")
                }
                
            }
                
            else {
                print("HTTP Status Code = \(HTTPStatusCode)\n")
                print("Error while loading channel videos: \(error)\n")
            }
            
            MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
        })
    }
    
    func finished(success: Bool) {
        print("\nFinsihed!\n")
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
        if currentType == .Video && indexPath.row > pageNum * 4 {
            var success = true
            getVideosForChannel(success)
            pageNum = pageNum + 1
        }
        
    }
    
    //Return the number of cards depending on the type of resource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (currentType){
        case .Article:
            return articleViews.count
        case .Audio:
            return audioViews.count
        case .Video:
            return videoViews.count
        }
    }
    
    //Configures each cell in the table view as a card and sets the UI elements to match with the Resource data
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "CardTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! CardTableViewCell
        let cardView: CardView?
        
        switch (currentType){
        case .Article:
            cardView = articleViews[indexPath.row]
        case .Audio:
            cardView = audioViews[indexPath.row]
        case .Video:
            cardView = videoViews[indexPath.row]
        }
        
        //Add the newl card view to the cell
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
}
