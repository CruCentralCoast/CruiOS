//
//  IntroPageContainerVC.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 9/28/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class IntroPageContainerVC: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.pageControl.pageIndicatorTintColor = UIColor.cruGray.withAlphaComponent(0.5)
        self.pageControl.currentPageIndicatorTintColor = UIColor.cruGray
        self.pageControl.isUserInteractionEnabled = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pageVC = segue.destination as? IntroPageVC {
            pageVC.pageControlDelegate = self
        }
    }
}

extension IntroPageContainerVC: PageControlDelegate {
    func didUpdatePageCount(_ count: Int) {
        self.pageControl.numberOfPages = count
    }
    
    func didUpdatePageIndex(_ index: Int) {
        self.pageControl.currentPage = index
        // Hide the page control dots on the last intro screen
        self.pageControl.isHidden = self.pageControl.currentPage == self.pageControl.numberOfPages - 1
    }
}

protocol PageControlDelegate {
    func didUpdatePageCount(_ count: Int)
    func didUpdatePageIndex(_ index: Int)
}
