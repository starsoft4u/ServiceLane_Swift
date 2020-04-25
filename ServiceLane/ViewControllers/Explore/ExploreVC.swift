//
//  ExploreVC.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/15.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import UIEmptyState

class ExploreVC: CommonVC {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var parishName: UILabel!
    @IBOutlet weak var btnViewAll: UIButton!
    @IBOutlet var parishes: [UIButton]!

    var users: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Parishes
        parishes.forEach {
            $0.titleLabel?.adjustsFontSizeToFitWidth = true
            $0.titleLabel?.numberOfLines = 0
            $0.titleLabel?.textAlignment = .center
        }

        // Providers
        let nib = UINib(nibName: UserMiniCell.nibName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: UserMiniCell.identifier)
        emptyStateDataSource = self

        // Load
        loadData()
    }

    fileprivate func loadData(parish: String = "") {
        let params: [String: Any] = [
            "parish": parish
        ]

        parishName.text = parish
        btnViewAll.isHidden = parish.isEmpty
        Helper.with(self).post(url: "/user/explore", params: params) { [weak self] json in
            guard let `self` = self else { return }

            self.users = json["data"]["pvList"].arrayValue.map(User.init)
            self.collectionView.reloadData()
            self.reloadEmptyStateForCollectionView(self.collectionView)
        }
    }

    @IBAction func onParashTapped(_ sender: UIButton) {
        loadData(parish: sender.title(for: .normal)!)
    }

    @IBAction func onViewAll(_ sender: Any) {
        loadData()
    }
}

extension ExploreVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserMiniCell.identifier, for: indexPath) as? UserMiniCell else {
            fatalError("Unable to dequeue resuable cell with identifier \(UserMiniCell.identifier)")
        }

        cell.user = users[indexPath.item]

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 16) / 2, height: 88)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        let vc = AppStoryboard.Main.viewController(viewControllerClass: UserVC.self)
        vc.user = users[indexPath.item]
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ExploreVC: UIEmptyStateDataSource {
    var emptyStateTitle: NSAttributedString {
        return NSAttributedString(
            string: "Sorry, we couldn't find any matches",
            attributes: [
                    .foregroundColor: UIColor.darkGrey,
                    .font: UIFont(name: "Karla-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15),
            ])
    }
}
