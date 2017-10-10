//
//  ResourceManager.swift
//  Cru
//
//  Created by Erica Solum on 9/17/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import Foundation
import ReadabilityKit
import Alamofire
import HTMLReader

class ResourceManager {
    // MARK: - Shared Instance
    static let sharedInstance = ResourceManager()
    private var leaderResources = [Resource]()
    private var filteredLeaderResources = [Resource]()
    private var resources = [Resource]()
    private var articles = [Article]()
    private var filteredArticles = [Article]()
    private var audioFiles = [Audio]()
    private var filteredAudio = [Audio]()
    private var videos = [Video]()
    private var filteredVideos = [Video]()
    private var tags = [ResourceTag]()
    private var filteredTags = [ResourceTag]()
    private var newVideos = [Video]()
    var urlString: String!
    private var delegates = [ResourceDelegate]()
    var searchDelegate: ResourceDelegate?
    private var articleDelAdded = false
    private var audioDelAdded = false
    private var videoDelAdded = false
    private var leaderDelAdded = false
    private var nextPageToken = ""
    private var pageNum = 1
    private var loadedResources = false {
        didSet {
            for del in delegates {
                del.resourcesLoaded(loadedResources)
            }
            print("Set loaded resources")
        }
    }
    private var loadedResourceTags = false
    private var youtubeLoaded = false
    private var hasConnection = true
    private var numUploads: Int!
    private var downloadGroup: DispatchGroup?
    private var searchActivated = false
    private var searchPhrase = ""
    
    private var numNewVideos: Int! // The number of new youtube videos from infinite scrolling
    
    private init() {
    }
    
    // MARK: - Functions
    
    func doesHaveConnection() -> Bool {
        return hasConnection
    }
    func isSearchActivated() -> Bool {
        return searchActivated
    }
    
    func getArticles() -> [Article] {
        if searchActivated {
            return filteredArticles
        }
        return articles
    }
    func getAudio() -> [Audio] {
        if searchActivated {
            return filteredAudio
        }
        return audioFiles
    }
    func getVideos() -> [Video] {
        if searchActivated {
            return filteredVideos
        }
        return videos
    }
    
    func getResourceTags() -> [ResourceTag] {
        return tags
    }
    
    
    
    func getLeaderResources() -> [Resource] {
        if searchActivated {
            return filteredLeaderResources
        }
        return leaderResources
    }
    
    
    // MARK: - Set Functions
    
    
    // MARK: - Resource Delegate Functions
    func addArticleDelegate(_ delegate: ResourceDelegate) {
        articleDelAdded = true
        self.delegates.append(delegate)
    }
    func hasAddedArticleDelegate() -> Bool {
        return articleDelAdded
    }
    
    func addAudioDelegate(_ delegate: ResourceDelegate) {
        audioDelAdded = true
        self.delegates.append(delegate)
    }
    func hasAddedAudioDelegate() -> Bool {
        return audioDelAdded
    }
    
    func addVideoDelegate(_ delegate: ResourceDelegate) {
        videoDelAdded = true
        self.delegates.append(delegate)
    }
    func hasAddedVideoDelegate() -> Bool {
        return videoDelAdded
    }
    
    func addLeaderDelegate(_ delegate: ResourceDelegate) {
        leaderDelAdded = true
        self.delegates.append(delegate)
    }
    func hasAddedLeaderDelegate() -> Bool {
        return leaderDelAdded
    }
    
    // MARK: - Search Functions
    func getFilteredTags() -> [ResourceTag] {
        return filteredTags
    }
    func getSearchPhrase() -> String {
        return searchPhrase
    }
    func setFilteredTags(tags: [ResourceTag]) {
        self.searchActivated = true
        self.filteredTags = tags
    }
    func setSearchPhrase(phrase: String) {
        self.searchPhrase = phrase
        self.searchActivated = true
    }
    func resetSearch() {
        self.searchActivated = false
        self.filteredTags = tags
        self.searchPhrase = ""
    }
    
    //Search modal calls this when "Apply" is tapped
    func applyFilters(_ tags: [ResourceTag], searchText: String?) {
        searchActivated = true
        filteredTags = tags
        
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
            return true
        }
        
