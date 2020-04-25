//
//  UserVC.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/15.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class UserVC: ButtonBarPagerTabStripViewController {
    var user: User!
    var portfolios: [Portfolio] = []
    var services: [ServicePackage] = []
    var reviews: [Review] = []

    override func viewDidLoad() {
        settings.style.buttonBarBackgroundColor = UIColor(rgb: 0xF0F1F0)
        settings.style.buttonBarHeight = 0
        settings.style.selectedBarHeight = 0

        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarMinimumInteritemSpacing = 8
        settings.style.buttonBarItemFont = UIFont(name: "WorkSans-Bold", size: 17) ?? UIFont.boldSystemFont(ofSize: 17)
        settings.style.buttonBarItemBackgroundColor = UIColor.clear
        settings.style.buttonBarItemTitleColor = UIColor(rgb: 0x0078C5)

        changeCurrentIndexProgressive = { (old, new, percent, changeCurrentIndex, animate) -> Void in
            guard changeCurrentIndex else { return }

            old?.backgroundColor = UIColor(rgb: 0xF0F1F0)
            new?.backgroundColor = UIColor.white
        }

        navigationItem.title = user.name
        
        super.viewDidLoad()

        loadUser()
    }

    fileprivate func loadUser() {
        let params: [String: Any] = [
            "userId": user.id,
        ]
        Helper.with(self).post(url: "/user/profile", params: params) { [weak self] res in
            guard let `self` = self else { return }
            self.user = User(json: res["data"]["userInfo"])
            self.portfolios = res["data"]["prList"].arrayValue.map(Portfolio.init)
            self.services = res["data"]["pvList"].arrayValue.map(ServicePackage.init)
            self.reviews = res["data"]["rvList"].arrayValue.map(Review.init)
            self.reloadPagerTabStripView()
        }
    }

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let identify = AppStoryboard.Main.viewController(viewControllerClass: IdentityVC.self)
        identify.user = user
        identify.services = services

        let review = AppStoryboard.Main.viewController(viewControllerClass: ReviewVC.self)
        review.user = user
        review.reviews = reviews

        let portfolio = AppStoryboard.Main.viewController(viewControllerClass: PortfolioVC.self)
        portfolio.user = user
        portfolio.portfolios = portfolios

        return [identify, review, portfolio]
    }
}
