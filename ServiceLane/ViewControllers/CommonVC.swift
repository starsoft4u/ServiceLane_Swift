//
//  ViewController.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/12.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import ActiveLabel

class CommonVC: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        viewWillAppear(animated, navigationBar: true)
    }

    func viewWillAppear(_ animated: Bool, navigationBar: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(!navigationBar, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        hideKeyboardWhenTappedAround()
    }
}

extension CommonVC {
    func setupTermsAndConditions(label: ActiveLabel) {
        let terms = ActiveType.custom(pattern: "\\sterms of service\\b")
        let privacy = ActiveType.custom(pattern: "\\sprivacy policy\\b")

        label.customize { item in
            item.enabledTypes = [terms, privacy]

            item.customColor[terms] = UIColor.white
            item.customSelectedColor[terms] = UIColor.darkGrey
            item.handleCustomTap(for: terms) { _ in
                let vc = AppStoryboard.Main.viewController(viewControllerClass: PrivacyPolicyVC.self)
                vc.isPrivacy = false
                self.navigationController?.pushViewController(vc, animated: true)
            }

            item.customColor[privacy] = UIColor.white
            item.customSelectedColor[privacy] = UIColor.darkGrey
            item.handleCustomTap(for: privacy) { _ in
                let vc = AppStoryboard.Main.viewController(viewControllerClass: PrivacyPolicyVC.self)
                vc.isPrivacy = true
                self.navigationController?.pushViewController(vc, animated: true)
            }

            item.configureLinkAttribute = { type, attr, _ in
                var attribute = attr
                switch type {
                case terms, privacy:
                    attribute[NSAttributedString.Key.underlineStyle] = NSUnderlineStyle.single.rawValue
                default:
                    break
                }
                return attribute
            }
        }
    }
}
