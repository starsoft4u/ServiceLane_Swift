//
//  PortfolioVC.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/16.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import Cosmos
import XLPagerTabStrip
import Lightbox
import UIEmptyState

class PortfolioHeader: UICollectionReusableView {
    @IBOutlet weak var since: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var imgCheck: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var rating: CosmosView!
}

class PortfolioVC: CommonVC {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout!

    var user: User!
    var portfolios: [Portfolio] = []
    var images: [LightboxImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Load view
        images = portfolios.map { item in
            return item.image.isEmpty ? LightboxImage(image: #imageLiteral(resourceName: "ic_empty")) : LightboxImage(imageURL: URL(string: item.image)!)
        }

        // Configure collection view
        let nib = UINib(nibName: PortfolioCell.nibName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: PortfolioCell.identifier)
        emptyStateDataSource = self
        reloadEmptyStateForCollectionView(collectionView)
    }
}

extension PortfolioVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return portfolios.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PortfolioCell.identifier, for: indexPath) as? PortfolioCell else {
            fatalError("Unable to dequeue resuable cell with identifier \(PortfolioCell.identifier)")
        }

        cell.portfolio = portfolios[indexPath.item]
        cell.imageOnly = true
        cell.onTapImage = {
            let controller = LightboxController(images: self.images, startIndex: indexPath.item)
            self.present(controller, animated: true, completion: nil)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            fatalError("Unexpected collection reusable view \(kind)")
        }

        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? PortfolioHeader else {
            fatalError("Unable to dequeue resuable supplementary view as header")
        }

        header.since.text = "Member since (\(Helper.date(from: user.createdOn, to: "yyyy")))"
        header.avatar.sd_setImage(with: URL(string: user.photo), placeholderImage: #imageLiteral(resourceName: "avatar"))
        header.imgCheck.isHidden = !user.featured
        header.username.text = user.name
        header.rating.rating = Double(user.rate)

        return header
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w: CGFloat = (collectionView.bounds.width - 16 * 3) / 2
        return CGSize(width: w, height: w)
    }
}

extension PortfolioVC: UIEmptyStateDataSource {
    var emptyStateTitle: NSAttributedString {
        return NSAttributedString(
            string: "Portfolio not available",
            attributes: [
                    .foregroundColor: UIColor.darkGrey,
                    .font: UIFont(name: "Karla-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15),
            ])
    }
}

extension PortfolioVC: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return "Portfolio"
    }
}
