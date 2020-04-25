//
//  CommonTableVC.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/13.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit

class CommonTableVC: UITableViewController {

    override func viewWillAppear(_ animated: Bool) {
        viewWillAppear(animated, navigationBar: true)
    }

    func viewWillAppear(_ animated: Bool, navigationBar: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(!navigationBar, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        hideKeyboardWhenTappedAround()

        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 1))
    }
}

extension CommonTableVC {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
