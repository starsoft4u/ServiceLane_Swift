//
//  SupportVC.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/15.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import UITextView_Placeholder
import SwiftValidators

class SupportVC: CommonVC {
    @IBOutlet weak var messageBox: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        messageBox.placeholder = "Send a message to Service Lane support"
    }
    
    @IBAction func onSendAction(_ sender: Any) {
        if StoreKey.me.value == nil {
            alert(message: "Please login to be able to send message")
        } else if Validator.isEmpty().apply(messageBox.text) {
            alert(message: "Please enter the message")
        } else {
            let params: [String: Any] = [
                "userId": StoreKey.me.value!.id,
                "content": messageBox.text!,
            ]
            Helper.with(self).post(url: "/user/sendEmail", params: params) { [weak self] res in
                guard let `self` = self else { return }
                self.messageBox.text = ""
                self.dismissKeyboard()
                self.alert(message: "Message sent successfully")
            }
        }
    }
}
