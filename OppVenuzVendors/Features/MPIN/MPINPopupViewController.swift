//
//  MPINPopupViewController.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 11/11/25.
//

import UIKit

protocol MPINPopupDelegate: AnyObject {
    func mpinPopupDidCancel(_ popup: MPINPopupViewController)
    func mpinPopup(_ popup: MPINPopupViewController, didTapProceed username: String, mpin: String)
    func mpinPopupForgotTapped(_ popup: MPINPopupViewController, for username: String)
}

final class MPINPopupViewController: UIViewController, UITextFieldDelegate {

    // MARK: Inputs
    weak var delegate: MPINPopupDelegate?
    var username: String = ""
    var totalDigits: Int = 6

    // MARK: UI
    private let dimView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let card = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let fieldsStack = UIStackView()
    private var fields: [UITextField] = []

    private let cancelButton = UIButton(type: .system)
    // Use your existing GradientButton subclass. It must exist in the project.
    private let verifyButton = GradientButton(type: .system)
    private let forgotButton = UIButton(type: .system)

    private var verifyHeight: NSLayoutConstraint?

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fields.first?.becomeFirstResponder()
        updateActiveVisuals()
        layoutGradientIfNeeded()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutGradientIfNeeded()
    }

    // MARK: Build
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
        card.backgroundColor = UIColor.systemBackground
        card.layer.cornerRadius = 18
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.18
        card.layer.shadowRadius = 24
        card.layer.shadowOffset = CGSize(width: 0, height: 8)
        view.addSubview(card)

        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            card.widthAnchor.constraint(lessThanOrEqualToConstant: 460)
        ])

        let v = UIStackView()
        v.axis = .vertical
        v.spacing = 16
        v.isLayoutMarginsRelativeArrangement = true
        v.layoutMargins = UIEdgeInsets(top: 24, left: 22, bottom: 22, right: 22)
        v.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(v)
        NSLayoutConstraint.activate([
            v.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            v.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            v.topAnchor.constraint(equalTo: card.topAnchor),
            v.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])

        titleLabel.text = "MPIN Verification"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textAlignment = .center

        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.font = .systemFont(ofSize: 15)
        subtitleLabel.text = "Enter MPIN for \(username)"

        fieldsStack.axis = .horizontal
        fieldsStack.spacing = 12
        fieldsStack.distribution = .fillEqually
        buildDigitFields()

        // Buttons row
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 12
        row.distribution = .fillEqually

        // Cancel (hollow)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        cancelButton.setTitleColor(.systemBlue, for: .normal)
        cancelButton.layer.cornerRadius = 12
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.systemBlue.cgColor
        cancelButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        // Verify (gradient)
        verifyButton.setTitle("Verify", for: .normal)
        verifyButton.setTitleColor(.white, for: .normal)
        verifyButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        verifyButton.layer.cornerRadius = 12
        verifyButton.clipsToBounds = true
        verifyButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        verifyButton.addTarget(self, action: #selector(verifyTapped), for: .touchUpInside)
        verifyButton.isEnabled = false
        verifyButton.alpha = 0.6
        // Fixed height so it never collapses (this was why it looked “missing”)
        verifyButton.translatesAutoresizingMaskIntoConstraints = false
        verifyHeight = verifyButton.heightAnchor.constraint(equalToConstant: 52)
        verifyHeight?.isActive = true

        row.addArrangedSubview(cancelButton)
        row.addArrangedSubview(verifyButton)

        // Forgot MPIN
        forgotButton.setTitle("Forgot MPIN", for: .normal)
        forgotButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        forgotButton.addTarget(self, action: #selector(forgotTapped), for: .touchUpInside)
        forgotButton.contentEdgeInsets = .zero

        // Assemble
        v.addArrangedSubview(titleLabel)
        v.addArrangedSubview(subtitleLabel)
        v.addArrangedSubview(fieldsStack)
        v.addArrangedSubview(row)
        v.addArrangedSubview(forgotButton)
    }

    private func buildDigitFields() {
        fields.forEach { $0.removeFromSuperview() }
        fields.removeAll()

        for _ in 0..<totalDigits {
            let tf = UITextField()
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
            tf.translatesAutoresizingMaskIntoConstraints = false
            tf.widthAnchor.constraint(equalToConstant: 48).isActive = true
            tf.heightAnchor.constraint(equalToConstant: 48).isActive = true
            fields.append(tf)
            fieldsStack.addArrangedSubview(tf)
        }
    }

    // MARK: Actions
    @objc private func cancelTapped() { delegate?.mpinPopupDidCancel(self) }

    @objc private func verifyTapped() {
        let pin = fields.compactMap { $0.text }.joined()
        guard pin.count == totalDigits else { return }
        delegate?.mpinPopup(self, didTapProceed: username, mpin: pin)
    }

    @objc private func forgotTapped() {
        delegate?.mpinPopupForgotTapped(self, for: username)
    }

    // MARK: Focus + Blink
    private func updateActiveVisuals() {
        let activeIndex: Int = fields.firstIndex(where: { ($0.text ?? "").isEmpty }) ?? (fields.count - 1)
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
        anim.fromValue = 1
        anim.toValue = 0.6
        anim.duration = 0.8
        anim.autoreverses = true
        anim.repeatCount = .infinity
        tf.layer.add(anim, forKey: key)
    }
    private func stopBlink(on tf: UITextField) {
        tf.layer.removeAnimation(forKey: "blink")
        tf.layer.opacity = 1
    }

    // MARK: UITextFieldDelegate
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        // Only digits
        if !string.isEmpty, string.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil {
            return false
        }

        if string.isEmpty {
            textField.text = ""
            if let i = fields.firstIndex(of: textField), i > 0 {
                fields[i - 1].text = ""
                fields[i - 1].becomeFirstResponder()
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

    private func layoutGradientIfNeeded() {
        // Ensure GradientButton’s layer fills bounds after layout changes.
        verifyButton.setNeedsLayout()
        verifyButton.layoutIfNeeded()
    }
}