        if searchText != nil {
            filteredAudio = taggedAudio.filter { file in
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
            filteredAudio = taggedAudio
            filteredVideos = taggedVideos
        }
        print("Search delegate refresh data")
        NotificationCenter.default.post(name: NSNotification.Name.init("searchRefresh"), object: nil)
    }
    
    // MARK: - Loading Resources
    func loadResourceTags() {
        if !self.loadedResourceTags {
            //Also get resource tags and store them
            CruClients.getServerClient().getData(DBCollection.ResourceTags, insert: self.insertResourceTag, completionHandler: {success in
                
                self.loadedResourceTags = success
            })
        }
    }
    
    func loadResources(_ completion: @escaping (Bool, Bool) -> Void){
        if !loadedResources {
            CruClients.getServerClient().getData(.ResourcePages, insert: self.insertResourcePage) { _ in
                CruClients.getServerClient().getData(.Resource, insert: self.insertResource) { success in
                    self.loadedResources = success
                    if success {
                        self.getVideosForChannel({ success in
                            self.youtubeLoaded = success
                            if !success {
                                print("Could not load youtube videos")
                            }
                            completion(self.loadedResources, self.youtubeLoaded)
                        })
                    }
                }
            }
        } else {
            completion(self.loadedResources, self.youtubeLoaded)
        }
    }
    
    fileprivate func insertResourcePage(_ dict : NSDictionary) {
        let dateFormatter = GlobalUtils.getDefaultDateFormatter()
        let id = dict["_id"] as? String
        let title = dict["title"] as? String
        let url: String? = nil
        let type = ResourceType.Article
        let date = dict["publishedDate"] as? String
        let tags = dict["tags"] as? [String]
        let description = dict["content"] as? String
        let restricted = dict["restricted"] as? Bool ?? false
        let author = dict["author"] as? String
        
        // Create a Resource object from the dict
        let resource = Resource(id: id, title: title, url: url, type: type, date: date, tags: tags, description: description)!
        resource.restricted = restricted
        resource.author = author
        
        // Add it to our list of resources
        if restricted {
            self.leaderResources.append(resource)
        } else {
            self.resources.append(resource)
        }
        
        // Extra processing
        self.insertArticleFromResourcePage(resource)
    }
    
    // MARK: - General Resource Handling
    //Get resources from database
    private func insertResource(_ dict : NSDictionary) {
        let resource = Resource(dict: dict)!
        if resource.restricted! {
            leaderResources.append(resource)
        } else {
            resources.insert(resource, at: 0)
        }
        // Make sure to call downloadGroup.leave() when each resource has been inserted
        //downloadGroup?.enter()
        
        if (resource.type == ResourceType.Article) {
            insertArticle(resource)
        } else if (resource.type == ResourceType.Video) {
            insertVideo(resource)
        } else if (resource.type == ResourceType.Audio) {
            insertAudio(resource)
        }
    }
    
    func insertResourceTag(_ dict : NSDictionary) {
        //downloadGroup?.enter()
        let tag = ResourceTag(dict: dict)!
        tags.insert(tag, at: 0)
        //downloadGroup?.leave()
    }
    
    // MARK: - Article Functions
    /* Helper function to insert an article resource */
    fileprivate func insertArticle(_ resource: Resource,completionHandler: ((Bool) -> Void)? = nil) {
        print("Inserting article")
        let resUrl = URL(string: resource.url)
        guard let url = resUrl else {
            return
        }
        let newArt = Article(id: resource.id, title: resource.title, url: resource.url, date: resource.date, tags: resource.tags, abstract: resource.description, imgURL: "", restricted: resource.restricted, containsHTML: false)
        self.articles.append(newArt!)
        
        if resource.description == "" {
            //Use Readability to scrape article for description
            Readability.parse(url: url) { data in
                let description = data?.description ?? ""
                let imageUrl = data?.topImage ?? ""
                newArt?.abstract = description
                resource.description = description
                NotificationCenter.default.post(name: NSNotification.Name.init("refresh"), object: nil)
                //NotificationCenter.default.postNotificationName("refresh", object: nil)
                //let newArt = Article(id: resource.id, title: resource.title, url: resource.url, date: resource.date, tags: resource.tags, abstract: description, imgURL: imageUrl, restricted: resource.restricted)
                //self.articles.append(newArt!)
                //self.downloadGroup?.leave()
            }
        }
        /*else {
            let newArt = Article(id: resource.id, title: resource.title, url: resource.url, date: resource.date, tags: resource.tags, abstract: resource.description, imgURL: "", restricted: resource.restricted)
            self.articles.append(newArt!)
            //self.downloadGroup?.leave()
        }*/
    }
    
