//
//  IdentifyVC.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/15.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import Cosmos
import XLPagerTabStrip
import SDWebImage
import UIEmptyState

class IdentityVC: CommonVC {
    @IBOutlet weak var since: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var imgCheck: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var parish: UILabel!
    @IBOutlet weak var photoCntView: UILabel!
    @IBOutlet weak var serviceCntView: UILabel!
    @IBOutlet weak var reviewCntView: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var shortBio: UILabel!
    @IBOutlet weak var service: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!

    var user: User!
    var services: [ServicePackage] = []
    var contactInfo: [(icon: UIImage, title: String, url: String)] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Load view
        since.text = "Member since (\(Helper.date(from: user.createdOn, to: "yyyy")))"
        avatar.sd_setImage(with: URL(string: user.photo), placeholderImage: #imageLiteral(resourceName: "avatar.png"))
        imgCheck.isHidden = !user.featured
        username.text = user.name
        rating.rating = Double(user.rate)
        category.text = user.category
        parish.text = user.parish
        photoCntView.text = "Photos (\(user.portfolioCnt))"
        serviceCntView.text = "Services (\(user.serviceCnt))"
        reviewCntView.text = "Reviews (\(user.reviewCnt))"

        // Contact info
        if !user.phoneCompact.isEmpty, canOpen("tel://\(user.phoneCompact)") {
            contactInfo.append((icon: #imageLiteral(resourceName: "ic_phone.png"), title: user.phone, url: "tel://\(user.phoneCompact)"))
        }
        if !user.whatsAppCompact.isEmpty, canOpen("https://api.whatsapp.com/send?phone=\(user.whatsAppCompact)") {
            contactInfo.append((icon: #imageLiteral(resourceName: "ic_whatsapp.png"), title: user.phone, url: "https://api.whatsapp.com/send?phone=\(user.whatsAppCompact)"))
        }
        if !user.email.isEmpty, canOpen("mailto:\(user.email)") {
            contactInfo.append((icon: #imageLiteral(resourceName: "ic_mail.png"), title: "Send me an email", url: "mailto:\(user.email)"))
        }
        if !user.facebook.isEmpty, canOpen(user.facebook) {
            contactInfo.append((icon: #imageLiteral(resourceName: "ic_facebook.png"), title: "My facebook page", url: user.facebook))
        }
        if !user.webSite.isEmpty, canOpen(user.webSite) {
            contactInfo.append((icon: #imageLiteral(resourceName: "ic_website.png"), title: "Visit my website", url: user.webSite))
        }

        collectionView.register(UINib(nibName: ContactItemCell.nibName, bundle: nil), forCellWithReuseIdentifier: ContactItemCell.identifier)

        // Short bio
        if user.shortBio.isEmpty {
            shortBio.text = "Bio information not provided"
            shortBio.textAlignment = .center
            shortBio.textColor = .darkGrey
        } else {
            shortBio.text = user.shortBio
            shortBio.textColor = .black
        }

        // Services count
        service.text = "SERVICE PACKAGES (\(services.count))"

        // Configure services tableview
        tableView.register(UINib(nibName: ServiceCell.nibName, bundle: nil), forCellReuseIdentifier: ServiceCell.identifier)

        tableViewHeight.constant = 10000
        collectionViewHeight.constant = 300
        view.layoutIfNeeded()

        tableViewHeight.constant = services.isEmpty ? 48 : tableView.contentSize.height
        collectionViewHeight.constant = collectionView.contentSize.height
        view.layoutIfNeeded()


        // Empty state for service list
        emptyStateDataSource = self
        reloadEmptyStateForTableView(tableView)
    }

    fileprivate func canOpen(_ urlString: String) -> Bool {
        if let url = URL(string: urlString) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }

    fileprivate func open(_ urlString: String) {
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

extension IdentityVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contactInfo.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContactItemCell.identifier, for: indexPath) as? ContactItemCell else {
            fatalError("Unable to dequeue reusable cell with identifier \(ContactItemCell.identifier)")
        }

        cell.item = contactInfo[indexPath.item]

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w: CGFloat = (collectionView.bounds.width - 16 * 2) / 2
        return CGSize(width: w, height: 36)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        open(contactInfo[indexPath.item].url)
    }
}

extension IdentityVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ServiceCell.identifier, for: indexPath) as? ServiceCell else {
            fatalError("Unable to dequeue resuable cell with identifier \(ServiceCell.identifier)")
        }

        cell.service = services[indexPath.row]

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension IdentityVC: UIEmptyStateDataSource {
    var emptyStateTitle: NSAttributedString {
        return NSAttributedString(
            string: "Service information not provided",
            attributes: [
                    .foregroundColor: UIColor.darkGrey,
                    .font: UIFont(name: "Karla-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15),
            ])
    }
}

extension IdentityVC: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return "Identity"
    }
}
