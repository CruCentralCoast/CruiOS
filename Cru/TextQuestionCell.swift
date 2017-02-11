//
//  TextQuestionCell.swift
//  Cru
//
//  Created by Peter Godkin on 5/10/16.
//  Copyright © 2016 Jamaican Hopscotch Mafia. All rights reserved.
//

import UIKit

class TextQuestionCell: UITableViewCell {

    @IBOutlet weak var answer: UITextView!
    
    @IBOutlet weak var question: UILabel!
    
    var cgQuestion: CGQuestion!

    func setQuestion(_ cgq: CGQuestion) {
        cgQuestion = cgq
        question.text = cgQuestion.question
        answer.text = ""
    }
}
