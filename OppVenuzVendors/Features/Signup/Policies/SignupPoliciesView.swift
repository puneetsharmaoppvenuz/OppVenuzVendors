//
//  pol.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 25/11/25.
//

import SwiftUI

struct SignupPoliciesView: View {
    
    @StateObject private var viewModel = SignupPoliciesViewModel()
    @Environment(\.dismiss) private var dismiss
    
    @State private var showErrorAlert: Bool = false
    
    /// Called after successful signup → LoginViewController handles navigation.
    var onContinue: (() -> Void)?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                header
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        titleBlock
                        policyList
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
                }
                
                continueButton
            }
            .background(Color(.systemBackground).ignoresSafeArea())
            
            if viewModel.isLoading {
                loaderOverlay
            }
        }
        .sheet(item: $viewModel.selectedItem) { item in
            policyDetailSheet(item)
        }
        .onChange(of: viewModel.errorMessage) { _, newValue in
            showErrorAlert = (newValue != nil)
        }
        .alert("Signup Failed", isPresented: $showErrorAlert, actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text(viewModel.errorMessage ?? "Something went wrong.")
        })
    }
    
    // MARK: - Header
    
    private var header: some View {
        ZStack(alignment: .leading) {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.22, green: 0.34, blue: 0.96),
                    Color(red: 0.52, green: 0.14, blue: 0.92)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 40)
            .ignoresSafeArea(edges: .top)
            
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.leading, 16)
            }
        }
    }
    
    // MARK: - Title
    
    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Review & Accept Policies")
                .font(.system(size: 18, weight: .semibold))
            
            Text("Please read and accept the following policies to complete your signup.")
                .font(.system(size: 13))
                .foregroundColor(.secondary)
        }
        .padding(.top, 16)
    }
    
    // MARK: - Policy List
    
    private var policyList: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(viewModel.items) { item in
                policyRow(item)
            }
        }
    }
    
    private func policyRow(_ item: SignupPoliciesViewModel.PolicyItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            
            HStack(spacing: 10) {
                
                Button {
                    viewModel.toggle(item)
                } label: {
                    Image(systemName: item.isChecked ? "checkmark.square.fill" : "square")
                        .font(.system(size: 20))
                        .foregroundColor(item.isChecked ? Color.blue : Color(.systemGray3))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.system(size: 14, weight: .semibold))
                    
                    Text("I have read and agree to this policy.")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button {
                    viewModel.openDetail(item)
                } label: {
                    Text("Read")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(8)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 1)
        )
    }
    
    // MARK: - Continue Button
    
    private var continueButton: some View {
        Button {
            
            Task {
                let ok = await viewModel.performSignup()
                
                if ok {
                    onContinue?()
                }
            }
            
        } label: {
            Text(viewModel.isLoading ? "Processing..." : "Continue")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors:
                                            viewModel.isContinueEnabled && !viewModel.isLoading
                                           ? [Color.blue, Color.purple]
                                           : [Color.gray, Color.gray]
                                          ),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
        .disabled(!viewModel.isContinueEnabled || viewModel.isLoading)
    }
    
    // MARK: - Loader Overlay
    
    private var loaderOverlay: some View {
        ZStack {
            Color.black.opacity(0.25).ignoresSafeArea()
            ProgressView()
                .scaleEffect(1.4)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                )
        }
    }
    
    // MARK: - Detail Sheet
    
    @ViewBuilder
    private func policyDetailSheet(_ item: SignupPoliciesViewModel.PolicyItem) -> some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(item.title)
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text(item.content)
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                }
                .padding(20)
            }
            .navigationTitle(item.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        viewModel.closeDetail()
                    }
                }
            }
        }
    }
}
