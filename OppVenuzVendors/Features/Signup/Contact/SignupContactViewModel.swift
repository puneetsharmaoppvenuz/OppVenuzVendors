//
//  SignupContactViewModel.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 14/11/25.
//

import Combine
import SwiftUI
import Foundation

// MARK: - Field Kind

enum SignupContactFieldKind {
    case business
    case whatsapp
    case email
}

// MARK: - State per field

struct SignupContactFieldState {
    var value: String = ""
    var otp: String = ""
    var isOTPSent: Bool = false
    var isVerified: Bool = false
    var isSendingOTP: Bool = false
    var isVerifyingOTP: Bool = false
    var countdown: Int = 0        // 0 means no active countdown
    
    /// Last value for which OTP was actually requested from backend.
    /// Used so that if user changes away and comes back to same value,
    /// we can reuse existing OTP without calling API again.
    var lastOTPValue: String? = nil
    
    var canResend: Bool {
        isOTPSent && countdown == 0 && !isVerified
    }
}

// MARK: - Service protocol

protocol SignupContactServicing {
    func requestOTP(kind: SignupContactFieldKind,
                    value: String) async throws -> OTPMessageResponse
    func verifyOTP(kind: SignupContactFieldKind,
                   value: String,
                   otp: String) async throws -> OTPMessageResponse
}

// MARK: - Default service using VendorAPI + NetworkManager

struct DefaultSignupContactService: SignupContactServicing {
    
    func requestOTP(kind: SignupContactFieldKind,
                    value: String) async throws -> OTPMessageResponse {
        let api: VendorAPI
        switch kind {
        case .business, .whatsapp:
            api = .requestPhoneOTP(phone: value)
        case .email:
            api = .requestEmailOTP(email: value)
        }
        
        let response: OTPMessageResponse = try await NetworkManager.shared
            .requestJSON(api, decode: OTPMessageResponse.self)
        return response
    }
    
    func verifyOTP(kind: SignupContactFieldKind,
                   value: String,
                   otp: String) async throws -> OTPMessageResponse {
        let api: VendorAPI
        switch kind {
        case .business, .whatsapp:
            api = .verifyPhoneOTP(phone: value, otp: otp)
        case .email:
            api = .verifyEmailOTP(email: value, otp: otp)
        }
        
        let response: OTPMessageResponse = try await NetworkManager.shared
            .requestJSON(api, decode: OTPMessageResponse.self)
        return response
    }
}

// MARK: - Main ViewModel

@MainActor
final class SignupContactViewModel: ObservableObject {
    
    // MARK: - Published fields
    
    @Published var business = SignupContactFieldState()
    @Published var whatsapp = SignupContactFieldState()
    @Published var email    = SignupContactFieldState()
    
    // MARK: - Derived validity
    
    var isBusinessValid: Bool {
        business.value.trimmed.isValidPhone
    }
    
    var isWhatsappValid: Bool {
        whatsapp.value.trimmed.isValidPhone
    }
    
    var isEmailValid: Bool {
        email.value.trimmed.isValidEmail
    }
    
    var canContinue: Bool {
        business.isVerified && whatsapp.isVerified && email.isVerified
    }
    
    // MARK: - Timer
    
    private var timer: Timer?
    
    // MARK: - Service
    
    private let service: SignupContactServicing
    
    // MARK: - Init
    
    init(service: SignupContactServicing = DefaultSignupContactService()) {
        self.service = service
        
        // Pre-fill from SignupDraft (same behaviour as old UIKit VC)
        let draft = SignupDraft.shared
        business.value = draft.businessPhone ?? ""
        whatsapp.value = draft.whatsappPhone ?? ""
        email.value = draft.email ?? ""
        business.isVerified = draft.isBusinessPhoneVerified
        whatsapp.isVerified = draft.isWhatsappPhoneVerified
        email.isVerified = draft.isEmailVerified
        
        // If already verified in draft, treat those as having had OTP at least once.
        if let phone = draft.businessPhone, !phone.isEmpty {
            business.lastOTPValue = phone
        }
        if let alt = draft.whatsappPhone, !alt.isEmpty {
            whatsapp.lastOTPValue = alt
        }
        if let mail = draft.email, !mail.isEmpty {
            email.lastOTPValue = mail
        }
    }
    
    // MARK: - Public API for View
    
