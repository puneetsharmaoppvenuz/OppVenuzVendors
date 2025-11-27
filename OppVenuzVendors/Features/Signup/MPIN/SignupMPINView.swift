//
//  SignupMPINView.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 14/11/25.

import SwiftUI

struct SignupMPINView: View {
    
    @StateObject private var viewModel = SignupMPINViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var onContinue: (() -> Void)? = nil
    
    @FocusState private var isMPINFocused: Bool
    @FocusState private var isConfirmFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                
                Spacer().frame(height: 40)
                
                Text("Set your MPIN")
                    .font(RobotoFont.bold(22))
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("Enter a 6-digit MPIN to protect your account")
                    .font(RobotoFont.regular(14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                VStack(alignment: .leading, spacing: 24) {
                    
                    // MARK: Enter MPIN
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Enter MPIN")
                            .font(RobotoFont.medium(15))
                        
                        pinInputRow(
                            text: viewModel.mpin,
                            isFocused: isMPINFocused
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isMPINFocused = true
                        }
                        .overlay(
                            TextField("",
                                      text: Binding(
                                        get: { viewModel.mpin },
                                        set: { viewModel.updateMPIN($0) }
                                      )
                                     )
                            .keyboardType(.numberPad)
                            .textContentType(.oneTimeCode)
                            .font(RobotoFont.regular(0.1))   // invisible text
                                .foregroundColor(.clear)
                                .tint(.clear)                    // hide system caret
                                .textFieldStyle(.plain)
                                .multilineTextAlignment(.center)
                                .focused($isMPINFocused)
                                .labelsHidden()
                                .accessibilityHidden(true)
                        )
                    }
                    
                    // MARK: Confirm MPIN
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Confirm MPIN")
                            .font(RobotoFont.medium(15))
                        
                        pinInputRow(
                            text: viewModel.confirmMPIN,
                            isFocused: isConfirmFocused
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isConfirmFocused = true
                        }
                        .overlay(
                            TextField("",
                                      text: Binding(
                                        get: { viewModel.confirmMPIN },
                                        set: { viewModel.updateConfirmMPIN($0) }
                                      )
                                     )
                            .keyboardType(.numberPad)
                            .textContentType(.oneTimeCode)
                            .font(RobotoFont.regular(0.1))
                            .foregroundColor(.clear)
                            .tint(.clear)
                            .textFieldStyle(.plain)
                            .multilineTextAlignment(.center)
                            .focused($isConfirmFocused)
                            .labelsHidden()
                            .accessibilityHidden(true)
                        )
                        
                        // 🔴 Inline error when both filled & mismatch
                        if viewModel.confirmMPIN.count == 6,
                           viewModel.mpin.count == 6,
                           viewModel.confirmMPIN != viewModel.mpin {
                            Text("MPIN does not match")
                                .font(RobotoFont.regular(12))
                                .foregroundColor(.red)
                        }
                    }
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                Button {
                    viewModel.saveDraft()
                    onContinue?()
                } label: {
                    Text("Proceed")
                        .font(RobotoFont.medium(17))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .background(
                    viewModel.isValid
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
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
                .disabled(!viewModel.isValid)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - PIN row (6 boxes)
    
    private func pinInputRow(text: String, isFocused: Bool) -> some View {
        HStack(spacing: 12) {
            ForEach(0..<6, id: \.self) { index in
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        .frame(width: 40, height: 40)
                    
                    if index < text.count {
                        Circle()
                            .fill(Color.black)
                            .frame(width: 10, height: 10)
                    } else if index == text.count && isFocused {
                        Rectangle()
                            .fill(Color.black.opacity(0.8))
                            .frame(width: 2, height: 20)
                    }
                }
            }
        }
    }
}

// Draft for MPIN (unchanged)
final class SignupMPINDraft {
    static let shared = SignupMPINDraft()
    var mpin: String = ""
}
