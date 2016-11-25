//
//  SurveyViewController.swift
//  Cru
//
//  Created by Peter Godkin on 5/5/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import MRProgress
import UIKit

class SurveyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPopoverPresentationControllerDelegate {
    
    let textId = "text-cell"
    let optionId = "option-cell"
    
    var questions = [UITableViewCell]()
    var optionsToBeShown = [String]()
    var optionHandler: ((String)->())!
    var optionCell: OptionQuestionCell!
    
    private var ministry: Ministry!
    
    @IBOutlet weak var table: UITableView!
    
    func setMinistry(min: Ministry) {
        ministry = min
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MRProgressOverlayView.showOverlayAddedTo(self.view, animated: true)
        
        CruClients.getServerClient().getDataIn(DBCollection.Ministry, parentId: ministry.id, child: DBCollection.Question,
            insert: insertQuestion, completionHandler: finishInserting)
        // Do any additional setup after loading the view.
    }
    
    private func insertQuestion(dict: NSDictionary) {
        let question = CGQuestion(dict: dict)
        
        var cell: UITableViewCell
        switch (question.type) {
            case .TEXT:
                cell = self.table.dequeueReusableCellWithIdentifier(textId)!
                let textCell = cell as! TextQuestionCell
                textCell.answer.layer.borderWidth = 1
                textCell.answer.layer.borderColor = UIColor.lightGrayColor().CGColor
                textCell.setQuestion(question)
                break;

            case .SELECT:
                cell = self.table.dequeueReusableCellWithIdentifier(optionId)!
                let selectCell = cell as! OptionQuestionCell
                selectCell.setQuestion(question)
                selectCell.presentingVC = self
                break;
            
        }
        questions.append(cell)
        table.insertRowsAtIndexPaths([NSIndexPath(forItem: 0, inSection: 0)], withRowAnimation: .Automatic)
        
    }
    
    private func finishInserting(success: Bool) {
        table.reloadData()
        
        
        MRProgressOverlayView.dismissOverlayForView(self.view, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = questions[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let cell = questions[indexPath.row]
        switch (cell.reuseIdentifier!) {
            case textId:
                return 200
                
            case optionId:
                return 150.0
                
            default:
                return 100
        }
    }

    @IBAction func submitPressed(sender: AnyObject) {
        if (validateAnswers()) {
            self.performSegueWithIdentifier("showCGS", sender: self)
        }
    }
    
    private func validateAnswers() -> Bool {
        let optionCells = questions.filter{ $0 is OptionQuestionCell } as! [OptionQuestionCell]
        //optionCells.forEach { $0.validate() }
        return optionCells.reduce(true) {(result, cur) in result && cur.validate()}
    }
    
    func showOptions(options: [String], optionHandler: ((String)->()), theCell: OptionQuestionCell){
        self.optionCell = theCell
        optionsToBeShown = options
        self.optionHandler = optionHandler
        self.performSegueWithIdentifier("showOptions", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "showOptions"){
            if let popupVC = segue.destinationViewController as? SearchableOptionsVC{
                
                popupVC.options = optionsToBeShown
                popupVC.optionHandler = optionHandler
                popupVC.preferredContentSize = CGSize(width: self.view.frame.width * 0.97, height: self.view.frame.height * 0.77)
                popupVC.popoverPresentationController!.sourceRect = CGRectMake(CGRectGetMidX(self.view.bounds), (optionCell.frame.origin.y),0,0)
                popupVC.popoverPresentationController?.permittedArrowDirections = .Any
                popupVC.popoverPresentationController?.sourceView = self.table
                
                let controller = popupVC.popoverPresentationController
                
                if(controller != nil){
                    controller?.delegate = self
                }
            }
        } else if (segue.identifier == "showCGS"){
            if let selectCGVC = segue.destinationViewController as? SelectCGVC {
                // we're ignoring the tet question answers for now, as they will be sent differently
                selectCGVC.setAnswers(getOptionQuestionAnswers())
                selectCGVC.setMinistry(ministry.id)
            }
        }
    }
    
    private func getOptionQuestionAnswers() -> [[String:String]] {
        var optionQuestionCells = questions.filter{ $0 is OptionQuestionCell } as! [OptionQuestionCell]
        optionQuestionCells = optionQuestionCells.filter{ $0.isAnswered() != nil }
        return optionQuestionCells.map{ $0.getAnswer().getDict() }
    }

    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }

}
