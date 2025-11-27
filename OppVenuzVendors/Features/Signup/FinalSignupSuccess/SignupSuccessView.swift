//
//  Success.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 25/11/25.
//

import SwiftUI

struct SignupSuccessView: View {
    
    var onContinue: (() -> Void)?
    
    var body: some View {
        ZStack {
            Color(red: 0.93, green: 0.94, blue: 1.0)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.15))
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .fill(Color.green)
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Text("All Business Details\nSubmitted")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 20, weight: .semibold))
                    
                    Text("Thanks! Your business details have been submitted successfully. Our team is reviewing it and your status will be updated within 48 hours.")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                )
                .padding(.horizontal, 24)
                
                Spacer()
                
                Button {
                    onContinue?()
                } label: {
                    Text("Continue to Home Page")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 32)
                }
            }
        }
    }
}
