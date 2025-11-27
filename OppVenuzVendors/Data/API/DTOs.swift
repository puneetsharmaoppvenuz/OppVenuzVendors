//
//  DTO's.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 10/11/25.
//

import Foundation

public struct AuthResponse: Decodable {
    public let token: String?
    public let message: String?
}

public struct BaseAPIResponse: Decodable {
    public let status: String?
    public let data: [String: String]?
}

struct APIErrorEnvelope: Decodable {
    let status: Bool?
    let message: String?
    let errors: [String: [String]]?
    
    var bestMessage: String? {
        if let m = message, !m.isEmpty { return m }
        if let nonField = errors?["non_field_errors"]?.first, !nonField.isEmpty { return nonField }
        if let any = errors?.first?.value.first, !any.isEmpty { return any }
        return nil
    }
    
    static func decode(from data: Data?) -> APIErrorEnvelope? {
        guard let data else { return nil }
        return try? JSONDecoder().decode(APIErrorEnvelope.self, from: data)
    }
}

// MARK: - Signup response
public struct VendorProfile: Codable {
    public let vendor_id: String?
    public let business_name: String?
    public let first_name: String?
    public let middle_name: String?
    public let last_name: String?
    public let email: String?
    public let contact_no: String?
    public let whatsapp_no: String?
    public let gender: String?
    public let date_of_birth: String?
    public let city: String?
    public let state: String?
    public let pincode: String?
    public let address: String?
    public let service_name: String?
    public let best_suited_for: String?
    public let working_since: String?
    public let year_of_experience: Int?
    public let payment_status: String?
    public let profile_status: String?
    public let access: String?
    public let refresh: String?
}

public struct SignupResponseEnvelope: Decodable {
    public let status: Bool?
    public let message: String?
    public let data: VendorProfile?
}
