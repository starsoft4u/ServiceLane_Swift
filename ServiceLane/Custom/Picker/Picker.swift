//
//  Picker.swift
//  Yeahh
//
//  Created by raptor on 2018/5/10.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import McPicker

@IBDesignable class Picker: UIView {
    var view: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var left: NSLayoutConstraint!
    @IBOutlet weak var right: NSLayoutConstraint!
    @IBInspectable var icon: UIImage? {
        didSet {
            if let icon = self.icon {
                iconView.isHidden = false
                iconView.image = icon
            } else {
                iconView.isHidden = true
            }
        }
    }
    @IBInspectable var placeholder: String? {
        didSet {
            if let title = self.title {
                title.text = placeholder
            }
        }
    }
    @IBInspectable var size: CGFloat = 17 {
        didSet {
            title.font = title.font.withSize(size)
        }
    }
    @IBInspectable var color: UIColor? {
        didSet {
            title.textColor = color
        }
    }
    @IBInspectable var paddingLeft: CGFloat = 8 {
        didSet {
            left.constant = paddingLeft
            updateConstraints()
        }
    }
    @IBInspectable var paddingRight: CGFloat = 8 {
        didSet {
            right.constant = paddingRight
            updateConstraints()
        }
    }

    var didSelect: ((Common) -> Void)?
    var selectedIndex: Int? {
        return items.index(where: { $0.name == title.text })
    }
    var selectedId: Int {
        get {
            if let index = selectedIndex {
                return items[index].id
            } else {
                return 0
            }
        }
        set {
            if let index = items.index(where: { $0.id == newValue }) {
                placeholder = items[index].name
            }
        }
    }
    var selectedName: String {
        if let index = selectedIndex {
            return items[index].name
        } else {
            return ""
        }
    }

    var items: [Common] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    func initialize() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }

    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "Picker", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView

        return view
    }

    func setup(_ items: [Common]) {
        guard !items.isEmpty else { return }

        self.items = items
        let gesture = UITapGestureRecognizer(target: self, action: #selector(Picker.onTapPicker(_:)))
        view.addGestureRecognizer(gesture)
    }

    @objc fileprivate func onTapPicker(_ sender: Any) {
        // dismiss keyboard
        var root = view
        while (root?.superview != nil) {
            root = root?.superview
        }
        root?.endEditing(true)

        let picker = McPicker(data: [items.map { $0.name }])
        if let index = selectedIndex {
            picker.pickerSelectRowsForComponents = [0: [index: true]]
        }
        picker.show { item in
            self.title.text = item[0]
            self.didSelect?(Common(id: self.selectedId, name: self.selectedName))
        }
    }
}
