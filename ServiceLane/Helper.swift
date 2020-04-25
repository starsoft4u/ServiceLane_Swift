//
//  Enums.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/13.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import Networking
import SwiftyJSON
import Toast_Swift

enum AppStoryboard: String {
    case Main, StartUp, Home, Search, Explore, Account, Settings

    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }

    func viewController<T: UIViewController>(viewControllerClass: T.Type) -> T {
        let storyboardIdentifier = (viewControllerClass as UIViewController.Type)
        return instance.instantiateViewController(withIdentifier: "\(storyboardIdentifier)") as! T
    }
}

final class StoreKey {
    struct launchCount: TSUD {
        static var defaultValue: Int = 0
    }
    struct me: TSUD {
        static let defaultValue: User? = nil
    }
}

class Helper {
    struct Url {
        static let base = "https://myservicelane.com"
        static let password = "\(Helper.Url.base)/forgot_password.php"
        static let privacy = "\(Helper.Url.base)/privacy-app.php"
        static let terms = "\(Helper.Url.base)/terms-app.php"
        static let plans = "\(Helper.Url.base)/plans.php?userId=";
        static let profile = "\(Helper.Url.base)/admin/upload/profile"
        static let portfolio = "\(Helper.Url.base)/admin/upload/portfolio"
        static let api = "\(Helper.Url.base)/api/index.php/api"
    }

    fileprivate let net: Networking = Networking(baseURL: Helper.Url.api)
    fileprivate weak var vc: UIViewController?

    fileprivate static var instance: Helper?

    init(vc: UIViewController) {
        self.vc = vc
    }

    open class func with(_ vc: UIViewController) -> Helper {
        if let instance = instance {
            instance.vc = vc
            return instance
        } else {
            return Helper(vc: vc)
        }
    }
}

// Mark: - Utilities
extension Helper {
    open class func date(from: String, to: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"

        guard let date = formatter.date(from: from) else { return "" }

        formatter.dateFormat = to
        return formatter.string(from: date)
    }
}

// Mark: - Networking
extension Helper {
    func handleResponse(url: String, result: JSONResult, completion: ((_ res: JSON) -> Void)?) {
        switch result {
        case .success(let res):
            print("[$] response [\(url)] Success : \(res)")
            let json = JSON(res.dictionaryBody)
            if json["status"].boolValue {
                completion?(JSON(res.dictionaryBody))
            } else {
                vc?.alert(message: json["error"].string ?? "Something went wrong, try again")
            }

        case .failure(let res):
            print("[$] response [\(url)] Failed : \(res.error)")
            vc?.alert(message: "Something went wrong, try again")
        }
    }

    func get(url: String, params: [String: Any]? = nil, indicator: Bool = true, completion: ((_ res: JSON) -> Void)? = nil) {
        if indicator {
            vc?.view.makeToastActivity(.center)
            vc?.view.isUserInteractionEnabled = false
        }

        print("[$] GET: \(url)")
        net.get(url, parameters: params) { result in
            if indicator {
                self.vc?.view.hideToastActivity()
                self.vc?.view.isUserInteractionEnabled = true
            }
            self.handleResponse(url: url, result: result, completion: completion)
        }
    }

    func post(url: String, params: [String: Any]? = nil, indicator: Bool = true, completion: ((_ res: JSON) -> Void)? = nil) {
        if indicator {
            vc?.view.makeToastActivity(.center)
            vc?.view.isUserInteractionEnabled = false
        }

        print("[$] POST: \(url)")
        net.post(url, parameterType: .formURLEncoded, parameters: params) { result in
            if indicator {
                self.vc?.view.hideToastActivity()
                self.vc?.view.isUserInteractionEnabled = true
            }
            self.handleResponse(url: url, result: result, completion: completion)
        }
    }

    func postMultiPart(url: String, params: [String: Any]? = nil, parts: [FormDataPart], indicator: Bool = true, completion: ((_ res: JSON) -> Void)? = nil) {
        if indicator {
            vc?.view.makeToastActivity(.center)
            vc?.view.isUserInteractionEnabled = false
        }

        print("[$] Multipart/Form Data: \(url)")
        net.post(url, parameters: params, parts: parts) { result in
            if indicator {
                self.vc?.view.hideToastActivity()
                self.vc?.view.isUserInteractionEnabled = true
            }
            self.handleResponse(url: url, result: result, completion: completion)
        }
    }
}
