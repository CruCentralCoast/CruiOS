//
//  OptionQuestionCell.swift
//  Cru
//
//  Created by Peter Godkin on 5/10/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class OptionQuestionCell: UITableViewCell {
    static let selectOption = "Select Option"
    
    @IBOutlet weak var error: UILabel!
    @IBOutlet weak var question: UILabel!
    @IBOutlet weak var optionButton: UIButton!
    var presentingVC: SurveyViewController!
    var cgQuestion: CGQuestion!
    
    func isAnswered() -> Bool {
        
        return optionButton.currentTitle != OptionQuestionCell.selectOption
    }
    
    func getAnswer() -> CGQuestionAnswer {
        return CGQuestionAnswer(question: cgQuestion.id, value: optionButton.currentTitle!)
    }
    
    func validate() -> Bool {
        if (!isAnswered() && cgQuestion.required) {
            error.text = "Required Question"
            return false
        } else {
            error.text = ""
            return true
        }
    }
    
    func setQuestion(cgq: CGQuestion) {
        cgQuestion = cgq
        error.text = ""
        question.text = cgQuestion.question
        optionButton.setTitle(OptionQuestionCell.selectOption, forState: .Normal)
    }
    
    func setOptionButtonText(text : String){
        optionButton.setTitle(text, forState: .Normal)
    }
    
    @IBAction func showOptions(sender: AnyObject) {
        presentingVC.showOptions(cgQuestion.options, optionHandler: setOptionButtonText, theCell: self)
        //presentingVC.performSegueWithIdentifier("showOptions", sender: presentingVC)
    }
}
