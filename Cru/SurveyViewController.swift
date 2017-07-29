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
    
    fileprivate var ministry: Ministry!
    
    @IBOutlet weak var table: UITableView!
    
    func setMinistry(_ min: Ministry) {
        ministry = min
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MRProgressOverlayView.showOverlayAdded(to: self.view, animated: true)
        
        CruClients.getServerClient().getDataIn(DBCollection.Ministry, parentId: ministry.id, child: DBCollection.Question,
            insert: insertQuestion, completionHandler: finishInserting)
        // Do any additional setup after loading the view.
    }
    
    fileprivate func insertQuestion(_ dict: NSDictionary) {
        let question = CGQuestion(dict: dict)
        
        var cell: UITableViewCell
        switch (question.type) {
            case .TEXT:
                cell = self.table.dequeueReusableCell(withIdentifier: textId)!
                let textCell = cell as! TextQuestionCell
                textCell.answer.layer.borderWidth = 1
                textCell.answer.layer.borderColor = UIColor.lightGray.cgColor
                textCell.setQuestion(question)
                break;

            case .SELECT:
                cell = self.table.dequeueReusableCell(withIdentifier: optionId)!
                let selectCell = cell as! OptionQuestionCell
                selectCell.setQuestion(question)
                selectCell.presentingVC = self
                break;
            
        }
        questions.append(cell)
        table.insertRows(at: [IndexPath(item: 0, section: 0)], with: .automatic)
        
    }
    
    fileprivate func finishInserting(_ success: Bool) {
        table.reloadData()
        
        
        MRProgressOverlayView.dismissOverlay(for: self.view, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = questions[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
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

    @IBAction func submitPressed(_ sender: AnyObject) {
        if (validateAnswers()) {
            self.performSegue(withIdentifier: "showCGS", sender: self)
        }
    }
    
    fileprivate func validateAnswers() -> Bool {
        let optionCells = questions.filter{ $0 is OptionQuestionCell } as! [OptionQuestionCell]
        //optionCells.forEach { $0.validate() }
        return optionCells.reduce(true) {(result, cur) in result && cur.validate()}
    }
    
    func showOptions(_ options: [String], optionHandler: @escaping ((String)->()), theCell: OptionQuestionCell){
        self.optionCell = theCell
        optionsToBeShown = options
        self.optionHandler = optionHandler
        self.performSegue(withIdentifier: "showOptions", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "showOptions"){
            if let popupVC = segue.destination as? SearchableOptionsVC{
                
                popupVC.options = optionsToBeShown
                popupVC.optionHandler = optionHandler
                popupVC.preferredContentSize = CGSize(width: self.view.frame.width * 0.97, height: self.view.frame.height * 0.77)
                popupVC.popoverPresentationController!.sourceRect = CGRect(x: self.view.bounds.midX, y: (optionCell.frame.origin.y),width: 0,height: 0)
                popupVC.popoverPresentationController?.permittedArrowDirections = .any
                popupVC.popoverPresentationController?.sourceView = self.table
                
                let controller = popupVC.popoverPresentationController
                
                if(controller != nil){
                    controller?.delegate = self
                }
            }
        } else if (segue.identifier == "showCGS"){
            if let selectCGVC = segue.destination as? SelectCGVC {
                // we're ignoring the tet question answers for now, as they will be sent differently
                selectCGVC.setAnswers(getOptionQuestionAnswers())
                selectCGVC.setMinistry(ministry.id)
            }
        }
    }
    
    fileprivate func getOptionQuestionAnswers() -> [[String:String]] {
        var optionQuestionCells = questions.filter{ $0 is OptionQuestionCell } as! [OptionQuestionCell]
        optionQuestionCells = optionQuestionCells.filter{ $0.isAnswered() }
        return optionQuestionCells.map{ $0.getAnswer().getDict() }
    }

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

}
