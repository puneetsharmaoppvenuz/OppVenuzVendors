//
//  DesinableView.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 10/11/25.
//

import UIKit

// MARK: - Gradient Direction Enum
public enum GradientDirection: Int {
    case topToBottom = 0
    case leftToRight = 1
    case topLeftToBottomRight = 2
    case bottomLeftToTopRight = 3
}

// MARK: - UIView subclass for shadow, corner radius, gradient
@IBDesignable
class DesignableView: UIView {
    
    // MARK: - Inspectable Properties
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet { updateCornerRadius() }
    }
    
    @IBInspectable var shadowColor: UIColor = .black {
        didSet { updateShadow() }
    }
    
    @IBInspectable var shadowOpacity: Float = 0 {
        didSet { updateShadow() }
    }
    
    @IBInspectable var shadowOffset: CGSize = .zero {
        didSet { updateShadow() }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 0 {
        didSet { updateShadow() }
    }
    
    @IBInspectable var gradientStartColor: UIColor? {
        didSet { updateGradient() }
    }
    
    @IBInspectable var gradientEndColor: UIColor? {
        didSet { updateGradient() }
    }
    
    @IBInspectable var gradientDirectionRaw: Int = 0 {
        didSet { updateGradient() }
    }
    
    private var gradientLayer: CAGradientLayer?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCornerRadius()
        updateShadow()
        updateGradient()
    }
    
    // MARK: - Update Methods
    private func updateCornerRadius() {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = cornerRadius > 0 && shadowOpacity == 0
    }
    
    private func updateShadow() {
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
        layer.masksToBounds = false
    }
    
    private func updateGradient() {
        guard let startColor = gradientStartColor, let endColor = gradientEndColor else {
            gradientLayer?.removeFromSuperlayer()
            gradientLayer = nil
            return
        }
        
        let layerToUse = gradientLayer ?? CAGradientLayer()
        layerToUse.frame = bounds
        layerToUse.colors = [startColor.cgColor, endColor.cgColor]
        
        switch GradientDirection(rawValue: gradientDirectionRaw) ?? .topToBottom {
        case .topToBottom:
            layerToUse.startPoint = CGPoint(x: 0.5, y: 0.0)
            layerToUse.endPoint = CGPoint(x: 0.5, y: 1.0)
        case .leftToRight:
            layerToUse.startPoint = CGPoint(x: 0.0, y: 0.5)
            layerToUse.endPoint = CGPoint(x: 1.0, y: 0.5)
        case .topLeftToBottomRight:
            layerToUse.startPoint = CGPoint(x: 0.0, y: 0.0)
            layerToUse.endPoint = CGPoint(x: 1.0, y: 1.0)
        case .bottomLeftToTopRight:
            layerToUse.startPoint = CGPoint(x: 0.0, y: 1.0)
            layerToUse.endPoint = CGPoint(x: 1.0, y: 0.0)
        }
        
        if gradientLayer == nil {
            layer.insertSublayer(layerToUse, at: 0)
            gradientLayer = layerToUse
        }
    }
}

//
//  GradientButton.swift
//  OppVenuzVendors
//
//  Created by Puneet Sharma on 10/11/2025.
//  Comments in English only.
//

import UIKit

@IBDesignable
final class GradientButton: UIButton {
    
    // MARK: - Inspectables (brand defaults set to #5A69FC → #AF6AEF)
    @IBInspectable var startHex: String = "#5A69FC" { didSet { setNeedsLayout() } }
    @IBInspectable var endHex:   String = "#AF6AEF" { didSet { setNeedsLayout() } }
    @IBInspectable var cornerRadius: CGFloat = 12   { didSet { setNeedsLayout() } }
    
    // Shadow (Figma export style)
    // 10% black, radius 14, offset (0,7)
    @IBInspectable var shadowOpacity: Float = 0.10  { didSet { setNeedsLayout() } }
    @IBInspectable var shadowRadius: CGFloat = 14   { didSet { setNeedsLayout() } }
    @IBInspectable var shadowOffsetY: CGFloat = 7   { didSet { setNeedsLayout() } }
    
    // Typography
    @IBInspectable var fontName: String = "Poppins-SemiBold" { didSet { applyTypography() } }
    @IBInspectable var fontSize: CGFloat = 17                 { didSet { applyTypography() } }
    
    // Interaction
    @IBInspectable var darkenOnHighlight: Bool = true
    
    // Layers
    private var gradientLayer: CAGradientLayer?
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        applyGradient()
        applyShadow()
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
    }
    
    override var isHighlighted: Bool {
        didSet { animateHighlight(isHighlighted) }
    }
    
    // MARK: - Styling
    private func applyGradient() {
        let start = UIColor(hex: startHex)
        let end = UIColor(hex: endHex)
        
        if gradientLayer == nil {
            let g = CAGradientLayer()
            g.startPoint = CGPoint(x: 0.0, y: 0.5)
            g.endPoint   = CGPoint(x: 1.0, y: 0.5)
            layer.insertSublayer(g, at: 0)
            gradientLayer = g
        }
        
        gradientLayer?.frame = bounds
        gradientLayer?.cornerRadius = cornerRadius
        gradientLayer?.colors = [start.cgColor, end.cgColor]
    }
    
    private func applyShadow() {
        // Figma-style shadow path tied to current bounds and corner radius
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        layer.shadowPath   = path
        layer.shadowColor  = UIColor.black.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius  = shadowRadius
        layer.shadowOffset  = CGSize(width: 0, height: shadowOffsetY)
    }
    
    private func applyTypography() {
        titleLabel?.font = UIFont(name: fontName, size: fontSize)
        setTitleColor(.white, for: .normal)
    }
    
    private func animateHighlight(_ highlighted: Bool) {
        guard darkenOnHighlight, let gradientLayer else { return }
        // Subtle brightness change on press
        let anim = CABasicAnimation(keyPath: "opacity")
        anim.fromValue = gradientLayer.opacity
        let target: Float = highlighted ? 0.85 : 1.0
        anim.toValue = target
        anim.duration = 0.12
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        gradientLayer.add(anim, forKey: "opacity")
        gradientLayer.opacity = target
    }
}

// MARK: - Hex helper
private extension UIColor {
    convenience init(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if h.hasPrefix("#") { h.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        self.init(
            red:   CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8)  / 255.0,
            blue:  CGFloat( rgb & 0x0000FF)        / 255.0,
            alpha: 1.0
        )
    }
}

import SwiftUI

extension View {
    func signupTextFieldStyle() -> some View {
        self
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
    }
}

