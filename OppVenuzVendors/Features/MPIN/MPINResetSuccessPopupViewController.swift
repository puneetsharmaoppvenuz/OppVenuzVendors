//
//  MPINResetSuccessPopupViewController.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 11/11/25.
//

import UIKit

protocol MPINResetSuccessPopupDelegate: AnyObject {
    func mpinResetSuccessContinue(_ popup: MPINResetSuccessPopupViewController)
}

final class MPINResetSuccessPopupViewController: UIViewController {
    
    weak var delegate: MPINResetSuccessPopupDelegate?
    
    private let dimView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let card = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let button = GradientButton()
    
    // Keep a reference so we can safely resize without duplicating layers
    private var buttonGradient: CAGradientLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Ensure the gradient always matches the latest button bounds
        buttonGradient?.frame = button.bounds
    }
    
    private func buildUI() {
        view.backgroundColor = .clear
        
        // Dim
        dimView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimView)
        NSLayoutConstraint.activate([
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Card
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.96)
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.15
        card.layer.shadowOffset = CGSize(width: 0, height: 8)
        card.layer.shadowRadius = 20
        view.addSubview(card)
        
        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            card.widthAnchor.constraint(lessThanOrEqualToConstant: 380)
        ])
        
        // Vertical stack inside card
        let v = UIStackView()
        v.axis = .vertical
        v.alignment = .center
        v.spacing = 20
        v.isLayoutMarginsRelativeArrangement = true
        v.layoutMargins = UIEdgeInsets(top: 28, left: 24, bottom: 24, right: 24)
        v.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(v)
        NSLayoutConstraint.activate([
            v.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            v.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            v.topAnchor.constraint(equalTo: card.topAnchor),
            v.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])
        
        // Icon
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.image = UIImage(systemName: "checkmark.circle.fill")
        iconView.tintColor = .systemGreen
        iconView.contentMode = .scaleAspectFit
        iconView.widthAnchor.constraint(equalToConstant: 64).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 64).isActive = true
        
        // Title — two lines, centered, Roboto-Bold if available
        titleLabel.text = "Your MPIN\nReset Successfully"
        titleLabel.font = UIFont(name: "Roboto-Bold", size: 22) ?? .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.adjustsFontForContentSizeCategory = true
        
        // Gradient button
        styleGradient(button: button, title: "Continue")
        button.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        // Arrange
        v.addArrangedSubview(iconView)
        v.addArrangedSubview(titleLabel)
        
        // spacer to give air between title and button on small screens
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: 8).isActive = true
        v.addArrangedSubview(spacer)
        
        v.addArrangedSubview(button)
        button.leadingAnchor.constraint(equalTo: v.layoutMarginsGuide.leadingAnchor).isActive = true
        button.trailingAnchor.constraint(equalTo: v.layoutMarginsGuide.trailingAnchor).isActive = true
        
        // Accessibility
        view.accessibilityViewIsModal = true
        titleLabel.accessibilityLabel = "Your MPIN reset successfully. Continue."
    }
    
    @objc private func continueTapped() {
        delegate?.mpinResetSuccessContinue(self)
    }
    
    // MARK: - Styling
    
    private func styleGradient(button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont(name: "Roboto-Medium", size: 16) ?? .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        
        // Drop shadow under the button (on container)
        let shadow = CALayer()
        shadow.shadowColor = UIColor.black.cgColor
        shadow.shadowOpacity = 0.20
        shadow.shadowOffset = CGSize(width: 0, height: 7)
        shadow.shadowRadius = 14
        shadow.frame = button.bounds
        shadow.backgroundColor = UIColor.clear.cgColor
        shadow.cornerRadius = 20
        button.layer.insertSublayer(shadow, at: 0)
        
        // Gradient layer – replace if already present
        let grad = CAGradientLayer()
        grad.colors = [UIColor(hex: "#5A69FC").cgColor, UIColor(hex: "#AF6AEF").cgColor]
        grad.startPoint = CGPoint(x: 0, y: 0.5)
        grad.endPoint   = CGPoint(x: 1, y: 0.5)
        grad.cornerRadius = 20
        grad.frame = button.bounds
        
        // Remove previous gradient if any
        buttonGradient?.removeFromSuperlayer()
        button.layer.insertSublayer(grad, above: shadow)
        buttonGradient = grad
    }
}

// MARK: - Hex helper
private extension UIColor {
    convenience init(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if h.hasPrefix("#") { h.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        self.init(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgb & 0x0000FF) / 255.0,
                  alpha: 1.0)
    }
}
