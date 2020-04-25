//
//  Jiggyo+types.swift
//  Jiggyo
//
//  Created by raptor on 10/01/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension Double {
    func fixed(_ num: Int, trimZero: Bool = true) -> String {
        let cnt = (trimZero && self.truncatingRemainder(dividingBy: 1) == 0) ? 0 : num
        let format = "%.\(cnt)f"
        return String(format: format, self)
    }
}

extension Int {
    var formatted: String {
        let formatter = NumberFormatter()
        formatter.groupingSize = 3
        formatter.groupingSeparator = ","
        formatter.decimalSeparator = "."
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self))!
    }
}

extension NSObject {

    class var dynamicClassFullName: String {
        return NSStringFromClass(self)
    }

    class var dynamicClassName: String {
        let p = dynamicClassFullName
        let r = p.range(of: ".")!
        return String(p[r.upperBound...])
    }

    var dynamicTypeFullName: String {
        return NSStringFromClass(type(of: self))
    }

    var dynamicTypeName: String {
        let p = dynamicTypeFullName
        let r = p.range(of: ".")!
        return String(p[r.upperBound...])
    }

}

extension UIViewController {
    // keyboard
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func alert(icon: UIImage? = nil, message: String, positiveTitle: String = "OK", positiveAction: (() -> Void)? = nil, negativeTitle: String? = nil, negativeAction: (() -> Void)? = nil) {
        let alert = AppStoryboard.Main.viewController(viewControllerClass: AlertVC.self)

        alert.icon = icon
        alert.message = message
        alert.positiveTitle = positiveTitle
        alert.positiveAction = positiveAction
        alert.negativeTitle = negativeTitle
        alert.negativeAction = negativeAction

        present(alert, animated: true, completion: nil)
    }
}

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    @IBInspectable var shadowColor: UIColor? {
        get { return UIColor(cgColor: layer.shadowColor!) }
        set { layer.shadowColor = newValue?.cgColor }
    }

    @IBInspectable var shadowSize: CGFloat {
        get { return layer.shadowOffset.width }
        set { layer.shadowOffset = CGSize(width: newValue, height: newValue) }
    }

    @IBInspectable var shadowRadius: CGFloat {
        get { return layer.shadowRadius }
        set { layer.shadowRadius = newValue }
    }

    @IBInspectable var shadowOpacity: Float {
        get { return layer.shadowOpacity }
        set { layer.shadowOpacity = min(newValue, 1) }
    }

    open class var nibName: String {
        return self.dynamicClassName
    }

    open class var identifier: String {
        return self.nibName
    }

    func lock() {
        if let _ = viewWithTag(10) {
            //View is already locked
        }
        else {
            let lockView = UIView(frame: bounds)
            lockView.backgroundColor = UIColor(white: 0.0, alpha: 0.75)
            lockView.tag = 10
            lockView.alpha = 0.0
            let activity = UIActivityIndicatorView(style: .white)
            activity.hidesWhenStopped = true
            activity.center = lockView.center
            lockView.addSubview(activity)
            activity.startAnimating()
            addSubview(lockView)

            UIView.animate(withDuration: 0.2) {
                lockView.alpha = 1.0
            }
        }
    }

    func unlock() {
        if let lockView = viewWithTag(10) {
            UIView.animate(withDuration: 0.2, animations: {
                lockView.alpha = 0.0
            }) { finished in
                lockView.removeFromSuperview()
            }
        }
    }

    func fadeOut(duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.alpha = 0.0
        }
    }

    func fadeIn(duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.alpha = 1.0
        }
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }

    open class var orange: UIColor { return UIColor(rgb: 0xFF6100) }
    open class var grass: UIColor { return UIColor(rgb: 0x2AD59E) }
    open class var blue: UIColor { return UIColor(rgb: 0x0078C5) }
    open class var darkGrey: UIColor { return UIColor(rgb: 0x3F403F) }
}

extension UITextField {
    func addToolbar(
        doneTitle: String? = nil,
        onDone: (target: Any, action: Selector)? = nil,
        cancelTitle: String? = nil,
        onCancel: (target: Any, action: Selector)? = nil) {

        let onCancel = onCancel ?? (target: self, action: #selector(cancelButtonTapped))
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))

        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            UIBarButtonItem(title: cancelTitle ?? "Cancel", style: .plain, target: onCancel.target, action: onCancel.action),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: doneTitle ?? "Done", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()

        self.inputAccessoryView = toolbar
    }

    // Default actions:
    @objc func doneButtonTapped() { self.resignFirstResponder() }
    @objc func cancelButtonTapped() { self.resignFirstResponder() }
}

extension UIButton {
    func multiline(_ lines: Int = 0) {
        titleLabel?.numberOfLines = lines
        titleLabel?.lineBreakMode = .byTruncatingTail
        titleLabel?.textAlignment = .center
    }

    func underline() {
        guard let titleLabel = self.titleLabel, let str = titleLabel.text else { return }

        var attrs: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: tintColor,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.underlineColor: tintColor
        ]
        if let font = titleLabel.font {
            attrs[NSAttributedString.Key.font] = font
        }
        titleLabel.attributedText = NSMutableAttributedString(string: str, attributes: attrs)
    }
}

extension UIImage {
    func resize(to targetSize: CGSize) -> UIImage {
        let size = self.size

        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        draw(in: rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
