//
//  PlanVC.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/15.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit

class PlanVC: CommonVC {
    @IBOutlet weak var planName: UILabel!
    @IBOutlet weak var startedOn: UILabel!
    @IBOutlet weak var expiredOn: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Load
        loadPlanData()
    }

    fileprivate func loadPlanData() {
        let params: [String: Any] = [
            "userId": StoreKey.me.value!.id
        ]
        Helper.with(self).post(url: "/user/viewPlan", params: params) { [weak self] res in
            guard let `self` = self else { return }

            let currentPlan = Plan(json: res["data"]["curPlan"][0])

            self.planName.text = currentPlan.title
            self.startedOn.text = Helper.date(from: currentPlan.startOn, to: "dd/MM/yyyy")
            self.expiredOn.text = Helper.date(from: currentPlan.expireOn, to: "dd/MM/yyyy")
        }
    }
}
