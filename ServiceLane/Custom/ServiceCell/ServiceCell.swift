//
//  ServiceCell.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/15.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit

class ServiceCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var descriptionView: UILabel!
    @IBOutlet weak var rate: UILabel!

    var service: ServicePackage! {
        didSet { setup(for: service) }
    }

    fileprivate func setup(for service: ServicePackage) {
        title.text = service.name
        descriptionView.text = service.description
        rate.text = "Rate: $\(service.rate.fixed(2))/\(service.duration.rawValue)"
    }
}
