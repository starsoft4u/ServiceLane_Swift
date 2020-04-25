//
//  ProviderCell.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/15.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import Cosmos

class UserCell: UITableViewCell {
    @IBOutlet weak var avatar: CircleImageView!
    @IBOutlet weak var featured: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var descriptionView: UILabel!
    @IBOutlet weak var parish: UILabel!
    @IBOutlet weak var photosCnt: UILabel!
    @IBOutlet weak var servicesCnt: UILabel!

    var user: User! {
        didSet { setup(for: user) }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    fileprivate func setup(for user: User) {
        avatar.sd_setImage(with: URL(string: user.photo), placeholderImage: #imageLiteral(resourceName: "avatar"))
        featured.isHidden = !user.featured
        username.text = user.name
        rating.rating = Double(user.rate)
        rating.text = "\(user.reviewCnt) reviews"
        descriptionView.text = user.category
        parish.text = user.parish
        photosCnt.text = "Photos (\(user.portfolioCnt))"
        servicesCnt.text = "Services (\(user.serviceCnt))"
    }
}
