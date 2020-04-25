//
//  AlertVC.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/26.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit

class AlertVC: UIViewController {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var messageView: UILabel!
    @IBOutlet weak var negativeButton: UIButton!
    @IBOutlet weak var positiveButton: UIButton!

    var icon: UIImage?
    var message: String?
    var negativeTitle: String?
    var negativeAction: (() -> Void)?
    var positiveTitle: String? = "OK"
    var positiveAction: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        iconView.image = icon ?? #imageLiteral(resourceName: "ic_notify")
        messageView.text = message
        positiveButton.setTitle(positiveTitle, for: .normal)
        negativeButton.setTitle(negativeTitle, for: .normal)
        negativeButton.isHidden = negativeTitle == nil
    }

    @IBAction func onPositiveAction(_ sender: Any) {
        dismiss(animated: true, completion: positiveAction)
    }

    @IBAction func onNegativeAction(_ sender: Any) {
        dismiss(animated: true, completion: negativeAction)
    }
}
