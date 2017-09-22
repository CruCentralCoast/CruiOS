//
//  ArticlesTabViewController.swift
//  Cru
//
//  Created by Erica Solum on 9/19/17.
//  Copyright © 2017 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import DZNEmptyDataSet
import MRProgress

class ArticlesTabViewController: UITableViewController, ResourceDelegate, IndicatorInfoProvider, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    // MARK: - Properties
    var articles = [Article]()
    var filteredArticles = [Article]()
    var hasConnection = true
    var emptyTableImage: UIImage?
    var searchActivated = false
    var searchPhrase: String?
    var noResultsString: NSAttributedString!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Make the line between cells invisible
        tableView.separatorStyle = .none
        tableView.backgroundColor = Colors.googleGray
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160
        
        print("Articles Tab VC Initiated")
        //ResourceManager.sharedInstance.addObserverForResources(self)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTable), name: NSNotification.Name.init("refresh"), object: nil)
        
        CruClients.getServerClient().checkConnection(self.finishConnectionCheck)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Refresh table when article's description is finished loading
    func refreshTable(_ notification: NSNotification) {
        self.tableView.reloadData()
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
            
            if ResourceManager.sharedInstance.hasAddedArticleDelegate() {
                self.articles = ResourceManager.sharedInstance.getArticles()
                self.tableView.reloadData()
                MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
            }
            else {
                ResourceManager.sharedInstance.addArticleDelegate(self)
            }
            
        }
        
    }

    // MARK: - Pager Tab Whatever Delegate Functions
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "ARTICLES")
    }

    // MARK: - Table View Delegate Functions
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchActivated {
            return filteredArticles.count
        }
        return articles.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleTableViewCell", for: indexPath) as! ArticleTableViewCell
        let dateFormatString = "MMM d, yyyy"
        
        // Configure the cell...
        var art: Article
        if searchActivated {
            art = filteredArticles[indexPath.row]
        }
        else {
            art = articles[indexPath.row]
        }
        
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
            vc.artTitle = art.title
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
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
                noResultsString = NSAttributedString(string: "No articles found with the phrase \(ResourceManager.sharedInstance.getSearchPhrase())", attributes: attributes)
            }
            else {
                noResultsString = NSAttributedString(string: "No article resources found", attributes: attributes)
            }
        }
        
        return noResultsString
    }
    
    // MARK: - Resources Delegate Function
    func resourcesLoaded(_ loaded: Bool) {
        print("Notified article VC with resources loaded: \(loaded)")
        if loaded {
            self.articles = ResourceManager.sharedInstance.getArticles()
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
