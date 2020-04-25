//
//  AccountVC.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/13.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit

class AccountVC: CommonTableVC {

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)

        // Sign out
        if indexPath.row == 5 {
            StoreKey.me.value = nil
            tabBarController?.navigationController?.popToRootViewController(animated: true)
        }
    }
}
