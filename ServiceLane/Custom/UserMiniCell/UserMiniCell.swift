//
//  OfferCell.swift
//  Yeahh
//
//  Created by raptor on 05/02/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import Cosmos

class UserMiniCell: UICollectionViewCell {
    @IBOutlet weak var rootView: UIView!
    @IBOutlet weak var avatar: CircleImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var parish: UILabel!
    @IBOutlet weak var category: UILabel!

    var user: User! { didSet { setup(for: user) } }

    override func awakeFromNib() {
        super.awakeFromNib()

        rootView.layer.borderColor = UIColor(patternImage: #imageLiteral(resourceName: "dot_small")).cgColor
    }

    func setup(for user: User) {
        avatar.sd_setImage(with: URL(string: user.photo), placeholderImage: #imageLiteral(resourceName: "avatar"))
        name.text = user.name
        rating.rating = Double(user.rate)
        parish.text = user.parish
        category.text = user.category
    }
}
