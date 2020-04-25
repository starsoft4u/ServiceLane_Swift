//
//  CircleImageView.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/19.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit

class CircleImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = CGFloat.minimum(bounds.width, bounds.height) / 2
        clipsToBounds = true
    }
}
