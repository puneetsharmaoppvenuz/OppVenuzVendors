//
//  AuthRequestDecorator.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 10/11/25.
//

import Foundation

public struct AuthRequestDecorator: RequestDecorator {
    
    public init() {}
    
    public func decorate(_ request: inout URLRequest) {
        
        guard let url = request.url else { return }
        
        // Normalize path: remove trailing slashes + ignore query params
        let cleanPath = url.path.lowercased()
        
        // APIs that must NEVER send token — full list
        let noAuthEndpoints: [String] = [
            "/vendor/login",
            "/vendor/signup",
            "/admin-master/baseapi",
            "/vendor/uploaddocument",
            "/vendor/auth/request-otp",
            "/vendor/requestPhone-otp",
            "/vendor/requestEmail-otp",
            "/vendor/auth/verify-otp",
            "/vendor/auth/request-email-otp",
            "/vendor/auth/verify-email-otp",
            "/vendor/verifyEmail-otp",
            "/vendor/verifyPhone-otp",
            "/vendor/auth/forgot-mpin",
            "/vendor/auth/verify-forgot-mpin",
            "/vendor/auth/reset-mpin"
        ]
       let noHeaders = noAuthEndpoints.map { $0.lowercased() }
        // If ANY endpoint matches prefix exactly, skip adding token
        if noHeaders.contains(where: { cleanPath.hasPrefix($0) }) {
            return
        }
        
        // Otherwise add token normally
        if let token = VendorSessionManager.shared.token,
           !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
}
