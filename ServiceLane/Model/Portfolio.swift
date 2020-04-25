//
//  Portfolio.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/14.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import SwiftyJSON

struct Portfolio {
    var id: Int
    var image: String
    var uploadedAt: String

    init(json: JSON) {
        id = json["ID"].intValue
        if let url = json["Filename"].string {
            let encoded = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? url
            image = "\(Helper.Url.portfolio)/\(encoded)"
        } else {
            image = ""
        }
        uploadedAt = json["CreatedOn"].stringValue
    }
}
