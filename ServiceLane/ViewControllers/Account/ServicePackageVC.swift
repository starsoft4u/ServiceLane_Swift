//
//  ServicePackageVC.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/13.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import SwiftValidators

class ServicePackageVC: CommonTableVC {
    @IBOutlet weak var footerView: UIView!

    var services: [ServicePackage] = []
    var banners: [UIImage] = [#imageLiteral(resourceName: "banner1"), #imageLiteral(resourceName: "banner2"), #imageLiteral(resourceName: "banner3"),]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Tableview
        let nib = UINib(nibName: ServicePackageCell.nibName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: ServicePackageCell.identifier)
        tableView.estimatedRowHeight = 320
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = footerView

        // Load service packages
        loadSerivicePackages()
    }

    fileprivate func loadSerivicePackages() {
        let params: [String: Any] = [
            "userId": StoreKey.me.value!.id,
        ]
        Helper.with(self).post(url: "/user/profile", params: params) { [weak self] res in
            guard let `self` = self else { return }
            self.services = res["data"]["pvList"].arrayValue.map(ServicePackage.init)
            self.tableView.reloadData()
        }
    }

    fileprivate func deleteServicePackage(for service: ServicePackage) {
        let params: [String: Any] = [
            "userId": StoreKey.me.value!.id,
            "serviceId": service.id,
        ]
        Helper.with(self).post(url: "/pvService/removeService", params: params) { [weak self] res in
            guard let `self` = self else { return }
            self.loadSerivicePackages()
        }
    }

    @IBAction func onSaveAction(_ sender: UIButton) {
        // Add new services
        guard let cell = tableView.cellForRow(at: IndexPath(row: services.count, section: 0)) as? ServicePackageCell else {
            fatalError("Unable to fetch the last cell for service package")
        }
        let title = cell.titleEdit.text!
        let desc = cell.descriptionEdit.text!
        let rate = cell.rate.text!
        let duration = cell.duration

        if Validator.isEmpty().apply(title) {
            alert(message: "Please enter the service name")
        } else if Validator.isEmpty().apply(desc) {
            alert(message: "Please enter the service description")
        } else if !Validator.isNumeric().apply(rate) {
            alert(message: "The amount for rate is invalid")
        } else if duration == .none {
            alert(message: "Please select the duration")
        } else {
            let params: [String: Any] = [
                "userId": StoreKey.me.value!.id,
                "srvName": title,
                "srvDesc": desc,
                "rate": rate,
                "per": duration.rawValue,
            ]
            Helper.with(self).post(url: "/pvService/addService", params: params) { [weak self] res in
                guard let `self` = self else { return }
                self.alert(message: "Congratulations, you have added a new service package successfully", positiveAction: {
                    self.loadSerivicePackages()
                })
            }
        }
    }
}

extension ServicePackageVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ServicePackageCell.identifier, for: indexPath) as? ServicePackageCell else {
            fatalError("Unable to dequeue resuable cell with identifier \(ServicePackageCell.identifier)")
        }

        if indexPath.row < services.count {
            cell.banner = banners[indexPath.row % banners.count]
            cell.servicePackage = services[indexPath.row]
            cell.onDelete = { item in
                self.alert(message: "Are you sure you want to delete this service?", positiveTitle: "Delete", positiveAction: {
                    self.deleteServicePackage(for: item)
                }, negativeTitle: "Cancel")
            }
        } else {
            cell.banner = #imageLiteral(resourceName: "banner4")
            cell.servicePackage = nil
        }

        return cell
    }
}
