//
//  TutorialVC.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/12.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import CHIPageControl

struct TutorialCell {
    var image: UIImage?
    var title: String?
    var description: String?
}

class TutorialVC: CommonVC {
    @IBOutlet weak var pageControlContainer: UIView!

    var cells: [TutorialCell] = []
    var pages: [UIViewController] = []
    var pageVC: UIPageViewController!
    var pageControl: CHIPageControlJaloro!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated, navigationBar: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup the pages
        loadPages()

        // Present the PageViewController
        if let vc = pages.first {
            pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
            pageVC.dataSource = self
            pageVC.delegate = self
            pageVC.setViewControllers([vc], direction: .forward, animated: false, completion: nil)

            view.addSubview(pageVC.view)
            view.sendSubviewToBack(pageVC.view)
        }

        view.layoutIfNeeded()

        // Setup the PageControl
        pageControl = CHIPageControlJaloro(frame: pageControlContainer.bounds)
        pageControl.numberOfPages = pages.count
        pageControl.tintColor = UIColor.darkGrey
        pageControl.currentPageTintColor = UIColor.white
        pageControl.elementWidth = 24
        pageControl.elementHeight = 6
        pageControl.radius = 3
        pageControlContainer.addSubview(pageControl)
    }

    fileprivate func loadPages() {
        cells += [TutorialCell(image: #imageLiteral(resourceName: "tutorial1"), title: "Get listed", description: "We connect service providers with clients in Grenada & beyond")]
        cells += [TutorialCell(image: #imageLiteral(resourceName: "tutorial2"), title: "Get found", description: "Sign up today to instantly expose your business to Grenada & beyond")]
        cells += [TutorialCell(image: #imageLiteral(resourceName: "tutorial3"), title: "Get hired", description: "Publish your profile, get new leads & start earning money today")]

        cells.forEach { cell in
            if let vc = storyboard?.instantiateViewController(withIdentifier: "TutorialCellVC") as? TutorialCellVC {
                vc.cell = cell
                pages += [vc]
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        StoreKey.launchCount.value += 1
    }
}

extension TutorialVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard var pageIndex = pages.index(of: viewController) else {
            return nil
        }
        pageIndex -= 1
        guard 0..<pages.count ~= pageIndex else {
            return nil
        }
        return pages[pageIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard var pageIndex = pages.index(of: viewController) else {
            return nil
        }
        pageIndex += 1
        guard 0..<pages.count ~= pageIndex else {
            return nil
        }
        return pages[pageIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let vc = pageViewController.viewControllers?.first, let pageIndex = pages.index(of: vc) {
                pageControl.set(progress: pageIndex, animated: true)
            }
        }
    }
}

