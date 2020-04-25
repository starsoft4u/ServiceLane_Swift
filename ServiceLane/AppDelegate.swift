//
//  AppDelegate.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/12.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import Toast_Swift
import IQKeyboardManagerSwift
import FacebookCore
import SwiftyStoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Keyboard manager
        IQKeyboardManager.shared.enable = true

        // Toast
        var style = ToastStyle()
        style.activityBackgroundColor = UIColor(white: 0, alpha: 0.5)
        ToastManager.shared.style = style

        // Facebook
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

        // IAP
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                }
            }
        }
        SwiftyStoreKit.shouldAddStorePaymentHandler = { payment, product in
            return true
        }

        // Already logged in?
        if StoreKey.launchCount.value > 0 {
            let nav = AppStoryboard.Main.instance.instantiateInitialViewController() as? UINavigationController

            let signUp = AppStoryboard.Main.viewController(viewControllerClass: SignUpVC.self)

            if let user = StoreKey.me.value {
                if user.status == 0 {
                    let startup = AppStoryboard.StartUp.viewController(viewControllerClass: StartUpProfileVC.self)
                    nav?.viewControllers = [signUp, startup]
                } else {
                    let tab = AppStoryboard.Main.viewController(viewControllerClass: MainVC.self)
                    nav?.viewControllers = [signUp, tab]
                }
            } else {
                nav?.viewControllers = [signUp]
            }
            self.window?.rootViewController = nav
            self.window?.makeKeyAndVisible()
        }

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return SDKApplicationDelegate.shared.application(app, open: url, options: options)
    }

    private func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {

        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let url = userActivity.webpageURL,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            let arg = components.queryItems?.first,
            let encoded = arg.value,
            let data = Data(base64Encoded: encoded) else {
                return false
        }

        let email = String(data: data, encoding: .utf8)

        let nav = AppStoryboard.Main.instance.instantiateInitialViewController() as? UINavigationController
        let signUp = AppStoryboard.Main.viewController(viewControllerClass: SignUpVC.self)
        let profile = AppStoryboard.StartUp.viewController(viewControllerClass: StartUpProfileVC.self)
        profile.userEmail = email

        nav?.viewControllers = [signUp, profile]

        self.window?.rootViewController = nav
        self.window?.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

