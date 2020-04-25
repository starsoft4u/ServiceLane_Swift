//
//  ContactItemCell.swift
//  ServiceLane
//
//  Created by raptor on 2018/7/17.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit

class ContactItemCell: UICollectionViewCell {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var name: UILabel!

    var item: (icon: UIImage, title: String, url: String)! {
        didSet {
            iconView.image = item.icon
            name.text = item.title
        }
    }
}
