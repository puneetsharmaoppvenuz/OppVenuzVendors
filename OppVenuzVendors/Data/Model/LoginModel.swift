//
//  LoginModel.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 28/11/25.
//
import Foundation

// MARK: - Login response models

 struct AuthResponseEnvelope: Decodable {
    let status: Bool?
    let message: String?
    let data: AuthData?
}

 struct AuthData: Decodable {
    let vendorID: String?
    let businessName: String?
    let firstName: String?
    let lastName: String?
    let email: String?
    let contactNo: String?
    let gender: String?
    let dateOfBirth: String?
    let city: String?
    let state: String?
    let pincode: String?
    let address: String?
    let serviceName: String?
    let bestSuitedFor: String?
    let workingSince: String?
    let yearOfExperience: Int?
    let referralCode: String?
    let createdAt: String?
    let paymentStatus: String?
    let profileStatus: String?
    let profileImage: String?
    let documents: [AuthDocument]?
    let access: String?
    let refresh: String?
    let deviceInfo: AuthDeviceInfo?

    var token: String? { access }

    enum CodingKeys: String, CodingKey {
        case vendorID         = "vendor_id"
        case businessName     = "business_name"
        case firstName        = "first_name"
        case lastName         = "last_name"
        case email
        case contactNo        = "contact_no"
        case gender
        case dateOfBirth      = "date_of_birth"
        case city
        case state
        case pincode
        case address
        case serviceName      = "service_name"
        case bestSuitedFor    = "best_suited_for"
        case workingSince     = "working_since"
        case yearOfExperience = "year_of_experience"
        case referralCode     = "referral_code"
        case createdAt        = "created_at"
        case paymentStatus    = "payment_status"
        case profileStatus    = "profile_status"
        case profileImage     = "profile_image"
        case documents
        case access
        case refresh
        case deviceInfo       = "device_info"
    }
}

 struct AuthDocument: Decodable {
    let id: Int?
    let phone: String?
    let companyType: String?
    let documentType: String?
    let documentURL: String?
    let status: String?

    enum CodingKeys: String, CodingKey {
        case id
        case phone
        case companyType  = "company_type"
        case documentType = "document_type"
        case documentURL  = "document_url"
        case status
    }
}

 struct AuthDeviceInfo: Decodable {
    let deviceType: String?
    let osVersion: String?
    let browserName: String?
    let browserVersion: String?
    let osType: String?

    enum CodingKeys: String, CodingKey {
        case deviceType      = "device_type"
        case osVersion       = "os_version"
        case browserName     = "browser_name"
        case browserVersion  = "browser_version"
        case osType          = "os_type"
    }
}
