//
//  PasswordVC.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/15.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import SwiftValidators

class PasswordVC: CommonTableVC {
    @IBOutlet weak var oldPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var footerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = footerView
    }

    @IBAction func onSaveAction(_ sender: UIButton) {
        if Validator.isEmpty().apply(newPassword.text) {
            alert(message: "Please enter the new password")
        } else if newPassword.text != confirmPassword.text {
            alert(message: "The 2 passwords do not match")
        } else {
            let params: [String: Any] = [
                "userEmail": StoreKey.me.value!.email,
                "curPwd": oldPassword.text!,
                "newPwd": newPassword.text!,
            ]
            Helper.with(self).post(url: "/user/updatePwd", params: params) { [weak self] res in
                guard let `self` = self else { return }
                self.oldPassword.text = ""
                self.newPassword.text = ""
                self.confirmPassword.text = ""
                self.alert(message: "Great! Your password has been updated successfully")
            }
        }
    }
}

extension PasswordVC {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0...2:
            return 56
        case 3:
            return 16
        default:
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
}
