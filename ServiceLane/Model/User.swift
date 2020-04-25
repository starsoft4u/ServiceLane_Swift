//
//  User.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/13.
//  Copyright © 2018 raptor. All rights reserved.
//

import Foundation
import SwiftyJSON

struct User: Codable {
    var id: Int
    var type: Int
    var categoryId: String
    var categoryList: [Common]
    var category: String {
        return categoryList.map { $0.name }.joined(separator: ", ")
    }
    var subCategoryId: Int
    var email: String
    var firstName: String
    var lastName: String
    var status: Int
    var phone: String
    var whatsApp: String
    var facebook: String
    var webSite: String
    var address: String
    var city: String
    var parish: String
    var zip: String
    var photo: String
    var shortBio: String
    var rate: Int
    var reviewCnt: Int
    var portfolioCnt: Int
    var serviceCnt: Int
    var featured: Bool
    var activated: Bool
    var createdOn: String
    var name: String {
        return "\(firstName) \(lastName)"
    }

    var phoneCompact: String {
        return "1" + phone
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "+", with: "")
            .replacingOccurrences(of: "-", with: "")
    }
    var whatsAppCompact: String {
        return "1" + whatsApp
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "+", with: "")
            .replacingOccurrences(of: "-", with: "")
    }

    init(json: JSON) {
        id = json["UserID"].intValue
        type = json["UserType"].intValue
        categoryId = json["CategoryID"].stringValue
        categoryList = json["Category"].arrayValue.map {
            Common(id: $0["ID"].intValue, name: $0["Category"].stringValue)
        }
        subCategoryId = json["SubcategoryID"].intValue
        email = json["Email"].stringValue
        firstName = json["FName"].stringValue
        lastName = json["LName"].stringValue
        status = json["Status"].intValue
        phone = json["Phone"].stringValue
        whatsApp = json["WhatsApp"].stringValue
        facebook = json["Facebook"].stringValue
        webSite = json["Website"].stringValue
        address = json["Address"].stringValue
        city = json["City"].stringValue
        parish = json["Parish"].stringValue
        zip = json["Zip"].stringValue
        let url = json["ProfilePhoto"].stringValue
        if url.isEmpty {
            photo = ""
        } else if url.lowercased().starts(with: "http") {
            photo = url
        } else {
            let encoded = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? url
            photo = "\(Helper.Url.profile)/\(encoded)"
        }
        shortBio = json["ShortBio"].stringValue
        rate = json["rate"].intValue
        reviewCnt = json["reviewCnt"].int ?? json["rvCount"].intValue
        portfolioCnt = json["prCount"].intValue
        serviceCnt = json["pvCount"].intValue
        createdOn = json["CreatedOn"].stringValue
        featured = json["Featured"].intValue == 1
        activated = (json["Status"].int ?? 1) == 1
    }
}
