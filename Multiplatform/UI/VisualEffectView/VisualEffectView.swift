//
//  VisualEffectView.swift
//  VisualEffectView
//
//  Created by Lasha Efremidze on 5/26/16.
//  Copyright © 2016 Lasha Efremidze. All rights reserved.
//

import UIKit

// swiftlint:disable identifier_name force_cast

/// VisualEffectView is a dynamic background blur view.
@objcMembers
open class VisualEffectView: UIVisualEffectView {
    /// Returns the instance of UIBlurEffect.
    private let blurEffect = (NSClassFromString("_UICustomBlurEffect") as! UIBlurEffect.Type).init()

    /// Tint color.
    ///
    /// The default value is nil.
    open var colorTint: UIColor? {
        get {
            sourceOver?.value(forKeyPath: "color") as? UIColor
        }
        set {
            prepareForChanges()
            sourceOver?.setValue(newValue, forKeyPath: "color")
            sourceOver?.perform(Selector(("applyRequestedEffectToView:")), with: overlayView)
            applyChanges()
            overlayView?.backgroundColor = newValue
        }
    }

    /// Tint color alpha.
    ///
    /// Don't use it unless `colorTint` is not nil.
    /// The default value is 0.0.
    open var colorTintAlpha: CGFloat {
        get { _value(forKey: .colorTintAlpha) ?? 0.0 }
        set { colorTint = colorTint?.withAlphaComponent(newValue) }
    }

    /// Blur radius.
    ///
    /// The default value is 0.0.
    open var blurRadius: CGFloat {
        get {
            gaussianBlur?.requestedValues?["inputRadius"] as? CGFloat ?? 0
        }
        set {
            prepareForChanges()
            gaussianBlur?.requestedValues?["inputRadius"] = newValue
            applyChanges()
        }
    }

    /// Scale factor.
    ///
    /// The scale factor determines how content in the view is mapped from
    /// the logical coordinate space (measured in points) to the device coordinate space (measured in pixels).
    ///
    /// The default value is 1.0.
    open var scale: CGFloat {
        get { _value(forKey: .scale) ?? 1.0 }
        set { _setValue(newValue, forKey: .scale) }
    }

    // MARK: - Initialization

    override public init(effect: UIVisualEffect?) {
        super.init(effect: effect)

        self.scale = 1
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.scale = 1
    }
}

// MARK: - Helpers

private extension VisualEffectView {
    /// Returns the value for the key on the blurEffect.
    func _value<T>(forKey key: Key) -> T? {
        blurEffect.value(forKeyPath: key.rawValue) as? T
    }

    /// Sets the value for the key on the blurEffect.
    func _setValue(_ value: (some Any)?, forKey key: Key) {
        blurEffect.setValue(value, forKeyPath: key.rawValue)
    }

    enum Key: String {
        case colorTint, colorTintAlpha, blurRadius, scale
    }
}

// swiftlint:enable identifier_name force_cast
