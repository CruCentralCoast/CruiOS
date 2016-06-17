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

class ResourcesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, CardViewDelegate, SWRevealViewControllerDelegate {
    //MARK: Properties
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectorBar: UITabBar!
    
    
    var serverClient: ServerProtocol
    var resources = [Resource]()
    var cardViews = [CardView]()
    
    
    var currentType = ResourceType.Article
    var articleViews = [CardView]()
    var audioViews = [CardView]()
    var videoViews = [CardView]()
    var allViews = [CardView]()
    var audioPlayer:AVAudioPlayer!
    
    
    
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
        serverClient.getData(DBCollection.Resource, insert: insertResource, completionHandler: completion)
        
        tableView.backgroundColor = Colors.googleGray
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        
        //Set the nav title
        navigationItem.title = "Resources"
        
        self.navigationController!.navigationBar.titleTextAttributes  = [ NSFontAttributeName: UIFont(name: Config.fontBold, size: 20)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        selectorBar.tintColor = UIColor.whiteColor()
    }
    
    func completion(success: Bool) {
        if( success) {
            
        }
        MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
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
            insertArticle(resource, completionHandler: {error in })
        }
            
        else if (resource.type == ResourceType.Video) {
            if(resource.url.rangeOfString("youtube") != nil) {
                insertYoutube(resource, completionHandler: {error in })
            }
            else {
                insertGeneric(resource, completionHandler: {error in })
            }
        }
            
        else if (resource.type == ResourceType.Audio) {
            insertAudio(resource, completionHandler: {error in})
        }
    }
    
    /* Implement when tools support is requested */
    private func insertAudio(resource: Resource, completionHandler: (NSError?) -> Void) {
    
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
        completionHandler(nil)
        
    }
    
    /* Helper function to get and insert an article card */
    private func insertArticle(resource: Resource,completionHandler: (NSError?) -> Void) {
        Alamofire.request(.GET, resource.url)
            .responseString { responseString in
                guard responseString.result.error == nil else {
                    completionHandler(responseString.result.error!)
                    return
                    
                }
                guard let htmlAsString = responseString.result.value else {
                    let error = Error.errorWithCode(.StringSerializationFailed, failureReason: "Could not get HTML as String")
                    completionHandler(error)
                    return
                }
                
                
                let doc = HTMLDocument(string: htmlAsString)
                var abstract = ""
                var filteredContent = ""

                var articleCard:ArticleCard!
                var creator: Creator!
                
                let imgurUrl = NSURL(string: "https://unsplash.com/photos/rivAqXQNves")!
                
                let everyStudent = Creator(name:"everystudent.com", url:imgurUrl, favicon:NSURL(string:"http://1.everystudent.com/2013/logo4tm2.jpg"), iosStore:nil)
                
                let cru = Creator(name:"cru.org", url:imgurUrl, favicon:NSURL(string:"http://www.boomeranggmail.com/img/cru_logo.jpg"), iosStore:nil)
                
                let generic = Creator(name:"", url: NSURL(string:"")!, favicon:NSURL(string:"http://icons.iconarchive.com/icons/iconsmind/outline/512/Open-Book-icon.png"), iosStore:nil)
                
                //Use the right creator with the right favicon
                if(resource.url.rangeOfString("cru") != nil) {
                    creator = cru
                    
                    let absContent = doc.nodesMatchingSelector("p")
                    
                    abstract = absContent[0].textContent
                    
                    let content = doc.nodesMatchingSelector(".textImage")
                    
                    filteredContent = content[0].textContent
                    
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
                completionHandler(nil)
                
                
        }
    }
    
    /* Inserts an article from a generic source */
    private func insertGeneric(resource: Resource,completionHandler: (NSError?) -> Void) {
        Alamofire.request(.GET, resource.url)
            .responseString { responseString in
                guard responseString.result.error == nil else {
                    completionHandler(responseString.result.error!)
                    return
                    
                }
                guard let htmlAsString = responseString.result.value else {
                    let error = Error.errorWithCode(.StringSerializationFailed, failureReason: "Could not get HTML as String")
                    completionHandler(error)
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
              
                
                
                let _ = self.getYoutubeID(vidURL)
                
                
                let embedUrl = NSURL(string: vidURL)!
                let vidwebUrl = NSURL(string: vidURL)!
                
                
                let videoData:NSMutableDictionary = NSMutableDictionary()
                let videoMedia:NSMutableDictionary = NSMutableDictionary()
                videoMedia["description"] =  ""
                
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
                completionHandler(nil)
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
    
    
    private func insertYoutube(resource: Resource,completionHandler: (NSError?) -> Void) {
        var videoCard:VideoCard!
        var cardView : CardView! = nil
        
        let newUrl = NSURL(string: "http://www.youtube.com")!
        let embedUrl = NSURL(string: resource.url)!
        let vidwebUrl = NSURL(string: resource.url)!
        
        
        let youtube = Creator(name:"Youtube", url: newUrl, favicon:NSURL(string:"http://coopkanicstang-development.s3.amazonaws.com/brandlogos/logo-youtube.png"), iosStore:nil)
        
        
        let videoData:NSMutableDictionary = NSMutableDictionary()
        let videoMedia:NSMutableDictionary = NSMutableDictionary()
        
        videoData["media"] = videoMedia
        videoCard = VideoCard(title: resource.title, embedUrl: embedUrl, url: vidwebUrl, creator: youtube, data: videoData)
        
        
        cardView = CardView.createCardView(videoCard!, layout: .VideoCardShort)!
        
        
        
        self.videoViews.insert(cardView, atIndex: 0)
        
        if (cardView != nil) {
            cardView.delegate = self
            self.resources.insert(resource, atIndex: 0)
            if(self.currentType == .Video){
                self.tableView.insertRowsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)], withRowAnimation: .Automatic)
            }
        }
        completionHandler(nil)
    }
    
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
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