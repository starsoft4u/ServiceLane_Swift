//
//  MainVC.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/28.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit

class MainVC: UITabBarController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers = [
            AppStoryboard.Home.instance.instantiateInitialViewController()!,
            AppStoryboard.Main.instance.instantiateViewController(withIdentifier: "SearchNav"),
            AppStoryboard.Main.instance.instantiateViewController(withIdentifier: "ExploreNav"),
        ]

        if let _ = StoreKey.me.value {
            viewControllers! += [AppStoryboard.Account.instance.instantiateInitialViewController()!]
        }

        viewControllers! += [AppStoryboard.Settings.instance.instantiateInitialViewController()!]
    }
}
