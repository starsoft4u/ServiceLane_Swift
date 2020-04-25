//
//  LoginVC.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/12.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import SwiftValidators
import ActiveLabel
import FacebookCore
import FacebookLogin
import SwiftyJSON

class LoginVC: CommonVC {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var termsAndConditions: ActiveLabel!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated, navigationBar: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // terms and conditions
        setupTermsAndConditions(label: termsAndConditions)
    }

    @IBAction func onLoginAction(_ sender: Any) {
        if !Validator.isEmail().apply(email.text) {
            alert(message: "The email address is invalid")
        } else if Validator.isEmpty().apply(password.text) {
            alert(message: "Please enter your password")
        } else {
            let params: [String: Any] = [
                "email": email.text!,
                "password": password.text!,
            ]
            Helper.with(self).post(url: "/user/login", params: params) { [weak self] res in
                guard let `self` = self else { return }
                let user = User(json: res["data"])
                StoreKey.me.value = user
                if user.status == 0 {
                    self.performSegue(withIdentifier: "startup", sender: nil)
                } else {
                    self.performSegue(withIdentifier: "main", sender: nil)
                }
            }
        }
    }

    fileprivate func loginFacebook(email: String) {
        let params: [String: Any] = [
            "email": email,
        ]
        Helper.with(self).post(url: "/user/socialLogin", params: params) { [weak self] res in
            guard let `self` = self else { return }
            let user = User(json: res["data"])
            StoreKey.me.value = user
            if user.status == 0 {
                self.performSegue(withIdentifier: "startup", sender: nil)
            } else {
                self.performSegue(withIdentifier: "main", sender: nil)
            }
        }
    }

    @IBAction func onFacebookAction(_ sender: Any) {
        if let token = AccessToken.current {
            print("[$] Facebook logged in! : \(token)")
            requestFacebookProfile(token)
        } else {
            LoginManager().logIn(readPermissions: [.publicProfile, .email], viewController: self) { loginResult in
                switch loginResult {
                case .failed(let error):
                    print("[$] Facebook login failed >>> \(error)")
                    self.alert(message: "Something went wrong. Please try again.")

                case .cancelled:
                    print("[$] Facebook login cancelled")

                case .success(_, _, let token):
                    print("[$] Facebook logged in! : \(token)")
                    self.requestFacebookProfile(token)
                }
            }
        }
    }

    fileprivate func requestFacebookProfile(_ token: AccessToken) {
        let connection = GraphRequestConnection()
        connection.add(GraphRequest(
            graphPath: "me",
            parameters: ["fields": "email"],
            accessToken: token,
            httpMethod: .GET)) { httpResponse, result in
            switch result {
            case .success(let response):
                print("Graph Request Succeeded: \(response)")
                self.loginFacebook(email: JSON(response.dictionaryValue!)["email"].stringValue)

            case .failed(let error):
                print("Graph Request Failed (/me) : \(error)")
            }
        }
        connection.start()
    }

    @IBAction func onForgotPassword(_ sender: Any) {
        if let url = URL(string: Helper.Url.password), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }

    @IBAction func unwind2Login(_ sender: UIStoryboardSegue) {
        password.text = ""
    }
}
