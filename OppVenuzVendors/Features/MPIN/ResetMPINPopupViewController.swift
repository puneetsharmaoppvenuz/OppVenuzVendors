//
//  ResetMPINPopupViewController.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 11/11/25.
//

import UIKit

protocol ResetMPINPopupDelegate: AnyObject {
    func resetMPINPopupDidCancel(_ popup: ResetMPINPopupViewController)
    func resetMPINPopup(_ popup: ResetMPINPopupViewController, didSubmit newMPIN: String, for username: String)
}

final class ResetMPINPopupViewController: UIViewController, UITextFieldDelegate {
    
    weak var delegate: ResetMPINPopupDelegate?
    var username: String = ""
    var totalDigits: Int = 6
    
    private let dimView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let card = UIView()
    private let titleLabel = UILabel()
    private let row1Label = UILabel()
    private let row2Label = UILabel()
    private let row1Stack = UIStackView()
    private let row2Stack = UIStackView()
    private var row1Fields: [UITextField] = []
    private var row2Fields: [UITextField] = []
    private let closeButton = UIButton(type: .system)
    private let submitButton = GradientButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        row1Fields.first?.becomeFirstResponder()
    }
    
    // MARK: - UI
    private func buildUI() {
        view.backgroundColor = .clear
        
        dimView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimView)
        NSLayoutConstraint.activate([
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
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
            card.widthAnchor.constraint(lessThanOrEqualToConstant: 420)
        ])
        
        let v = UIStackView()
        v.axis = .vertical; v.spacing = 16; v.translatesAutoresizingMaskIntoConstraints = false
        v.isLayoutMarginsRelativeArrangement = true
        v.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        card.addSubview(v)
        NSLayoutConstraint.activate([
            v.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            v.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            v.topAnchor.constraint(equalTo: card.topAnchor),
            v.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])
        
        titleLabel.text = "Change MPIN"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        row1Label.text = "Enter New MPIN"
        row1Label.font = UIFont.systemFont(ofSize: 14)
        
        row2Label.text = "Re-Enter New MPIN"
        row2Label.font = UIFont.systemFont(ofSize: 14)
        
        row1Stack.axis = .horizontal; row1Stack.spacing = 12; row1Stack.distribution = .fillEqually
        row2Stack.axis = .horizontal; row2Stack.spacing = 12; row2Stack.distribution = .fillEqually
        
        buildDigitRow(into: row1Stack, store: &row1Fields)
        buildDigitRow(into: row2Stack, store: &row2Fields)
        
        styleFilled(button: submitButton, title: "Submit")
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        submitButton.isEnabled = false
        submitButton.alpha = 0.6
        
        // Close “X”
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        
        // Layout
        let headerRow = UIStackView(arrangedSubviews: [titleLabel, UIView(), closeButton])
        headerRow.axis = .horizontal
        
        v.addArrangedSubview(headerRow)
        v.addArrangedSubview(row1Label)
        v.addArrangedSubview(row1Stack)
        v.addArrangedSubview(row2Label)
        v.addArrangedSubview(row2Stack)
        v.addArrangedSubview(submitButton)
    }
    
    private func buildDigitRow(into stack: UIStackView, store: inout [UITextField]) {
        store.removeAll()
        for _ in 0..<totalDigits {
            let tf = UITextField()
            tf.translatesAutoresizingMaskIntoConstraints = false
            tf.keyboardType = .numberPad
            tf.textAlignment = .center
            tf.font = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .semibold)
            tf.isSecureTextEntry = true
            tf.layer.cornerRadius = 10
            tf.layer.borderWidth = 1
            tf.layer.borderColor = UIColor.systemGray4.cgColor
            tf.backgroundColor = .secondarySystemBackground
            tf.delegate = self
            tf.tintColor = .systemBlue
            tf.widthAnchor.constraint(equalToConstant: 44).isActive = true
            tf.heightAnchor.constraint(equalToConstant: 44).isActive = true
            store.append(tf)
            stack.addArrangedSubview(tf)
        }
    }
    
    // MARK: - Actions
    @objc private func closeTapped() { delegate?.resetMPINPopupDidCancel(self) }
    
    @objc private func submitTapped() {
        let a = row1Fields.compactMap { $0.text }.joined()
        let b = row2Fields.compactMap { $0.text }.joined()
        guard a.count == totalDigits, b.count == totalDigits else { return }
        guard a == b else {
            shake(card)
            return
        }
        delegate?.resetMPINPopup(self, didSubmit: a, for: username)
    }
    
    // MARK: - UITextFieldDelegate (one char, move across both rows)
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard string.isEmpty || string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil else {
            return false
        }
        
        func nextField(after tf: UITextField) -> UITextField? {
            if let i = row1Fields.firstIndex(of: tf), i < row1Fields.count - 1 { return row1Fields[i+1] }
            if tf == row1Fields.last { return row2Fields.first }
            if let j = row2Fields.firstIndex(of: tf), j < row2Fields.count - 1 { return row2Fields[j+1] }
            return nil
        }
        
        func prevField(before tf: UITextField) -> UITextField? {
            if let j = row2Fields.firstIndex(of: tf), j > 0 { return row2Fields[j-1] }
            if tf == row2Fields.first { return row1Fields.last }
            if let i = row1Fields.firstIndex(of: tf), i > 0 { return row1Fields[i-1] }
            return nil
        }
        
        if string.isEmpty {
            textField.text = ""
            if let p = prevField(before: textField) {
                p.text = ""
                p.becomeFirstResponder()
            }
            refreshSubmitState()
            return false
        }
        
        textField.text = String(string.prefix(1))
        if let n = nextField(after: textField) {
            n.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        refreshSubmitState()
        return false
    }
    
    private func refreshSubmitState() {
        let a = row1Fields.allSatisfy { ($0.text ?? "").count == 1 }
        let b = row2Fields.allSatisfy { ($0.text ?? "").count == 1 }
        let ok = a && b
        submitButton.isEnabled = ok
        submitButton.alpha = ok ? 1 : 0.6
    }
    
    // MARK: - Style helpers
    private func styleFilled(button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        let g = CAGradientLayer()
        g.colors = [UIColor(hex: "#5A69FC").cgColor, UIColor(hex: "#AF6AEF").cgColor]
        g.startPoint = CGPoint(x: 0, y: 0.5)
        g.endPoint = CGPoint(x: 1, y: 0.5)
        g.cornerRadius = 12
        g.frame = button.bounds
        button.layer.insertSublayer(g, at: 0)
        button.addTarget(self, action: #selector(resizeGradient(_:)), for: .allEvents)
    }
    
    @objc private func resizeGradient(_ sender: UIButton) {
        sender.layer.sublayers?.first?.frame = sender.bounds
    }
    
    private func shake(_ view: UIView) {
        let anim = CAKeyframeAnimation(keyPath: "transform.translation.x")
        anim.values = [-8, 8, -6, 6, -4, 4, 0]
        anim.duration = 0.4
        view.layer.add(anim, forKey: "shake")
    }
}

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
