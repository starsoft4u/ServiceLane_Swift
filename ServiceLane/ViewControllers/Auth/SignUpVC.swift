//
//  SignUpVC.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/13.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import SwiftValidators
import ActiveLabel
import FacebookCore
import FacebookLogin
import SwiftyJSON

class SignUpVC: CommonVC {
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
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

    @IBAction func OnSignUpAction(_ sender: Any) {
        if Validator.isEmpty().apply(firstName.text) {
            alert(message: "Please enter the first name")
        } else if Validator.isEmpty().apply(lastName.text) {
            alert(message: "Please enter the last name")
        } else if !Validator.isEmail().apply(email.text) {
            alert(message: "The email address is invalid")
        } else if Validator.isEmpty().apply(password.text) {
            alert(message: "Please enter your password")
        } else {
            let params: [String: Any] = [
                "firstName": firstName.text!,
                "lastName": lastName.text!,
                "email": email.text!,
                "password": password.text!,
            ]
            Helper.with(self).post(url: "/user/signup", params: params) { [weak self] res in
                guard let `self` = self else { return }
                StoreKey.me.value = User(json: res["data"])
                self.alert(message: "To proceed please click the link in the email we just sent to you")
            }
        }
    }

    fileprivate func signUpFacebook(email: String, firstName: String, lastName: String, avatar: String = "") {
        let params: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "avatar": avatar,
        ]
        Helper.with(self).post(url: "/user/socialSignUp", params: params) { [weak self] res in
            guard let `self` = self else { return }
            StoreKey.me.value = User(json: res["data"])
            self.performSegue(withIdentifier: "startup", sender: nil)
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
            parameters: ["fields": "id,first_name,last_name,email,picture.type(large)"],
            accessToken: token,
            httpMethod: .GET)) { httpResponse, result in
            switch result {
            case .success(let response):
                print("Graph Request Succeeded: \(response)")
                let json = JSON(response.dictionaryValue!)
                self.signUpFacebook(email: json["email"].stringValue, firstName: json["first_name"].stringValue, lastName: json["last_name"].stringValue, avatar:
                        json["picture"]["data"]["url"].stringValue)

            case .failed(let error):
                print("Graph Request Failed (/me) : \(error)")
            }
        }
        connection.start()
    }

    @IBAction func unwind2Signup(_ sender: UIStoryboardSegue) {
        firstName.text = ""
        lastName.text = ""
        email.text = ""
        password.text = ""
    }
}
