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
    private var resources = [Resource]()
    private var articles = [Article]()
    private var audioFiles = [Audio]()
    private var videos = [Video]()
    private var newVideos = [Video]()
    private var urlString: String!
    private var videosArray: Array<Dictionary<NSObject, AnyObject>> = []
    private var nextPageToken = ""
    private var pageNum = 1
    private var loadedResources = false
    private var numUploads: Int!
    private var numNewVideos: Int! // The number of new youtube videos from infinite scrolling
    
    private init() {
    }
    
    // MARK: - Functions
    
    func getArticles() -> [Article] {
        return articles
    }
    func getAudio() -> [Audio] {
        return audioFiles
    }
    func getVideos() -> [Video] {
        return videos
    }
    
    
    func loadResources(_ completion: @escaping ([Article], [Audio], [Video]) -> Void){
        if !loadedResources {
            
            CruClients.getServerClient().getData(DBCollection.Resource, insert: self.insertResource, completionHandler: { success in
                if success {
                    self.loadedResources = true
                    self.getVideosForChannel({ success in
                        completion(self.articles, self.audioFiles, self.videos)
                    })
                    
                }
            })
            //CruClients.getServerClient().getData(DBCollection.Resource, insert: insertResource, completionHandler: getVideosForChannel)
        }
        else {
            completion(articles, audioFiles, videos)
        }
        
        //serverClient.getData(DBCollection.Resource, insert: insertResource, completionHandler: finished)
    }
    
    // MARK: - General Resource Handling
    //Get resources from database
    private func insertResource(_ dict : NSDictionary) {
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
    
    // MARK: - Article Functions
    /* Helper function to insert an article resource */
    fileprivate func insertArticle(_ resource: Resource,completionHandler: (Bool) -> Void) {
        print("Inserting article")
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
        }
    }
    
    // MARK: - Audio Functions
    /* Creates new Audio object and inserts into table if necessary*/
    fileprivate func insertAudio(_ resource: Resource, completionHandler: (Bool) -> Void) {
        let newAud = Audio(id: resource.id, title: resource.title, url: resource.url, date: resource.date, tags: resource.tags, restricted: resource.restricted)
        newAud.prepareAudioFile()
        audioFiles.append(newAud)
        
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
                        
                        //let youtubeID = self.getYoutubeID(vidURL)
                        //let embedUrl = URL(string: vidURL)!
                        //let vidwebUrl = URL(string: vidURL)!
                        
                        let newVid = Video(id: resource.id, title: resource.title, url: resource.url, date: resource.date, tags: resource.tags, abstract: description, videoURL: vidURL, thumbnailURL: "", restricted: resource.restricted)
                        
                        self.videos.append(newVid!)
                }
            }
            else {
                let newVid = Video(id: resource.id, title: resource.title, url: resource.url, date: resource.date, tags: resource.tags, abstract: description, videoURL: videoUrl, thumbnailURL: "", restricted: resource.restricted)
                self.videos.append(newVid!)
            }
        }
    }
    
    //Get the data from Cru Central Coast's youtube channel
    private func getVideosForChannel(_ handler: @escaping (Bool)-> Void) {
        
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
                        let resource = Resource(id: videoID, title: snippetDict["title"] as? String, url: "https://www.youtube.com/watch?v=\(videoID)", type: "video", date: snippetDict["publishedAt"] as? String, tags: nil)!
                        
                        let newVid = Video(id: videoID, title: snippetDict["title"] as? String, url: resource.url, date: resource.date, tags: nil, abstract: snippetDict["description"] as? String, videoURL: resource.url, thumbnailURL: thumbnailURL as! String?,restricted: false)
                        
                        self.resources.append(resource)
                        self.videos.append(newVid!)
                        
                    }
                    self.pageNum = self.pageNum + 1
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
                    handler(false)
                    print("Error loading videos")
                }
                
            }
                
            else {
                handler(false)
                print("HTTP Status Code = \(HTTPStatusCode)\n")
                print("Error while loading channel videos: \(error)\n")
            }
            
            
        })
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
                        self.videosArray.append(snippetDict as [NSObject : AnyObject])
                        
                        let resource = Resource(id: videoID, title: snippetDict["title"] as? String, url: "https://www.youtube.com/watch?v=\(videoID)", type: "video", date: snippetDict["publishedAt"] as? String, tags: nil)!
                        
                        let newVid = Video(id: videoID, title: snippetDict["title"] as! String, url: resource.url, date: resource.date, tags: nil, abstract: snippetDict["description"] as? String, videoURL: resource.url, thumbnailURL: thumbnailURL as? String,restricted: false)
                        
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
