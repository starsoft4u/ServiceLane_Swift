//
//  SearchVC.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/15.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import SwiftValidators
import UIEmptyState

class SearchVC: CommonVC {
    @IBOutlet weak var category: Picker!
    @IBOutlet weak var parish: Picker!
    @IBOutlet weak var rating: Picker!
    @IBOutlet weak var reviews: Picker!
    @IBOutlet weak var from: UITextField!
    @IBOutlet weak var to: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var extendViews: [UIView]!

    var expanded: Bool = false
    var users: [User] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Table view
        let nib = UINib(nibName: UserCell.nibName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: UserCell.identifier)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 1))
        emptyStateDataSource = self

        // Initial load
        setupFilters()
    }

    fileprivate func setupFilters() {
        Helper.with(self).get(url: "/user/search") { [weak self] json in
            guard let `self` = self else { return }

            self.category.setup(json["data"]["catList"].arrayValue.map { Common(id: $0["ID"].intValue, name: $0["Category"].stringValue) })
            self.category.placeholder = "Select category"
            self.category.didSelect = { _ in self.search() }

            self.parish.setup(json["data"]["parishList"].arrayValue.map { Common(id: 0, name: $0.stringValue) })
            self.parish.placeholder = "Select parish"
            self.parish.didSelect = { _ in self.search() }

            self.rating.setup([1, 2, 3, 4, 5].map { Common(id: $0, name: "\($0) & above") })
            self.rating.placeholder = "Star rating"
            self.rating.didSelect = { _ in self.search() }

            self.reviews.setup([
                Common(id: 1, name: "0 - 10"),
                Common(id: 2, name: "10 - 25"),
                Common(id: 3, name: "25 - 50"),
                Common(id: 4, name: "50 - 100"),
                Common(id: 5, name: "100 - 200"),
                Common(id: 6, name: "200 - 500"),
                Common(id: 7, name: "500+"),
                ])
            self.reviews.placeholder = "Number of reviews"
            self.reviews.didSelect = { _ in self.search() }

            self.from.text = ""
            self.to.text = ""

            self.users = json["data"]["pvList"].arrayValue.map(User.init)
            self.tableView.reloadData()
            self.reloadEmptyStateForTableView(self.tableView)

            self.expand(show: false)
        }
    }

    fileprivate func search() {
        let params: [String: Any] = [
            "catId": category.selectedId,
            "parish": parish.selectedName,
            "rate": rating.selectedId,
            "reviewCnt": reviews.selectedId,
            "from": from.text ?? "",
            "to": to.text ?? "",
        ]
        Helper.with(self).post(url: "/user/search", params: params) { [weak self] json in
            guard let `self` = self else { return }
            self.users = json["data"].arrayValue.map(User.init)
            self.tableView.reloadData()
            self.reloadEmptyStateForTableView(self.tableView)
            self.expand(show: false)
        }
    }

    @IBAction func onToggleExpandAction(_ sender: UIBarButtonItem) {
        expand(show: !expanded)
    }

    fileprivate func expand(show: Bool) {
        expanded = show
        extendViews.forEach { $0.isHidden = !show }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func onFromUpAction(_ sender: UIButton) {
        guard Validator.isNumeric().apply(from.text) else {
            from.text = "0"
            return
        }
        let val = (from.text! as NSString).doubleValue + 1
        from.text = val.fixed(2)
    }

    @IBAction func onFromDownAction(_ sender: UIButton) {
        guard Validator.isNumeric().apply(from.text) else {
            from.text = "0"
            return
        }
        let val = (from.text! as NSString).doubleValue - 1
        from.text = Double.maximum(0, val).fixed(2)
    }

    @IBAction func onToUpAction(_ sender: UIButton) {
        guard Validator.isNumeric().apply(to.text) else {
            to.text = "0"
            return
        }
        let val = (to.text! as NSString).doubleValue + 1
        to.text = val.fixed(2)
    }

    @IBAction func onToDownAction(_ sender: UIButton) {
        guard Validator.isNumeric().apply(to.text) else {
            to.text = "0"
            return
        }
        let val = (to.text! as NSString).doubleValue - 1
        to.text = Double.maximum(0, val).fixed(2)
    }

    @IBAction func onUpdateSearchAction(_ sender: UIButton) {
        search()
    }

    @IBAction func onResetAction(_ sender: UIButton) {
        setupFilters()
    }
}

extension SearchVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath) as? UserCell else {
            fatalError("Unable to dequeue resuable cell with identifier \(UserCell.identifier)")
        }

        cell.user = users[indexPath.row]

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let vc = AppStoryboard.Main.viewController(viewControllerClass: UserVC.self)
        vc.user = users[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchVC: UIEmptyStateDataSource {
    var emptyStateTitle: NSAttributedString {
        return NSAttributedString(
            string: "Sorry, we couldn't find any matches",
            attributes: [
                    .foregroundColor: UIColor.darkGrey,
                    .font: UIFont(name: "Karla-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15),
            ])
    }
}
