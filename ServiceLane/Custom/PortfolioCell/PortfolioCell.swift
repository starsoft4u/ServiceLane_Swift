//
//  PortfolioCell.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/14.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import SDWebImage

class PortfolioCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var updated: UILabel!
    @IBOutlet weak var delete: UIButton!

    var portfolio: Portfolio! {
        didSet { setup(for: portfolio) }
    }
    var imageOnly: Bool! {
        didSet {
            updated.isHidden = imageOnly
            delete.isHidden = imageOnly
        }
    }
    var onDelete: ((_ portfolio: Portfolio) -> Void)?
    var onTapImage: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        let gesture = UITapGestureRecognizer(target: self, action: #selector(PortfolioCell.onTapImageAction(_:)))
        image.addGestureRecognizer(gesture)
    }

    fileprivate func setup(for portfolio: Portfolio) {
        image.sd_setImage(with: URL(string: portfolio.image), placeholderImage: #imageLiteral(resourceName: "ic_empty"))
        updated.text = "Uploaded: \(Helper.date(from: portfolio.uploadedAt, to: "M/d/yy"))"
    }

    @IBAction func onDeleteAction(_ sender: Any) {
        onDelete?(portfolio)
    }

    @objc func onTapImageAction(_ sender: UITapGestureRecognizer) {
        onTapImage?()
    }
}
