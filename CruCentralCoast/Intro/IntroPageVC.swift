//
//  IntroPageVC.swift
//  CruCentralCoast
//
//  Created by Tyler Dahl on 9/27/18.
//  Copyright © 2018 Landon Gerrits. All rights reserved.
//

import UIKit

class IntroPageVC: UIPageViewController {
    
    var pageControlDelegate: PageControlDelegate?
    
    private lazy var pages: [UIViewController] = {
        let storyboard = UIStoryboard(name: "Intro", bundle: nil)
        
        let welcomeVC = storyboard.instantiateViewController(withIdentifier: "IntroWelcomeVC")
        
        let termsOfServiceVC = storyboard.instantiateViewController(IntroTermsOfServiceVC.self)
        termsOfServiceVC.pageVCDelegate = self
        let navTOS = UINavigationController(rootViewController: termsOfServiceVC)
        navTOS.navigationBar.barTintColor = UIColor.white
        navTOS.navigationBar.prefersLargeTitles = true
        
        let privacyPolicyVC = storyboard.instantiateViewController(IntroPrivacyPolicyVC.self)
        privacyPolicyVC.pageVCDelegate = self
        let navPP = UINavigationController(rootViewController: privacyPolicyVC)
        navPP.navigationBar.barTintColor = UIColor.white
        navPP.navigationBar.prefersLargeTitles = true
        
        let chooseCampusVC = ChooseCampusVC()
        chooseCampusVC.pageVCDelegate = self
        let navCC = UINavigationController(rootViewController: chooseCampusVC)
        navCC.navigationBar.barTintColor = UIColor.white
        
        // TODO: Re-enable privacy policy screen when we have an updated privacy policy
        return [welcomeVC, navTOS, /*navPP,*/ navCC]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        self.delegate = self
        
        self.setViewControllers([self.pages[0]], direction: .forward, animated: true, completion: nil)
        self.pageControlDelegate?.didUpdatePageCount(self.pages.count)
    }
}

extension IntroPageVC: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let viewController = self.viewControllers?.first else { return }
        guard let index = self.pages.index(of: viewController) else { return }
        self.pageControlDelegate?.didUpdatePageIndex(index)
    }
}

extension IntroPageVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = self.pages.index(of: viewController) else { return nil }
        if index <= 0 { return nil }
        // Don't allow user to go back from choose campus screen
        if index == self.pages.count - 1 { return nil }
        return self.pages[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = self.pages.index(of: viewController) else { return nil }
        if index >= self.pages.count - 1 { return nil }
        // Don't allow user to advance without agreeing to TOS and Privacy Policy
        if index == 1 || index == 2 { return nil }
        return self.pages[index + 1]
    }
}

extension IntroPageVC: PageVCDelegate {
    func moveToNextPage() {
        guard let viewController = self.viewControllers?.first else { return }
        guard let index = self.pages.index(of: viewController), index < self.pages.count - 1 else { return }
        self.setViewControllers([self.pages[index + 1]], direction: .forward, animated: true) { finished in
            self.pageControlDelegate?.didUpdatePageIndex(index + 1)
        }
    }
    
    func moveToPreviousPage() {
        guard let viewController = self.viewControllers?.first else { return }
        guard let index = self.pages.index(of: viewController), index > 0 else { return }
        self.setViewControllers([self.pages[index - 1]], direction: .reverse, animated: true) { finished in
            self.pageControlDelegate?.didUpdatePageIndex(index - 1)
        }
    }
    
    func finishOnboarding() {
        LocalStorage.preferences.set(true, forKey: .onboarded)
    }
}

protocol PageVCDelegate {
    func moveToNextPage()
    func moveToPreviousPage()
    func finishOnboarding()
}