    func sendOTP(for kind: SignupContactFieldKind) {
        switch kind {
        case .business:
            guard isBusinessValid else {
                showToast("Enter a valid business mobile number.")
                return
            }
        case .whatsapp:
            guard isWhatsappValid else {
                showToast("Enter a valid WhatsApp mobile number.")
                return
            }
        case .email:
            guard isEmailValid else {
                showToast("Enter a valid email address.")
                return
            }
        }
        
        let currentValue = value(for: kind)
        
        // ⚠️ Important condition you requested:
        // If user had already requested OTP for this SAME value earlier,
        // and the field is not verified yet, we do NOT call API again.
        // We just re-open the OTP UI locally.
        if let last = lastOTPValue(for: kind),
           last == currentValue,
           !isVerified(kind: kind) {
            restoreExistingOTPUI(for: kind)
            showToast("An OTP was already sent for this. Please enter it to verify.")
            return
        }
        
        setSending(true, for: kind)
        
        Task {
            do {
                let resp = try await service.requestOTP(kind: kind, value: currentValue)
                
                if resp.isSendSuccess(for: kind) {
                    // Only start countdown if backend actually accepted the request
                    markOTPSent(for: kind)
                    setLastOTPValue(currentValue, for: kind)
                }
                
                showToast(resp.bestMessage)
            } catch {
                showToast(error.bestSignupMessage)
            }
            setSending(false, for: kind)
        }
    }
    
    func verifyOTP(for kind: SignupContactFieldKind) {
        let otp = otpFor(kind).trimmed
        guard otp.count >= 4 else {
            showToast("Enter the OTP.")
            return
        }
        
        let currentValue = value(for: kind)
        
        switch kind {
        case .business:
            guard isBusinessValid else {
                showToast("Enter a valid business mobile number.")
                return
            }
        case .whatsapp:
            guard isWhatsappValid else {
                showToast("Enter a valid WhatsApp mobile number.")
                return
            }
        case .email:
            guard isEmailValid else {
                showToast("Enter a valid email address.")
                return
            }
        }
        
        setVerifying(true, for: kind)
        
        Task {
            do {
                let resp = try await service.verifyOTP(kind: kind, value: currentValue, otp: otp)
                
                if resp.isVerifySuccess(for: kind) {
                    // Lock field, hide OTP, update draft on real verification
                    markVerified(for: kind)
                    setLastOTPValue(currentValue, for: kind)
                    saveDraftContact()
                }
                
                showToast(resp.bestMessage)
            } catch {
                showToast(error.bestSignupMessage)
            }
            setVerifying(false, for: kind)
        }
    }
    
    func resendOTP(for kind: SignupContactFieldKind) {
        // Button is disabled by view until countdown == 0, so this is safe.
        sendOTP(for: kind)
    }
    
    /// Called when the user edits the text field value.
    /// If they already had OTP or verification, we reset runtime state
    /// so they can generate a fresh OTP for new value.
    /// NOTE: We do NOT clear lastOTPValue here, so if user comes back
    /// to same value later, we still know we already requested OTP once.
    func didEditField(kind: SignupContactFieldKind) {
        switch kind {
        case .business:
            if business.isOTPSent || business.isVerified {
                business.isOTPSent = false
                business.isVerified = false
                business.countdown = 0
                business.otp = ""
            }
        case .whatsapp:
            if whatsapp.isOTPSent || whatsapp.isVerified {
                whatsapp.isOTPSent = false
                whatsapp.isVerified = false
                whatsapp.countdown = 0
                whatsapp.otp = ""
            }
        case .email:
            if email.isOTPSent || email.isVerified {
                email.isOTPSent = false
                email.isVerified = false
                email.countdown = 0
                email.otp = ""
            }
        }
        stopTimerIfDone()
    }
    
    // MARK: - Countdown management
    
    private func markOTPSent(for kind: SignupContactFieldKind) {
        switch kind {
        case .business:
            business.isOTPSent = true
            business.countdown = 60
        case .whatsapp:
            whatsapp.isOTPSent = true
            whatsapp.countdown = 60
        case .email:
            email.isOTPSent = true
            email.countdown = 60
        }
        startTimerIfNeeded()
    }
    
    private func markVerified(for kind: SignupContactFieldKind) {
        switch kind {
        case .business:
            business.isVerified = true
            business.otp = ""
            business.countdown = 0
        case .whatsapp:
            whatsapp.isVerified = true
            whatsapp.otp = ""
            whatsapp.countdown = 0
        case .email:
            email.isVerified = true
            email.otp = ""
            email.countdown = 0
        }
        stopTimerIfDone()
    }
    
    /// Restores OTP UI for an already-requested value without calling API again.
    /// We show OTP field again, but no timer; user can enter existing OTP or tap Resend.
    private func restoreExistingOTPUI(for kind: SignupContactFieldKind) {
        switch kind {
        case .business:
            business.isOTPSent = true
            business.countdown = 0
        case .whatsapp:
            whatsapp.isOTPSent = true
            whatsapp.countdown = 0
        case .email:
            email.isOTPSent = true
            email.countdown = 0
        }
        stopTimerIfDone()
    }
    
