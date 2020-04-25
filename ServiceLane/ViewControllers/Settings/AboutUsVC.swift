//
//  AboutUsVC.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/15.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit

class AboutUsVC: CommonTableVC {
    @IBOutlet weak var header: UIView!

    var items: [AboutUsItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        items = [
            (firstImage: #imageLiteral(resourceName: "about_1_1"), secondImage: #imageLiteral(resourceName: "about_1_2"), description: "Service Lane is a platform that connects independent Grenadian contractors to people in need of their services."),
            (firstImage: #imageLiteral(resourceName: "about_2"), secondImage: nil, description: "The directory helps search, filter, connect, preview and contact local service professionals."),
            (firstImage: #imageLiteral(resourceName: "about_3_1"), secondImage: #imageLiteral(resourceName: "about_3_2"), description: "Service Lane has a strong commitment to quality; we work hard to give our members the best experience."),
            (firstImage: #imageLiteral(resourceName: "about_4"), secondImage: nil, description: "Forget running around trying to get things done. With Service Lane, you can get work done easily")
        ]

        let nib = UINib(nibName: AboutUsCell.nibName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: AboutUsCell.identifier)
        tableView.tableHeaderView = header
    }
}

extension AboutUsVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AboutUsCell.identifier, for: indexPath) as? AboutUsCell else {
            fatalError("Unable to dequeue resuable cell with identifier \(AboutUsCell.identifier)")
        }

        cell.item = items[indexPath.row]

        return cell
    }
}
