//
//  Toast.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 11/11/25.
//

import UIKit

/// Global convenience. Call `toast("message")` from anywhere on main thread.
public func toast(_ message: String, duration: TimeInterval = 2.0) {
    DispatchQueue.main.async {
        guard
            let window = UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                .first
        else { return }

        ToastView.show(in: window, message: message, duration: duration)
    }
}

/// Internal view with padding + blur background.
private final class ToastView: UIView {

    private let label = PaddingLabel()

    static func show(in container: UIView,
                     message: String,
                     duration: TimeInterval) {

        // Remove any existing toasts first
        container.subviews.compactMap { $0 as? ToastView }.forEach { $0.removeFromSuperview() }

        let toast = ToastView()
        toast.translatesAutoresizingMaskIntoConstraints = false
        toast.layer.cornerRadius = 12
        toast.clipsToBounds = true

        // Background blur for iOS look
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterialDark))
        blur.translatesAutoresizingMaskIntoConstraints = false
        toast.addSubview(blur)
        NSLayoutConstraint.activate([
            blur.leadingAnchor.constraint(equalTo: toast.leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: toast.trailingAnchor),
            blur.topAnchor.constraint(equalTo: toast.topAnchor),
            blur.bottomAnchor.constraint(equalTo: toast.bottomAnchor)
        ])

        toast.label.text = message
        toast.label.textColor = .white
        toast.label.numberOfLines = 0
        toast.label.font = .systemFont(ofSize: 14, weight: .medium)
        toast.label.translatesAutoresizingMaskIntoConstraints = false

        blur.contentView.addSubview(toast.label)
        NSLayoutConstraint.activate([
            toast.label.leadingAnchor.constraint(equalTo: blur.contentView.leadingAnchor),
            toast.label.trailingAnchor.constraint(equalTo: blur.contentView.trailingAnchor),
            toast.label.topAnchor.constraint(equalTo: blur.contentView.topAnchor),
            toast.label.bottomAnchor.constraint(equalTo: blur.contentView.bottomAnchor)
        ])

        container.addSubview(toast)

        // Bottom, centered, safe-area aware
        let bottom = toast.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        bottom.priority = .required

        NSLayoutConstraint.activate([
            toast.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            toast.leadingAnchor.constraint(greaterThanOrEqualTo: container.leadingAnchor, constant: 24),
            toast.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -24),
            bottom
        ])

        toast.alpha = 0
        UIView.animate(withDuration: 0.25) {
            toast.alpha = 1
        }

        // Auto-hide
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            UIView.animate(withDuration: 0.25, animations: {
                toast.alpha = 0
            }, completion: { _ in
                toast.removeFromSuperview()
            })
        }
    }
}

/// UILabel with built-in padding
private final class PaddingLabel: UILabel {
    private let inset = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: inset))
    }
    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        return CGSize(width: s.width + inset.left + inset.right,
                      height: s.height + inset.top + inset.bottom)
    }
}
