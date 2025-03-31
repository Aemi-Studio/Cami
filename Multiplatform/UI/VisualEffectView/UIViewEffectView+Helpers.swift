//
//  UIViewEffectView+Helpers.swift
//  VisualEffectView
//
//  Created by Lasha Efremidze on 9/14/20.
//

import UIKit

extension UIVisualEffectView {
    var backdropView: UIView? {
        subview(of: NSClassFromString("_UIVisualEffectBackdropView"))
    }

    var overlayView: UIView? {
        subview(of: NSClassFromString("_UIVisualEffectSubview"))
    }

    var gaussianBlur: NSObject? {
        backdropView?.value(forKey: "filters", withFilterType: "gaussianBlur")
    }

    var sourceOver: NSObject? {
        overlayView?.value(forKey: "viewEffects", withFilterType: "sourceOver")
    }

    func prepareForChanges() {
        effect = UIBlurEffect(style: .light)
        gaussianBlur?.setValue(1.0, forKeyPath: "requestedScaleHint")
    }

    func applyChanges() {
        backdropView?.perform(Selector(("applyRequestedFilterEffects")))
    }
}

extension NSObject {
    var requestedValues: [String: Any]? {
        get { value(forKeyPath: "requestedValues") as? [String: Any] }
        set { setValue(newValue, forKeyPath: "requestedValues") }
    }

    func value(forKey key: String, withFilterType filterType: String) -> NSObject? {
        if let object = (value(forKeyPath: key) as? [NSObject]) {
            object.first { $0.value(forKeyPath: "filterType") as? String == filterType }
        } else {
            nil
        }
    }
}

private extension UIView {
    func subview(of classType: AnyClass?) -> UIView? {
        subviews.first { type(of: $0) == classType }
    }
}
