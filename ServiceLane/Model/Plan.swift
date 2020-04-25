//
//  Plan.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/27.
//  Copyright © 2018 raptor. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Plan {
    var id: Int
    var product: String
    var price: Double
    var startOn: String
    var expireOn: String
    var title: String {
        var unit = ""
        if product.lowercased().contains("day") {
            unit = "/day"
        } else if product.lowercased().contains("week") {
            unit = "/wk"
        } else if product.lowercased().contains("month") {
            unit = "/mo"
        } else if product.lowercased().contains("year") {
            unit = "/yr"
        }
        return "\(product) ($\(price.fixed(2))\(unit))"
    }

    init(json: JSON) {
        id = json["ID"].intValue
        product = json["Product"].stringValue
        price = json["Price"].doubleValue
        startOn = json["StartDate"].stringValue
        expireOn = json["EndDate"].stringValue
    }
}
