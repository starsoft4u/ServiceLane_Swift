//
//  Review.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/28.
//  Copyright © 2018 raptor. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Review {
    var id: Int
    var firstName: String
    var lastName: String
    var message: String
    var createdOn: String

    init(json: JSON) {
        id = json["ID"].intValue
        firstName = json["ReviewerFName"].stringValue
        lastName = json["ReviewerLName"].stringValue
        message = json["ReviewText"].stringValue
        createdOn = json["CreatedOn"].stringValue
    }
}
