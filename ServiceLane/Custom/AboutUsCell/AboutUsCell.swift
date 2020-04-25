//
//  AboutUsCell.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/15.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit

typealias AboutUsItem = (firstImage: UIImage?, secondImage: UIImage?, description: String?)

class AboutUsCell: UITableViewCell {
    @IBOutlet weak var firstImage: UIImageView!
    @IBOutlet weak var secondImage: UIImageView!
    @IBOutlet weak var descriptionView: UILabel!

    var item: AboutUsItem! {
        didSet { setup(for: item) }
    }

    fileprivate func setup(for item: AboutUsItem) {
        firstImage.image = item.firstImage
        secondImage.image = item.secondImage
        descriptionView.text = item.description

        firstImage.isHidden = item.firstImage == nil
        secondImage.isHidden = item.secondImage == nil
    }
}
