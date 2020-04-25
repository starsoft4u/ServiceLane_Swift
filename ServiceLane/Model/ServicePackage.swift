//
//  ServicePackage.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/13.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import SwiftyJSON

enum Duration: String {
    case none
    case hourly = "hr"
    case daily = "day"
    case weekly = "wk"
    case monthly = "mo"
    case yearly = "yr"
    case fixed = "fixed"

    var id: Int {
        switch self {
        case .none: return 0
        case .hourly: return 1
        case .daily: return 2
        case .weekly: return 3
        case .monthly: return 4
        case .yearly: return 5
        case .fixed: return 6
        }
    }

    var title: String {
        switch self {
        case .none: return "Duration"
        case .hourly: return "Hour"
        case .daily: return "Day"
        case .weekly: return "Week"
        case .monthly: return "Month"
        case .yearly: return "Year"
        case .fixed: return "Fixed rate"
        }
    }
}

struct ServicePackage {
    var id: Int
    var name: String
    var description: String
    var rate: Double
    var duration: Duration

    init(json: JSON) {
        self.id = json["ID"].intValue
        self.name = json["ServiceName"].stringValue
        self.description = json["ServiceDescription"].stringValue
        self.rate = json["Rate"].doubleValue
        self.duration = Duration(rawValue: json["Per"].stringValue) ?? .none
    }
}
