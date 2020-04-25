//
//  StartUpPaymentVC.swift
//  ServiceLane
//
//  Created by raptor on 2018/7/30.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import RSSelectionMenu
import SwiftyStoreKit

enum Plans: String {
    case basicAnnual = "com.servicelane.myservicelane.basic.annual"
    case basicMontly = "com.servicelane.myservicelane.basic.monthly"
    case premiumAnnual = "com.servicelane.myservicelane.premium.annual"
    case premiumMontly = "com.servicelane.myservicelane.premium.monthly"
    case premiumGoldAAnnual = "com.servicelane.myservicelane.premiumgold.annual"
    case premiumGoldAMontly = "com.servicelane.myservicelane.premiumgold.monthly"
}

class StartUpPaymentVC: UITableViewController {
    @IBOutlet weak var basicLabel: UILabel!
    @IBOutlet weak var premiumLabel: UILabel!
    @IBOutlet weak var premiumGoldLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    @IBAction func onBasicAction(_ sender: UIButton) {
        let menu = RSSelectionMenu(selectionType: .Single, dataSource: ["Monthly - $25", "Annual - $250"], cellType: .Basic) { (cell, item, indexPath) in
            cell.textLabel?.text = item
            cell.tintColor = .orange
        }
        menu.setSelectedItems(items: [basicLabel.text!]) { (item, checked, selectedItems) in
            self.basicLabel.text = item
            self.basicLabel.tag = item!.starts(with: "Monthly") ? 0 : 1
        }
        menu.show(style: .Popover(sourceView: sender, size: CGSize(width: sender.bounds.width, height: 44)), from: self)
    }

    @IBAction func onPremiumAction(_ sender: UIButton) {
        let menu = RSSelectionMenu(selectionType: .Single, dataSource: ["Monthly - $49.95", "Annual - $499"], cellType: .Basic) { (cell, item, indexPath) in
            cell.textLabel?.text = item
            cell.tintColor = .orange
        }
        menu.setSelectedItems(items: [premiumLabel.text!]) { (item, checked, selectedItems) in
            self.premiumLabel.text = item
            self.premiumLabel.tag = item!.starts(with: "Monthly") ? 0 : 1
        }
        menu.show(style: .Popover(sourceView: sender, size: CGSize(width: sender.bounds.width, height: 44)), from: self)
    }

    @IBAction func onPremiumGoldAction(_ sender: UIButton) {
        let menu = RSSelectionMenu(selectionType: .Single, dataSource: ["Monthly - $99.95", "Annual - $999"], cellType: .Basic) { (cell, item, indexPath) in
            cell.textLabel?.text = item
            cell.tintColor = .orange
        }
        menu.setSelectedItems(items: [premiumGoldLabel.text!]) { (item, checked, selectedItems) in
            self.premiumGoldLabel.text = item
            self.premiumGoldLabel.tag = item!.starts(with: "Monthly") ? 0 : 1
        }
        menu.show(style: .Popover(sourceView: sender, size: CGSize(width: sender.bounds.width, height: 44)), from: self)
    }

    @IBAction func onBasicSelectAction(_ sender: UIButton) {
        let product = basicLabel.tag == 0 ? Plans.basicMontly.rawValue : Plans.basicAnnual.rawValue
        SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                self.addMembership(planId: self.basicLabel.tag == 0 ? 2 : 1, planName: self.basicLabel.tag == 0 ? "Basic Monthly" : "Basic Annual")

            case .error(let error):
                print("Purchase failed: \(error.localizedDescription)")
            }
        }
    }

    @IBAction func onPremiumSelectAction(_ sender: UIButton) {
        let product = premiumLabel.tag == 0 ? Plans.premiumMontly.rawValue : Plans.premiumAnnual.rawValue
        SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                self.addMembership(planId: self.premiumLabel.tag == 0 ? 4 : 3, planName: self.premiumLabel.tag == 0 ? "Premium Monthly" : "Premium Annual")

            case .error(let error):
                print("Purchase failed: \(error.localizedDescription)")
            }
        }
    }

    @IBAction func onPremiumGoldSelectAction(_ sender: UIButton) {
        let product = premiumGoldLabel.tag == 0 ? Plans.premiumGoldAMontly.rawValue : Plans.premiumGoldAAnnual.rawValue
        SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { result in
            switch result {
            case .success(let purchase):
                print("Purchase Success: \(purchase.productId)")
                self.addMembership(planId: self.premiumGoldLabel.tag == 0 ? 6 : 5, planName: self.premiumGoldLabel.tag == 0 ? "Basic Gold Monthly" : "Basic Gold Annual")

            case .error(let error):
                print("Purchase failed: \(error.localizedDescription)")
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    fileprivate func addMembership(planId: Int, planName: String) {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let start = fmt.string(from: Date())

        let endDate = Calendar.current.date(byAdding: planId % 2 == 0 ? .month : .year, value: 1, to: Date())!
        let end = fmt.string(from: endDate)

        let params: [String: Any] = [
            "UserID": StoreKey.me.value!.id,
            "TransactionID": 0,
            "PlanID": planId,
            "PlanName": planName,
            "StartDate": start,
            "EndDate": end,
            "Status": 1,
        ]
        Helper.with(self).post(url: "/user/add_membership", params: params) { [weak self] res in
            guard let `self` = self else { return }
            self.progress()
        }
    }

    fileprivate func progress() {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        let date = fmt.string(from: Date())

        let params: [String: Any] = [
            "userId": StoreKey.me.value!.id,
            "status": 1,
            "subscription_cancel_date": date,
            "subscription_cancel_reason": " ",
        ]
        Helper.with(self).post(url: "/user/update_status", params: params) { [weak self] res in
            guard let `self` = self else { return }
            StoreKey.me.value?.status = 1
            self.alert(message: "Success! Your payment has been verified. Welcome aboard", positiveTitle: "Close", positiveAction: {
                self.performSegue(withIdentifier: "main", sender: nil)
            })
        }
    }
}
