//
//  ServicePackageCell.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/13.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import UITextView_Placeholder

class ServicePackageCell: UITableViewCell {
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var titleEdit: UITextField!
    @IBOutlet weak var descriptionView: UILabel!
    @IBOutlet weak var descriptionEdit: UITextView!
    @IBOutlet weak var rate: UITextField!
    @IBOutlet weak var durationPicker: Picker!
    @IBOutlet weak var btnDelete: UIButton!

    var units: [Duration] = [.hourly, .daily, .weekly, .monthly, .yearly, .fixed]

    var banner: UIImage? {
        didSet {
            bannerView.subviews.forEach { $0.removeFromSuperview() }
            let imageView = UIImageView(frame: bannerView.bounds)
            imageView.image = banner
            bannerView.addSubview(imageView)
        }
    }
    var servicePackage: ServicePackage? {
        didSet { setup(for: servicePackage) }
    }
    var onDelete: ((_ item: ServicePackage) -> ())?
    var duration: Duration {
        if let index = durationPicker.selectedIndex {
            return units[index]
        } else {
            return .none
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        descriptionEdit.placeholder = "Enter service description"
        durationPicker.setup(units.map { Common(id: $0.id, name: $0.title) })
        durationPicker.title.textAlignment = .center
        durationPicker.title.font = rate.font
    }

    fileprivate func setup(for servicePackage: ServicePackage?) {
        if let service = servicePackage {
            titleEdit.isHidden = true
            descriptionView.isHidden = false
            descriptionEdit.isHidden = true
            btnDelete.superview?.isHidden = false

            titleView.text = service.name
            descriptionView.text = service.description
            rate.text = service.rate.fixed(2)
            rate.isUserInteractionEnabled = false
            durationPicker.placeholder = service.duration.title
            durationPicker.isUserInteractionEnabled = false

        } else {

            titleEdit.isHidden = false
            descriptionView.isHidden = true
            descriptionEdit.isHidden = false
            btnDelete.superview?.isHidden = true

            titleView.text = "Create a new service"
            titleEdit.text = ""
            descriptionEdit.text = ""
            rate.text = ""
            rate.isUserInteractionEnabled = true
            durationPicker.placeholder = Duration.none.title
            durationPicker.isUserInteractionEnabled = true
        }
    }

    @IBAction func onDeleteAction(_ sender: UIButton) {
        onDelete?(servicePackage!)
    }
}
