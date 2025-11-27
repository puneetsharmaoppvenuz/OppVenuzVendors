//
//  BaseAPIModel.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 10/11/25.
//

import Foundation

// Top-level
public struct BaseAPIEnvelope: Codable {
    public let status: Bool
    public let message: String?
    public let data: BaseAPIData?
}

// Payload
public struct BaseAPIData: Codable {
    public let appVersion: [AppVersion]?
    public let states: [StateItem]?
    public let categories: [CategoryItem]?
    public let company_type_documents: [CompanyTypeDoc]?
    public let gst: [GSTItem]?
    public let best_suited_for: [BestSuitedItem]?
    public let terms_and_conditions: [TermsItem]?
    public let onboarding: OnboardingBlock?
}

// Sub-objects (only the fields we need now)
public struct AppVersion: Codable {
    public let id: Int
    public let app_version: String
    public let is_force_update: Bool
    public let status: Int
}

public struct StateItem: Codable {
    public let id: Int
    public let state_name: String
    public let state_code: Int
    public let status: Int
    public let cities: [CityItem]?
}
public struct CityItem: Codable {
    public let id: Int
    public let city_name: String
    public let status: Int
    public let latitude: Double
    public let longitude: Double
}

public struct CategoryItem: Codable {
    public let id: Int
    public let service_name: String
    public let registration_charges: String
    public let status: Int
}

public struct CompanyTypeDoc: Codable {
    public let id: Int
    public let company_type: String
    public let documents: [DocItem]?
}
public struct DocItem: Codable {
    public let id: Int
    public let document_type: String
}

public struct GSTItem: Codable {
    public let id: Int
    public let gst_percentage: String
    public let status: String
}

public struct BestSuitedItem: Codable {
    public let id: Int
    public let name: String
    public let status: Int
}

public struct TermsItem: Codable {
    public let id: Int
    public let title: String
    public let content: String
    public let slug: String
    public let status: Int
}

public struct OnboardingBlock: Codable {
    public let gif: OnboardingGIF?
    public let flash_screens: [OnboardingImage]?
}
public struct OnboardingGIF: Codable {
    public let id: Int
    public let title: String
    public let media: MediaContainer
    public let type: Int
    public let order: Int
    public let status: Int
}
public struct OnboardingImage: Codable {
    public let id: Int
    public let title: String
    public let media: MediaContainer
    public let type: Int
    public let order: Int
    public let status: Int
}
public struct MediaContainer: Codable {
    public let image: String
}
