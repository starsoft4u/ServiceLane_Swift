//
//  TutorialCellVC.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/12.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit

class TutorialCellVC: CommonVC {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var descriptionView: UILabel!

    var cell: TutorialCell!

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = cell.image
        titleView.text = cell.title
        descriptionView.text = cell.description
    }
}
