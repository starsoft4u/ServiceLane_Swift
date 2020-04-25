//
//  HomeVC.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/13.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import Cosmos
import SDWebImage
import SwiftyJSON

class HomeVC: CommonTableVC {
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var providerCnt: UILabel!
    @IBOutlet var catButton: [UIButton]!
    @IBOutlet weak var catPanel: UIStackView!
    @IBOutlet weak var categoryPicker: Picker!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionVIewHeight: NSLayoutConstraint!

    var users: [User] = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // User info
        if let user = StoreKey.me.value {
            username.text = user.name
            rating.rating = Double(user.rate)
            avatar.sd_setImage(with: URL(string: user.photo), placeholderImage: #imageLiteral(resourceName: "avatar"))
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Provider count
        providerCnt.isHidden = true

        // Tableview
        tableView.separatorColor = UIColor(patternImage: #imageLiteral(resourceName: "dot_large"))

        // Category picker
        categoryPicker.didSelect = { item in
            self.loadHomeData(categoryId: item.id)
        }

        // Featured provider
        let nib = UINib(nibName: UserMiniCell.nibName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: UserMiniCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self

        // Categories and providers
        loadHomeData()
    }

    fileprivate func loadHomeData(categoryId: Int = 0) {
        let params: [String: Any] = [
            "catId": categoryId,
        ]
        Helper.with(self).post(url: "/user/home", params: params) { [weak self] json in
            guard let `self` = self else { return }

            let cnt = json["data"]["pvCount"].intValue
            self.providerCnt.text = "Pick one from \(cnt.formatted) providers"
            self.providerCnt.isHidden = cnt < 200
            self.setupProviders(users: json["data"]["pvList"].arrayValue.map(User.init))
            self.categoryPicker.setup(json["data"]["catList"].arrayValue.map { Common(id: $0["ID"].intValue, name: $0["Category"].stringValue) })
            if categoryId == 0 {
                self.categoryPicker.placeholder = "Select category"
            } else {
                self.categoryPicker.selectedId = categoryId
            }
            self.setupCategoryButtons(categories: json["data"]["topCatList"].arrayValue)

            self.tableView.reloadData()
        }
    }

    fileprivate func setupProviders(users: [User]) {
        self.users = users
        collectionView.reloadData()

        collectionVIewHeight.constant = collectionViewLayout.collectionViewContentSize.height
        view.layoutIfNeeded()
    }

    fileprivate func setupCategoryButtons(categories: [JSON]) {
        catPanel.isHidden = categories.isEmpty

        self.catButton.enumerated().forEach { index, button in
            button.multiline(index == 0 ? 5 : 2)
            if let id = Int(categories[index]["ID"].stringValue), let name = categories[index]["Category"].string {
                button.tag = id
                button.setTitle(name, for: .normal)
                button.isHidden = false
            } else {
                button.isHidden = true
            }
        }
    }

    @IBAction func onCatButtonAction(_ sender: UIButton) {
        loadHomeData(categoryId: sender.tag)
    }

    @IBAction func onViewAllAction(_ sender: UIButton) {
        loadHomeData()
    }
}

extension HomeVC {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if StoreKey.me.value == nil, indexPath.row == 0 {
            return UITableViewCell(frame: CGRect.zero)
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return StoreKey.me.value == nil ? 0 : 80
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
}

extension HomeVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
        return CGSize(width: (UIScreen.main.bounds.width - 16 * 3) / 2, height: 88)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        let vc = AppStoryboard.Main.viewController(viewControllerClass: UserVC.self)
        vc.user = users[indexPath.item]
        navigationController?.pushViewController(vc, animated: true)
    }

}
