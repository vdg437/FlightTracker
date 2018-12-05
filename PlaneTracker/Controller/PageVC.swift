//
//  PageVC.swift
//  PlaneTracker
//
//  Created by van der Goot Dave on 05/12/2018.
//  Copyright © 2018 van der Goot Dave. All rights reserved.
//

import UIKit

class PageVC: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    lazy var subViewControllers:[UIViewController] = {
        return[
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "flightNumberVC") as! FlightNumberVCViewController,
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mapView") as! MapVC,
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "listVC") as! FlightListTVC
        ]
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        setViewControllers([subViewControllers[0]], direction: .forward, animated: true, completion: nil)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return subViewControllers.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex:Int = subViewControllers.index(of: viewController) ?? 0
        if(currentIndex <= 0){
            return nil
        }
        return subViewControllers[currentIndex-1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex:Int = subViewControllers.index(of: viewController) ?? 0
        if(currentIndex <= 0){
            return nil
        }
        return subViewControllers[currentIndex+1]
    }
    
    // MARK: - Navigation
}
