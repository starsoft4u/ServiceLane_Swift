//
//  ReviewVC.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/15.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import Cosmos
import XLPagerTabStrip
import UIEmptyState

class ReviewVC: CommonTableVC {
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var since: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var imgCheck: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var rating: CosmosView!

    var user: User!
    var reviews: [Review] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Load view
        since.text = "Member since (\(Helper.date(from: user.createdOn, to: "yyyy")))"
        avatar.sd_setImage(with: URL(string: user.photo), placeholderImage: #imageLiteral(resourceName: "avatar"))
        imgCheck.isHidden = !user.featured
        username.text = user.name
        rating.rating = Double(user.rate)

        // Configure tableview
        tableView.tableHeaderView = header
        emptyStateDataSource = self
        reloadEmptyStateForTableView(tableView)
    }
}

extension ReviewVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath)

        let review = reviews[indexPath.row]

        if let label = cell.viewWithTag(1) as? UILabel {
            let attr1: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.foregroundColor: UIColor.darkGray,
                NSAttributedString.Key.font: UIFont(name: "Karla-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)
            ]
            let attrStr1 = NSMutableAttributedString(string: "\"\(review.message)\" – ", attributes: attr1)

            let attr2: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.font: UIFont(name: "Karla-Bold", size: 15) ?? UIFont.boldSystemFont(ofSize: 15)
            ]
            let attrStr2 = NSMutableAttributedString(string: "\(review.firstName) \(review.lastName), \(Helper.date(from: review.createdOn, to: "M/d/yy"))", attributes: attr2)

            let attrStr = NSMutableAttributedString()
            attrStr.append(attrStr1)
            attrStr.append(attrStr2)
            label.attributedText = attrStr
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ReviewVC: UIEmptyStateDataSource {
    var emptyStateTitle: NSAttributedString {
        return NSAttributedString(
            string: "No reviews yet",
            attributes: [
                    .foregroundColor: UIColor.darkGrey,
                    .font: UIFont(name: "Karla-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15),
            ])
    }
}

extension ReviewVC: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return "Reviews"
    }
}

