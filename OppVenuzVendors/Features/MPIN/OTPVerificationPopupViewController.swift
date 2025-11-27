//
//  VerifyOTP.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 11/11/25.
//

import UIKit

protocol OTPVerificationPopupDelegate: AnyObject {
    func otpPopupDidCancel(_ popup: OTPVerificationPopupViewController)
    func otpPopup(_ popup: OTPVerificationPopupViewController, didVerifyOTPFor username: String)
}

final class OTPVerificationPopupViewController: UIViewController, UITextFieldDelegate {
    
    weak var delegate: OTPVerificationPopupDelegate?
    var username: String = ""
    var totalDigits: Int = 6
    var resendSeconds: Int = 40   // start at 40s; screenshot shows (39s)
    
    private let dimView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let card = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let fieldsStack = UIStackView()
    private var fields: [UITextField] = []
    private let cancelButton = UIButton(type: .system)
    private let verifyButton = GradientButton()
    private let resendLabel = UILabel()
    private let resendButton = UIButton(type: .system)
    
    private var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        startTimer()
    }
    
    deinit { timer?.invalidate() }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fields.first?.becomeFirstResponder()
        updateActiveVisuals()
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
            card.widthAnchor.constraint(lessThanOrEqualToConstant: 380)
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
        
        titleLabel.text = "OTP Verification"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textAlignment = .center
        
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.text = "Please Enter OTP sent on your\n\(maskedUsername(username))"
        
        fieldsStack.axis = .horizontal
        fieldsStack.spacing = 12
        fieldsStack.distribution = .fillEqually
        buildDigitFields()
        
        let buttonsRow = UIStackView()
        buttonsRow.axis = .horizontal
        buttonsRow.spacing = 12
        buttonsRow.distribution = .fillEqually
        
        styleHollow(button: cancelButton, title: "Cancel")
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        
        styleFilled(button: verifyButton, title: "Verify OTP")
        verifyButton.addTarget(self, action: #selector(verifyTapped), for: .touchUpInside)
        verifyButton.isEnabled = false
        verifyButton.alpha = 0.6
        
        // Resend row
        let resendRow = UIStackView()
        resendRow.axis = .horizontal
        resendRow.alignment = .center
        resendRow.spacing = 4
        resendRow.distribution = .fill
        resendLabel.font = UIFont.systemFont(ofSize: 13)
        resendLabel.textColor = .secondaryLabel
        resendLabel.text = "Didn’t receive the code?"
        resendButton.setTitle("Resend", for: .normal)
        resendButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        resendButton.isEnabled = false
        resendButton.addTarget(self, action: #selector(resendTapped), for: .touchUpInside)
        
        v.addArrangedSubview(titleLabel)
        v.setCustomSpacing(4, after: titleLabel)
        v.addArrangedSubview(subtitleLabel)
        v.addArrangedSubview(fieldsStack)
        v.addArrangedSubview(buttonsRow)
        buttonsRow.addArrangedSubview(cancelButton)
        buttonsRow.addArrangedSubview(verifyButton)
        v.addArrangedSubview(resendRow)
        resendRow.addArrangedSubview(resendLabel)
        resendRow.addArrangedSubview(resendButton)
    }
    
    private func buildDigitFields() {
        fields.removeAll()
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
            fields.append(tf)
            fieldsStack.addArrangedSubview(tf)
        }
    }
    
    private func maskedUsername(_ s: String) -> String {
        // If looks like email, mask user part; otherwise mask phone.
        if s.contains("@") {
            let parts = s.split(separator: "@", maxSplits: 1).map(String.init)
            guard parts.count == 2 else { return s }
            let user = parts[0]
            let domain = parts[1]
            let maskedUser = user.count <= 2 ? String(repeating: "*", count: user.count)
            : user.prefix(2) + String(repeating: "*", count: max(user.count-2,0))
            return "\(maskedUser)@\(domain)"
        } else {
            let digits = s.filter { $0.isNumber }
            if digits.count >= 4 {
                let suffix = digits.suffix(3)
                return "Mobile No. *********\(suffix)"
            }
            return s
        }
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() { delegate?.otpPopupDidCancel(self) }
    
    @objc private func verifyTapped() {
        let code = fields.compactMap { $0.text }.joined()
        // TEMP RULE: 123456 passes (as per your note). Replace with OTP API later.
        if code == "123456" {
            delegate?.otpPopup(self, didVerifyOTPFor: username)
        } else {
            shake(card)
            // optional toast
        }
    }
    
    @objc private func resendTapped() {
        // Call resend API here later. For now just restart timer.
        resendSeconds = 40
        resendButton.isEnabled = false
        updateResendTitle()
        timer?.invalidate()
        startTimer()
    }
    
    // MARK: - Timer
    private func startTimer() {
        updateResendTitle()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] t in
            guard let self else { return }
            resendSeconds -= 1
            if resendSeconds <= 0 {
                t.invalidate()
                resendButton.isEnabled = true
                resendButton.setTitle("Resend", for: .normal)
            } else {
                updateResendTitle()
            }
        }
    }
    
    private func updateResendTitle() {
        resendButton.setTitle("Resend (\(resendSeconds)s)", for: .disabled)
    }
    
    // MARK: - Focus visuals
    private func updateActiveVisuals() {
        let activeIndex: Int = {
            if let i = fields.firstIndex(where: { ($0.text ?? "").isEmpty }) { return i }
            return max(fields.count - 1, 0)
        }()
        
        for (i, tf) in fields.enumerated() {
            if i == activeIndex {
                tf.layer.borderColor = UIColor.systemBlue.cgColor
                startBlink(on: tf)
            } else {
                tf.layer.borderColor = UIColor.systemGray4.cgColor
                stopBlink(on: tf)
            }
        }
    }
    
    private func startBlink(on tf: UITextField) {
        let key = "blink"
        tf.layer.removeAnimation(forKey: key)
        let anim = CABasicAnimation(keyPath: "opacity")
        anim.fromValue = 1.0
        anim.toValue = 0.7
        anim.duration = 0.8
        anim.autoreverses = true
        anim.repeatCount = .infinity
        tf.layer.add(anim, forKey: key)
    }
    
    private func stopBlink(on tf: UITextField) {
        tf.layer.removeAnimation(forKey: "blink")
        tf.layer.opacity = 1.0
    }
    
    // MARK: - UITextFieldDelegate
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard string.isEmpty || string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil else {
            return false
        }
        if string.isEmpty {
            textField.text = ""
            if let i = fields.firstIndex(of: textField), i > 0 {
                let prev = fields[i - 1]
                prev.text = ""
                prev.becomeFirstResponder()
            }
            refreshVerifyState()
            updateActiveVisuals()
            return false
        }
        textField.text = String(string.prefix(1))
        if let i = fields.firstIndex(of: textField), i < fields.count - 1 {
            fields[i + 1].becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        refreshVerifyState()
        updateActiveVisuals()
        return false
    }
    
    private func refreshVerifyState() {
        let filled = fields.allSatisfy { ($0.text ?? "").count == 1 }
        verifyButton.isEnabled = filled
        verifyButton.alpha = filled ? 1.0 : 0.6
    }
    
    // MARK: - Style helpers
    private func styleHollow(button: UIButton, title: String) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }
    
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
