//
//  SignupContactView.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 14/11/25.
//

import SwiftUI

// Simple helpers for Roboto font
enum RobotoFont {
    static func regular(_ size: CGFloat) -> Font {
        .custom("Roboto-Regular", size: size)
    }
    static func medium(_ size: CGFloat) -> Font {
        .custom("Roboto-Medium", size: size)
    }
    static func bold(_ size: CGFloat) -> Font {
        .custom("Roboto-Bold", size: size)
    }
}

struct SignupContactView: View {
    
    @StateObject private var viewModel = SignupContactViewModel()
    @Environment(\.dismiss) private var dismiss
    
    // Callback to push Basic Details (step 2)
    var onContinue: (() -> Void)? = nil

    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Illustration
                    Image("signup1") // or whatever you have; update asset name if needed
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 180)
                        .padding(.top, 8)
                    
                    // Title
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Create Your")
                            .font(RobotoFont.bold(28))
                        Text("Account")
                            .font(RobotoFont.bold(28))
                    }
                    
                    // Business mobile
                    contactSection(
                        title: "Enter Your Business Mobile Number",
                        placeholder: "Enter your Business Contact Number",
                        field: $viewModel.business.value,
                        isVerified: viewModel.business.isVerified,
                        kind: .business,
                        isValid: viewModel.isBusinessValid,
                        otpValue: $viewModel.business.otp,
                        isOTPSent: viewModel.business.isOTPSent,
                        isSending: viewModel.business.isSendingOTP,
                        isVerifying: viewModel.business.isVerifyingOTP,
                        countdown: viewModel.business.countdown
                    )
                    
                    // WhatsApp mobile
                    contactSection(
                        title: "Enter Your Whatsapp Mobile Number",
                        placeholder: "Enter your Whatsapp Mobile Number",
                        field: $viewModel.whatsapp.value,
                        isVerified: viewModel.whatsapp.isVerified,
                        kind: .whatsapp,
                        isValid: viewModel.isWhatsappValid,
                        otpValue: $viewModel.whatsapp.otp,
                        isOTPSent: viewModel.whatsapp.isOTPSent,
                        isSending: viewModel.whatsapp.isSendingOTP,
                        isVerifying: viewModel.whatsapp.isVerifyingOTP,
                        countdown: viewModel.whatsapp.countdown
                    )
                    
                    // Email
                    contactSection(
                        title: "Enter Your Mail ID",
                        placeholder: "Enter your Mail ID",
                        field: $viewModel.email.value,
                        isVerified: viewModel.email.isVerified,
                        kind: .email,
                        isValid: viewModel.isEmailValid,
                        otpValue: $viewModel.email.otp,
                        isOTPSent: viewModel.email.isOTPSent,
                        isSending: viewModel.email.isSendingOTP,
                        isVerifying: viewModel.email.isVerifyingOTP,
                        countdown: viewModel.email.countdown
                    )
                    
                    // Continue button + sign in
                    VStack(spacing: 16) {
                        Button {
                            onContinue?()
                        } label: {
                            Text("Continue")
                                .font(RobotoFont.medium(17))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .background(
                            viewModel.canContinue
                            ? LinearGradient(
                                colors: [Color(hex: "#5A69FC"), Color(hex: "#AF6AEF")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            : LinearGradient(
                                colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.5)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(
                            color: Color.black.opacity(viewModel.canContinue ? 0.1 : 0.0),
                            radius: 14, x: 0, y: 7
                        )
                        .disabled(!viewModel.canContinue)
                        
                        HStack(spacing: 4) {
                            Text("Already Have an Account")
                                .font(RobotoFont.regular(13))
                                .foregroundColor(.secondary)
                            Button {
                                dismiss()
                            } label: {
                                Text("Sign In")
                                    .font(RobotoFont.medium(13))
                                    .foregroundColor(Color(hex: "#5A69FC"))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.top, 16)
                    
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Section builder
    
    @ViewBuilder
    private func contactSection(
        title: String,
        placeholder: String,
        field: Binding<String>,
        isVerified: Bool,
        kind: SignupContactFieldKind,
        isValid: Bool,
        otpValue: Binding<String>,
        isOTPSent: Bool,
        isSending: Bool,
        isVerifying: Bool,
        countdown: Int
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(RobotoFont.medium(15))
            
            HStack(spacing: 8) {
                TextField(placeholder, text: field)
                    .font(RobotoFont.regular(14))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                // Disable while verified OR while sending OTP API
                    .disabled(isVerified || isSending)
                    .onChange(of: field.wrappedValue) { newValue in
                        var updated = newValue
                        
                        // For phone fields, keep only digits and limit to 10
                        switch kind {
                        case .business, .whatsapp:
                            let digits = newValue.filter(\.isNumber)
                            let limited = String(digits.prefix(10))
                            updated = limited
                        case .email:
                            break
                        }
                        
                        if updated != field.wrappedValue {
                            field.wrappedValue = updated
                        }
                        
                        // Reset OTP/resend/verified state if user edits after generating OTP
                        viewModel.didEditField(kind: kind)
                    }
                
                if isVerified {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.green)
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                }
            }
            
            // Generate / Resend OTP button (gradient)
            if !isVerified {
                let canTap = isValid && (!isOTPSent || countdown == 0)
                
                Button {
                    if isOTPSent && countdown == 0 {
                        viewModel.resendOTP(for: kind)
                    } else if !isOTPSent {
                        viewModel.sendOTP(for: kind)
                    }
                } label: {
                    HStack {
                        if isSending {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(buttonTitle(isOTPSent: isOTPSent, countdown: countdown))
                                .font(RobotoFont.medium(14))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                }
                .background(
                    canTap
                    ? LinearGradient(
                        colors: [Color(hex: "#5A69FC"), Color(hex: "#AF6AEF")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    : LinearGradient(
                        colors: [Color.gray.opacity(0.4), Color.gray.opacity(0.4)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(!canTap)
            }
            
            // OTP row
            if isOTPSent && !isVerified {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        TextField("Enter OTP", text: otpValue)
                            .keyboardType(.numberPad)
                            .font(RobotoFont.regular(14))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        
                        Button {
                            viewModel.verifyOTP(for: kind)
                        } label: {
                            HStack {
                                if isVerifying {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Verify")
                                        .font(RobotoFont.medium(14))
                                }
                            }
                            .frame(minWidth: 80)
                            .padding(.vertical, 9)
                        }
                        .background(Color(hex: "#28A745"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    if countdown > 0 {
                        Text("Resend OTP in 00:\(String(format: "%02d", countdown))")
                            .font(RobotoFont.regular(12))
                            .foregroundColor(.secondary)
                    }
                }
                .transition(.opacity)
            }
        }
    }
    
    private func buttonTitle(isOTPSent: Bool, countdown: Int) -> String {
        if !isOTPSent { return "Generate OTP" }
        if countdown > 0 { return "Resend OTP" }   // label, but disabled until countdown ends
        return "Resend OTP"
    }
}

// MARK: - Color hex helper

extension Color {
    init(hex: String) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch cleaned.count {
        case 3:
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}