    fileprivate func insertArticleFromResourcePage(_ resource: Resource) {
        let article = Article(id: resource.id, title: resource.title, url: nil, date: resource.date, tags: resource.tags, abstract: resource.description, imgURL: "", restricted: resource.restricted, containsHTML: true)!
        
        self.articles.append(article)
    }
    
    // MARK: - Audio Functions
    /* Creates new Audio object and inserts into table if necessary*/
    fileprivate func insertAudio(_ resource: Resource, completionHandler: ((Bool) -> Void)? = nil) {
        print("Inserting audio")
        let newAud = Audio(id: resource.id, title: resource.title, url: resource.url, date: resource.date, tags: resource.tags, restricted: resource.restricted)
        newAud.prepareAudioFile()
        audioFiles.append(newAud)

        //downloadGroup?.leave()
    }
    
    
    // MARK: - Video Functions
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
    
    //Inserts a video resource
    fileprivate func insertVideo(_ resource: Resource, completionHandler: ((Bool) -> Void)? = nil) {
        let resUrl = URL(string: resource.url)
        guard let url = resUrl else {
            return
        }
        print("Inserting video")
        
        if resource.description == "" {
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
                            
                            let newVid = Video(id: resource.id, title: resource.title, url: resource.url, date: resource.date, tags: resource.tags, abstract: description, videoURL: vidURL, thumbnailURL: "", restricted: resource.restricted, fromYoutube: false)
                            
                            self.videos.append(newVid!)

                            //self.downloadGroup?.leave()
                    }
                }
                else {
                    let newVid = Video(id: resource.id, title: resource.title, url: resource.url, date: resource.date, tags: resource.tags, abstract: description, videoURL: videoUrl, thumbnailURL: "", restricted: resource.restricted, fromYoutube: false)
                    self.videos.append(newVid!)

                    //self.downloadGroup?.leave()
                }
            }
        }
        else {
            let newVid = Video(id: resource.id, title: resource.title, url: resource.url, date: resource.date, tags: resource.tags, abstract: resource.description, videoURL: "", thumbnailURL: "", restricted: resource.restricted, fromYoutube: false)
            self.videos.append(newVid!)
            
            //self.downloadGroup?.leave()
        }
        
        
    }
    
    //Get the data from Cru Central Coast's youtube channel
    private func getVideosForChannel(_ handler: @escaping (Bool)-> Void) {
        print("Getting videos from youtube")
        
        self.urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=\(Config.cruChannelID)&maxResults=\(PageSize)&order=date&type=video&key=\(Config.youtubeApiKey)"
        
        if nextPageToken != "" {
            self.urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=\(Config.cruChannelID)&maxResults=\(PageSize)&order=date&pageToken=\(nextPageToken)&type=video&key=\(Config.youtubeApiKey)"
            //self.urlString = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=\(PageSize)&pageToken=\(nextPageToken)&playlistId=\(Config.cruUploadsID)&key=\(Config.youtubeApiKey)"
            
        }
        
        //downloadGroup?.enter()
        
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
                        self.downloadGroup?.enter()
                        let idDict = (items[i] as Dictionary<String, AnyObject>)["id"] as! Dictionary<String, AnyObject>
                        let videoID = idDict["videoId"] as! String
                        
                        
                        let snippetDict = (items[i] as Dictionary<String, AnyObject>)["snippet"] as! Dictionary<String, AnyObject>
                        //self.videosArray.append(snippetDict as [NSObject : AnyObject])
                        // Initialize a new dictionary and store the data of interest.
                        //var thumbnailsDict = Dictionary<String, AnyObject>()
                        
                        
                        let thumbnailURL = ((snippetDict["thumbnails"] as! Dictionary<String, Any>)["default"] as! Dictionary<String, Any>)["url"]
                        //desiredPlaylistItemDataDict["videoID"] = (snippetDict["resourceId"] as! Dictionary<String, AnyObject>)["videoId"]
                        //desiredPlaylistItemDataDict["date"] = snippetDict["publishedAt"]
                        
                        var title: String
                        var url: String
                        var date: String
                        var desc: String
                        
                        if let t = snippetDict["title"] {
                            title = t as! String
                        }
                        else {
                            title = "Video"
                        }
                        
                        if let d = snippetDict["publishedAt"] {
                            date = d as! String
                        }
                        else {
                            date = ""
                        }
                        
                        if let des = snippetDict["description"] {
                            desc = des as! String
                        }
                        else {
                            desc = ""
                        }
                        
                        url = "https://www.youtube.com/watch?v=\(videoID)"
                        
                        
                        let resource = Resource(id: videoID, title: title, url: url, type: ResourceType.Video, date: date, tags: nil, description: desc)!
                        
                        let newVid = Video(id: videoID, title: title, url: resource.url, date: resource.date, tags: nil, abstract: desc, videoURL: resource.url, thumbnailURL: thumbnailURL as! String?,restricted: false, fromYoutube: true)
                        
                        self.resources.append(resource)
                        self.videos.append(newVid!)
                        //self.downloadGroup?.leave()
                        
                    }
                    self.pageNum = self.pageNum + 1
                    //self.downloadGroup?.leave()
                    handler(true)
                    //self.tableView.reloadData()
                    
                    /*if self.overlayRunning {
                        MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
                        self.overlayRunning = false
                        
                    }*/
                    
                    /*self.tableView.emptyDataSetSource = self
                    self.tableView.emptyDataSetDelegate = self
                    self.tableView.tableFooterView = UIView()*/
                }
                catch {
                    print("Error loading videos")
                    //self.downloadGroup?.leave()
                    handler(false)
                    
                }
                
            }
                
            else {
                //self.downloadGroup?.leave()
                print("HTTP Status Code = \(HTTPStatusCode)\n")
                print("Error while loading channel videos: \(error)\n")
                handler(false)
                
            }
            
            
        })
        //downloadGroup?.leave()
    }
    
    //Yes, this is similar to the function above but this one has a completion handler
    //Load youtube videos for infinite scrolling
    func loadYouTubeVideos(completionHandler: @escaping (Int, [Video]) -> Void) {
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
                        
                        //var thumbnailURL = ""
                        let thumbnailURL = ((snippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["default"] as! Dictionary<String, AnyObject>)["url"]
                        /*if let snip = snippetDict["thumbnails"] {
                            if let def = snip["default"] {
                                
                                if let url = def["url"] {
                                    thumbnailURL = url as! String
                                }
                            }
                        }*/
                        
                        // Append the desiredPlaylistItemDataDict dictionary to the videos array.
                        //self.videosArray.append(snippetDict as [NSObject : AnyObject])
                        
                        var desc: String
                        if let d = snippetDict["description"] {
                            desc = d as! String
                        }
                        else {
                            desc = ""
                        }
                        let url = "https://www.youtube.com/watch?v=\(videoID)"
                        
                        let resource = Resource(id: videoID, title: snippetDict["title"] as? String, url: url, type: ResourceType.Video, date: snippetDict["publishedAt"] as? String, tags: nil, description: desc)!
                        
                        let newVid = Video(id: videoID, title: snippetDict["title"] as! String, url: resource.url, date: resource.date, tags: nil, abstract: snippetDict["description"] as? String, videoURL: resource.url, thumbnailURL: thumbnailURL as? String,restricted: false, fromYoutube: true)
                        
                        self.resources.append(resource)
                        self.videos.append(newVid!)
                        self.newVideos.append(newVid!)
                    }
                    self.pageNum = self.pageNum + 1
                    
                    //self.tableView.tableFooterView = UIView()
                    completionHandler(self.numNewVideos, self.newVideos)
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
    
    private func performGetRequest(_ targetURL: URL!, completion: @escaping (_ data: Data?, _ HTTPStatusCode: Int, _ error: Error?) -> Void) {
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
    
}

protocol ResourceDelegate {
    func resourcesLoaded(_ loaded: Bool)
    func refreshData()
}
