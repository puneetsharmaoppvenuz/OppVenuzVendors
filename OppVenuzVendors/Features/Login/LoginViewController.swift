
//
//  LoginViewController.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 10/11/25.
//

import UIKit
import SwiftUI

// MARK: - Safe decode types
private struct AuthData: Decodable { let token: String? }
private struct AuthResponseEnvelope: Decodable {
    let status: Bool?
    let message: String?
    let data: AuthData?
}

final class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var loginButton: GradientButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stylizeButton()
    }
    
    private func stylizeButton() {
        // For normal UIButton, add gradient programmatically.
        if !(loginButton != nil) {
            addGradient(to: loginButton)
        }
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        loginButton.layer.cornerRadius = 14
        loginButton.clipsToBounds = true
    }
    
    private func addGradient(to button: UIButton) {
        let g = CAGradientLayer()
        g.colors = [UIColor(hex: "#5A69FC").cgColor, UIColor(hex: "#AF6AEF").cgColor]
        g.startPoint = CGPoint(x: 0, y: 0.5)
        g.endPoint = CGPoint(x: 1, y: 0.5)
        g.cornerRadius = 14
        g.frame = button.bounds
        button.layer.insertSublayer(g, at: 0)
        button.addTarget(self, action: #selector(_syncGradientFrame(_:)), for: .allEvents)
    }
    
    @objc private func _syncGradientFrame(_ sender: UIButton) {
        sender.layer.sublayers?.first?.frame = sender.bounds
    }
    
    // MARK: - Actions
    @IBAction func didTapLogin(_ sender: GradientButton) {
        guard let raw = usernameField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty else {
            toast("Please enter your mobile number or email.")
            return
        }
        guard isValidEmail(raw) || isValidPhone(raw) else {
            toast("Please enter a valid mobile number or email.")
            return
        }
        
        let popup = MPINPopupViewController()
        popup.modalPresentationStyle = .overFullScreen
        popup.modalTransitionStyle = .crossDissolve
        popup.username = raw
        popup.delegate = self
        present(popup, animated: true)
    }
    
    // MARK: - Networking
    private func performLogin(username: String, mpin: String) {
        Task { @MainActor in
            do {
                GlobalLoader.shared.show()
                
                let req: URLRequest = try APIRequestFactory.make(.login(username: username, mpin: mpin))
                let resp: AuthResponseEnvelope = try await NetworkManager.shared
                    .requestJSON(req, decode: AuthResponseEnvelope.self)
                
                GlobalLoader.shared.hideAfterResponse(minDelay: 1.0)
                
                if let token = resp.data?.token, (resp.status ?? true) {
                    VendorSessionManager.shared.setToken(token)
                    routeToHome()
                } else {
                    // prefer envelope message if server returned status=false
                    toast(resp.message ?? "Login failed.")
                }
                
            } catch let NetworkError.status(code, rawBody) {
                GlobalLoader.shared.hideAfterResponse(minDelay: 1.0)
                
                // Parse JSON body to extract message/non_field_errors if possible
                let data = rawBody.data(using: .utf8)
                let server = APIErrorEnvelope.decode(from: data)
                let best = server?.bestMessage
                ?? (rawBody.isEmpty ? HTTPURLResponse.localizedString(forStatusCode: code) : rawBody)
                toast(best)
                
            } catch {
                GlobalLoader.shared.hideAfterResponse(minDelay: 1.0)
                toast(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Validators
    private func isValidEmail(_ s: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: s)
    }
    
    private func isValidPhone(_ s: String) -> Bool {
        let digits = s.filter { $0.isNumber }
        return (8...14).contains(digits.count)
    }
    
    private func routeToHome() {
        let homeView = VendorHomeTabView()
        let host = UIHostingController(rootView: homeView)
        host.modalPresentationStyle = .fullScreen
        present(host, animated: true)
    }
    
    // Signup
    @IBAction func signupButtonTapped(_ sender: UIButton) {
        let signupView = SignupContactView { [weak self] in
            self?.openSignupBasicDetails()
        }
        
        let hostingVC = UIHostingController(rootView: signupView)
        self.navigationController?.pushViewController(hostingVC, animated: true)
    }
    
    private func openSignupBasicDetails() {
        let basicView = SignupBasicDetailsView { [weak self] in
            self?.openMPINSetup()
        }
        let host = UIHostingController(rootView: basicView)
        navigationController?.pushViewController(host, animated: true)
    }
    
    private func openMPINSetup() {
        let mpinView = SignupMPINView { [weak self] in
            self?.openBusinessLocation()
        }
        let host = UIHostingController(rootView: mpinView)
        navigationController?.pushViewController(host, animated: true)
    }
    
    private func openBusinessLocation() {
        let locationView = SignupBusinessLocationView {  [weak self] in
            self?.openSignupDocuments()
        }
        let host = UIHostingController(rootView: locationView)
        navigationController?.pushViewController(host, animated: true)
    }
    
    private func openSignupDocuments() {
        let documentsView = SignupDocumentsView { [weak self] in
            self?.openSignupPolicies()
        }
        let hosting = UIHostingController(rootView: documentsView)
        navigationController?.pushViewController(hosting, animated: true)
    }
    
    private func openSignupPolicies() {
        let policiesView = SignupPoliciesView { [weak self] in
            self?.handleSignupSuccess()
        }
        let host = UIHostingController(rootView: policiesView)
        navigationController?.pushViewController(host, animated: true)
    }
    
    private func handleSignupSuccess() {
        let successView = SignupSuccessView { [weak self] in
            self?.routeToHome()
        }
        let host = UIHostingController(rootView: successView)
        host.modalPresentationStyle = .fullScreen
        
        // Make success screen the only VC in navigation stack
        navigationController?.setViewControllers([host], animated: true)
    }
    
}

// MARK: - MPIN chain
extension LoginViewController: MPINPopupDelegate {
    
    func mpinPopupDidCancel(_ popup: MPINPopupViewController) {
        popup.dismiss(animated: true)
    }
    
    func mpinPopup(_ popup: MPINPopupViewController, didTapProceed username: String, mpin: String) {
        popup.dismiss(animated: true) { [weak self] in
            self?.performLogin(username: username, mpin: mpin)
        }
    }
    
    func mpinPopupForgotTapped(_ popup: MPINPopupViewController, for username: String) {
        popup.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            let otp = OTPVerificationPopupViewController()
            otp.modalPresentationStyle = .overFullScreen
            otp.modalTransitionStyle = .crossDissolve
            otp.username = username
            otp.delegate = self
            self.present(otp, animated: true)
        }
    }
}

// MARK: - Forgot MPIN chain delegates
extension LoginViewController: OTPVerificationPopupDelegate, ResetMPINPopupDelegate, MPINResetSuccessPopupDelegate {
    
    // OTP
    func otpPopupDidCancel(_ popup: OTPVerificationPopupViewController) {
        popup.dismiss(animated: true)
    }
    
    func otpPopup(_ popup: OTPVerificationPopupViewController, didVerifyOTPFor username: String) {
        popup.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            let reset = ResetMPINPopupViewController()
            reset.modalPresentationStyle = .overFullScreen
            reset.modalTransitionStyle = .crossDissolve
            reset.username = username
            reset.delegate = self
            self.present(reset, animated: true)
        }
    }
    
    // Reset
    func resetMPINPopupDidCancel(_ popup: ResetMPINPopupViewController) {
        popup.dismiss(animated: true)
    }
    
    func resetMPINPopup(_ popup: ResetMPINPopupViewController, didSubmit newMPIN: String, for username: String) {
        // TODO wire backend when available. For now, show success popup.
        popup.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            let ok = MPINResetSuccessPopupViewController()
            ok.modalPresentationStyle = .overFullScreen
            ok.modalTransitionStyle = .crossDissolve
            ok.delegate = self
            self.present(ok, animated: true)
        }
    }
    
    // Success
    func mpinResetSuccessContinue(_ popup: MPINResetSuccessPopupViewController) {
        popup.dismiss(animated: true) {
            toast("MPIN reset. Please login with your new MPIN.")
        }
    }
}

// MARK: - Hex color util
private extension UIColor {
    convenience init(hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if h.hasPrefix("#") { h.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        self.init(red: CGFloat((rgb & 0xFF0000) >> 16)/255,
                  green: CGFloat((rgb & 0x00FF00) >> 8)/255,
                  blue: CGFloat(rgb & 0x0000FF)/255,
                  alpha: 1)
    }
}
