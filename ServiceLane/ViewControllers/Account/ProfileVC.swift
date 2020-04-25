//
//  ProfileVC.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/13.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import ImagePicker
import RSSelectionMenu
import SDWebImage
import SwiftValidators
import Networking

class ProfileVC: CommonTableVC {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var upload: UIButton!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var whatsApp: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var parish: Picker!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var facebook: UITextField!
    @IBOutlet weak var website: UITextField!
    @IBOutlet weak var wordCount: UILabel!
    @IBOutlet weak var shortBio: UITextView!

    var photo: UIImage?
    var categories: [Common] = []
    var selectedCategories: [String] = []
    var menu: RSSelectionMenu<String>?

    override func viewDidLoad() {
        super.viewDidLoad()

        // underline button
        upload.underline()

        // Load profile
        let params: [String: Any] = [
            "userId": StoreKey.me.value!.id,
        ]
        Helper.with(self).post(url: "/user/profile", params: params) { [weak self] res in
            guard let `self` = self else { return }
            let user = User(json: res["data"]["userInfo"])
            StoreKey.me.value = user
            self.avatar.sd_setImage(with: URL(string: user.photo), placeholderImage: #imageLiteral(resourceName: "avatar"))
            self.firstName.text = user.firstName
            self.lastName.text = user.lastName
            self.email.text = user.email
            self.phone.text = user.phone
            self.whatsApp.text = user.whatsApp
            self.address.text = user.address
            self.parish.setup(res["data"]["parishes"].arrayValue.map { item in Common(id: 0, name: item.stringValue) })
            self.parish.placeholder = user.parish
            if !user.categoryList.isEmpty {
                self.selectedCategories = user.categoryList.map { item in item.name }
                self.category.text = user.categoryList.map { item in item.name }.joined(separator: ", ")
            }
            self.categories = res["data"]["catList"].arrayValue.map { item in Common(id: item["ID"].intValue, name: item["Category"].stringValue) }
            self.setupCategory(self.categories.map { item in item.name })
            self.facebook.text = user.facebook
            self.website.text = user.webSite
            self.shortBio.text = user.shortBio
            self.shortBio.delegate = self
            let count = 140 - user.shortBio.replacingOccurrences(of: "\n", with: " ").split(separator: " ").count
            self.wordCount.text = count == 1 ? "1 word" : "\(count) words"
        }
    }

    fileprivate func setupCategory(_ items: [String]) {
        menu = RSSelectionMenu(selectionType: .Multiple, dataSource: items, cellType: .Basic) { (cell, item, indexPath) in
            cell.textLabel?.text = item
            cell.tintColor = .orange
        }
        menu?.setSelectedItems(items: selectedCategories, maxSelected: 2) { (item, checked, selectedItems) in
            self.category.text = selectedItems.joined(separator: ", ")
            self.selectedCategories = selectedItems
        }
    }

    @IBAction func onTapCategory(_ sender: UITapGestureRecognizer) {
        guard let menu = menu else { return }
        menu.show(style: .Popover(sourceView: category, size: CGSize(width: tableView.bounds.width - 48, height: 360)), from: self)
    }

    @IBAction func onUploadPhotoAction(_ sender: UIButton) {
        let imagePicker = ImagePickerController()
        imagePicker.delegate = self
        imagePicker.imageLimit = 1
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func onSaveAction(_ sender: UIButton) {
        if Validator.isEmpty().apply(firstName.text) {
            alert(message: "Please enter the first name")
        } else if Validator.isEmpty().apply(lastName.text) {
            alert(message: "Please enter the last name")
        } else if !Validator.isEmail().apply(email.text) {
            alert(message: "The email address is invalid")
        } else if selectedCategories.isEmpty {
            alert(message: "Please select the categories")
        } else if parish.selectedName.isEmpty {
            alert(message: "Please select the parish")
        } else {
            let params: [String: Any] = [
                "userId": StoreKey.me.value!.id,
                "fname": firstName.text!,
                "lname": lastName.text!,
                "email": email.text!,
                "phone": phone.text!,
                "whatsapp": whatsApp.text!,
                "address": address.text!,
                "parish": parish.selectedName,
                "categoryIds": categories.filter { item in selectedCategories.contains(item.name) }.map { item in item.id.description }.joined(separator: ", "),
                "fb_link": facebook.text!,
                "web_link": website.text!,
                "short_bio": shortBio.text!,
            ]
            if let image = photo, let imageData = image.jpegData(compressionQuality: 0.8) {
                let part = FormDataPart(type: .jpg, data: imageData, parameterName: "photo", filename: "file0.jpg")
                Helper.with(self).postMultiPart(url: "/user/updateinfo", params: params, parts: [part]) { [weak self] res in
                    guard let `self` = self else { return }
                    StoreKey.me.value = User(json: res["data"])
                    self.dismissKeyboard()
                    self.alert(message: "Updated successfully")
                }
            } else {
                Helper.with(self).post(url: "/user/updateinfo", params: params) { [weak self] res in
                    guard let `self` = self else { return }
                    StoreKey.me.value = User(json: res["data"])
                    self.dismissKeyboard()
                    self.alert(message: "Updated successfully")
                }
            }
        }
    }
}

extension ProfileVC {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if indexPath.row == 11 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 1000, bottom: 0, right: 0)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 1...10: return 48
        case 12: return 360
        default: return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
}

extension ProfileVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let count = 140 - textView.text.replacingOccurrences(of: "\n", with: " ").split(separator: " ").count
        wordCount.text = "\(count) \(count == 1 ? "word" : "words")"
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newStr = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let count = newStr.replacingOccurrences(of: "\n", with: " ").split(separator: " ").count
        return count <= 140
    }
}

extension ProfileVC: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.resetAssets()
    }

    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismiss(animated: true, completion: nil)
        if !images.isEmpty {
            photo = images.first
            avatar.image = images.first
        }
    }

    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
