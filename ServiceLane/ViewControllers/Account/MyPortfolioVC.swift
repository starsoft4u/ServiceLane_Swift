//
//  PortfolioVC.swift
//  ServiceLane
//
//  Created by raptor on 2018/6/14.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import Lightbox
import ImagePicker
import Networking

class MyPortfolioVC: CommonVC {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout!

    var portfolios: [Portfolio] = []
    var images: [LightboxImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Collection view
        let nib = UINib(nibName: PortfolioCell.nibName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: PortfolioCell.identifier)

        // Load portfolio
        loadPortfolio()
    }

    fileprivate func loadPortfolio() {
        let params: [String: Any] = [
            "userId": StoreKey.me.value!.id,
        ]
        Helper.with(self).post(url: "/user/profile", params: params) { [weak self] res in
            guard let `self` = self else { return }
            self.portfolios = res["data"]["prList"].arrayValue.map(Portfolio.init)
            self.images = self.portfolios.map { item in
                return item.image.isEmpty ? LightboxImage(image: #imageLiteral(resourceName: "ic_empty")) : LightboxImage(imageURL: URL(string: item.image)!)
            }
            self.collectionView.reloadData()
        }
    }

    @objc fileprivate func onAddAction(_ sender: UIButton) {
        let imagePicker = ImagePickerController()
        imagePicker.delegate = self
        imagePicker.imageLimit = 1
        present(imagePicker, animated: true, completion: nil)
    }
}

extension MyPortfolioVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
        cell.onTapImage = {
            let controller = LightboxController(images: self.images, startIndex: indexPath.item)
            self.present(controller, animated: true, completion: nil)
        }
        cell.onDelete = { item in
            self.alert(message: "Are you sure you want to delete this photo?", positiveTitle: "Delete", positiveAction: {
                let params: [String: Any] = [
                    "userId": StoreKey.me.value!.id,
                    "id": item.id
                ]
                Helper.with(self).post(url: "/user/deletePortfolio", params: params, completion: { [weak self] res in
                    guard let `self` = self else { return }
                    self.portfolios.remove(at: indexPath.item)
                    self.images.remove(at: indexPath.item)
                    self.collectionView.reloadData()
                })
            }, negativeTitle: "Cancel")
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            fatalError("Unexpected collection reusable view \(kind)")
        }

        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)

        if let button = header.viewWithTag(1) as? UIButton {
            button.addTarget(self, action: #selector(onAddAction(_:)), for: .touchUpInside)
        }

        return header
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w: CGFloat = (collectionView.bounds.width - 16 - 24 * 2) / 2
        return CGSize(width: w, height: w + 72)
    }
}

extension MyPortfolioVC: ImagePickerDelegate {
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.resetAssets()
    }

    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        imagePicker.dismiss(animated: true, completion: nil)

        if !images.isEmpty, let image = images.first {
            let targetSize = CGSize(width: 800, height: 800)
            let uploadImage = (image.size.width <= targetSize.width && image.size.height <= targetSize.height) ? image : image.resize(to: targetSize)

            let params: [String: Any] = [
                "userId": StoreKey.me.value!.id
            ]
            let part = FormDataPart(type: .jpg, data: uploadImage.jpegData(compressionQuality: 0.8)!, parameterName: "photo", filename: "file0.jpg")
            Helper.with(self).postMultiPart(url: "/user/addPortfolio", params: params, parts: [part]) { [weak self] res in
                guard let `self` = self else { return }
                self.loadPortfolio()
            }
        }
    }

    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
