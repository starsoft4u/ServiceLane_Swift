//
//  SettingsVC.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/15.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit

class SettingsVC: CommonTableVC {
    @IBOutlet weak var status: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        status.isOn = StoreKey.me.value?.activated ?? true

        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    @IBAction func onActivateAction(_ sender: UISwitch) {
        let params: [String: Any] = [
            "userId": StoreKey.me.value!.id,
            "status": status.isOn ? 1 : 0,
        ]
        Helper.with(self).post(url: "/user/activate", params: params, indicator: false) { res in
            StoreKey.me.value = User(json: res["data"])
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PrivacyPolicyVC {
            vc.isPrivacy = segue.identifier == "privacy"
        }
    }
}

extension SettingsVC {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if StoreKey.me.value == nil, indexPath.row < 2 {
            return 0
        }

        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)

        // Sign out
        if indexPath.row == 6 {
            StoreKey.me.value = nil
            tabBarController?.navigationController?.popToRootViewController(animated: true)
        }
    }
}