    private func startTimerIfNeeded() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }
    
    private func stopTimerIfDone() {
        guard business.countdown <= 0,
              whatsapp.countdown <= 0,
              email.countdown <= 0 else { return }
        timer?.invalidate()
        timer = nil
    }
    
    private func tick() {
        var anyActive = false
        
        if business.countdown > 0 {
            business.countdown -= 1
            anyActive = true
        }
        if whatsapp.countdown > 0 {
            whatsapp.countdown -= 1
            anyActive = true
        }
        if email.countdown > 0 {
            email.countdown -= 1
            anyActive = true
        }
        
        if !anyActive {
            stopTimerIfDone()
        }
    }
    
    // MARK: - Draft
    
    private func saveDraftContact() {
        SignupDraft.shared.setContact(
            businessPhone: business.value.trimmed,
            altPhone: whatsapp.value.trimmed,
            email: email.value.trimmed,
            phoneVerified: business.isVerified,
            whatsappPhoneVerified: whatsapp.isVerified,
            emailVerified: email.isVerified
        )
    }
    
    // MARK: - Helpers
    
    private func value(for kind: SignupContactFieldKind) -> String {
        switch kind {
        case .business: return business.value.trimmed
        case .whatsapp: return whatsapp.value.trimmed
        case .email:    return email.value.trimmed
        }
    }
    
    private func otpFor(_ kind: SignupContactFieldKind) -> String {
        switch kind {
        case .business: return business.otp
        case .whatsapp: return whatsapp.otp
        case .email:    return email.otp
        }
    }
    
    private func lastOTPValue(for kind: SignupContactFieldKind) -> String? {
        switch kind {
        case .business: return business.lastOTPValue
        case .whatsapp: return whatsapp.lastOTPValue
        case .email:    return email.lastOTPValue
        }
    }
    
    private func setLastOTPValue(_ value: String, for kind: SignupContactFieldKind) {
        switch kind {
        case .business:
            business.lastOTPValue = value
        case .whatsapp:
            whatsapp.lastOTPValue = value
        case .email:
            email.lastOTPValue = value
        }
    }
    
    private func isVerified(kind: SignupContactFieldKind) -> Bool {
        switch kind {
        case .business: return business.isVerified
        case .whatsapp: return whatsapp.isVerified
        case .email:    return email.isVerified
        }
    }
    
    private func setSending(_ sending: Bool, for kind: SignupContactFieldKind) {
        switch kind {
        case .business: business.isSendingOTP = sending
        case .whatsapp: whatsapp.isSendingOTP = sending
        case .email:    email.isSendingOTP = sending
        }
    }
    
    private func setVerifying(_ verifying: Bool, for kind: SignupContactFieldKind) {
        switch kind {
        case .business: business.isVerifyingOTP = verifying
        case .whatsapp: whatsapp.isVerifyingOTP = verifying
        case .email:    email.isVerifyingOTP = verifying
        }
    }
    
    private func showToast(_ message: String) {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        toast(trimmed)
    }
}

// MARK: - OTP API response + helpers

/// Response used by all OTP APIs:
/// - Send OTP (phone/email)
/// - Verify OTP (phone/email)
///
/// Examples from backend:
/// { "status": true, "message": "OTP sent successfully.", "email_sent": true }
/// { "status": true, "message": "Email Verified successfully.", "is_email_verified": true }
/// { "status": true, "message": "Phone verified successfully.", "is_phone_verified": true }
/// { "status": false, "message": "Invalid or expired OTP." }
struct OTPMessageResponse: Decodable {
    let status: Bool?
    let message: String?
    
    // Only present on "send email OTP"
    let emailSent: Bool?
    
    // Present on verify calls
    let isEmailVerified: Bool?
    let isPhoneVerified: Bool?
    
    enum CodingKeys: String, CodingKey {
        case status
        case message
        case emailSent       = "email_sent"
        case isEmailVerified = "is_email_verified"
        case isPhoneVerified = "is_phone_verified"
    }
    
    /// Generic text to show in toast.
    var bestMessage: String {
        if let m = message, !m.isEmpty { return m }
        return (status ?? false) ? "Request completed." : "Something went wrong."
    }
    
    /// Whether "send OTP" should be treated as success for this field.
    func isSendSuccess(for kind: SignupContactFieldKind) -> Bool {
        switch kind {
        case .email:
            if let emailSent { return emailSent }
            return status ?? false
        case .business, .whatsapp:
            return status ?? false
        }
    }
    
    /// Whether "verify OTP" should be treated as success for this field.
    func isVerifySuccess(for kind: SignupContactFieldKind) -> Bool {
        switch kind {
        case .email:
            if let isEmailVerified { return isEmailVerified }
            return status ?? false
        case .business, .whatsapp:
            if let isPhoneVerified { return isPhoneVerified }
            return status ?? false
        }
    }
}

// MARK: - Local validation helpers

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isValidEmail: Bool {
        let p = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return range(of: p, options: [.regularExpression, .caseInsensitive]) != nil
    }
    
    var isValidPhone: Bool {
        let digits = filter(\.isNumber)
        // Exactly 10 digits, not less or more
        return digits.count == 10
    }
}

private extension Error {
    var bestSignupMessage: String {
        if let n = self as? NetworkError {
            switch n {
            case .status(_, let msg):
                return msg
            default:
                return n.description
            }
        }
        return localizedDescription
    }
}
