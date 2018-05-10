//
//  SegmentedControlInNavBarView.swift
//  CruCentralCoast
//
//  Created by Michael Cantrell on 4/18/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class SegmentedControlInNavBarView: UIView {
    
    @IBOutlet weak var fakeBottomOfNavBar: UIView!
    
    var delegate: SegmentedControlInNavBarViewProtocol?
    @IBOutlet weak var cruSegmentedControl: CruSegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.fakeBottomOfNavBar.addBorders(edges: .bottom, color: .navBarLineGray, thickness: 0.5)
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: CruSegmentedControl) {
        self.delegate?.segmentedControlValueChanged(sender.selectedSegmentIndex)
    }
}

extension SegmentedControlInNavBarView: UpdateSegmentedControlDelegate {
    func setSegmentedControlValue(_ index: Int) {
        self.cruSegmentedControl.selectedSegmentIndex = index
    }
    
    
}

protocol SegmentedControlInNavBarViewProtocol {
    func segmentedControlValueChanged(_ index: Int) -> Void
}
