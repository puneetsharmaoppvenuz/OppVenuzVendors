//
//  SignUpDraft.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 12/11/25.
//

import Foundation
import CoreLocation

public final class SignupDraft: Codable {
    // MARK: - Storage
    private static let storageKey = "SignupDraft.storage.v1"
    static let shared = SignupDraft()
    // MARK: - Screen 1 (contact)
    public var businessPhone: String?
    public var whatsappPhone: String?
    public var email: String?
    public var isBusinessPhoneVerified = false
    public var isWhatsappPhoneVerified = false
    public var isEmailVerified = false
    
    // MARK: - Screen 2 (mpin)
    public var mpin: String?
    
    // MARK: - Screen 3 (basic)
    public var firstName: String?
    public var middleName: String?
    public var lastName: String?
    public var businessName: String?
    /// "M" | "F" | "O"
    public var gender: String?
    /// ISO date string "YYYY-MM-DD" for server
    public var dobISO: String?
    public var categoryId: Int?
    public var bestSuitedIds: [Int] = []
    public var yearsOfExperience: String?
    public var workingSince: String?

    // MARK: - Screen 5 (location)
    public var stateId: Int?
    public var stateName: String?
    public var cityId: Int?
    public var cityName: String?
    public var addressLine: String?
    public var pincode: String?
    /// Store coordinates as Doubles (Codable-friendly)
    public var latitude: Double?
    public var longitude: Double?
    
    // MARK: - Screen 6 (documents)
    public struct UploadedDoc: Codable, Hashable {
        // Legacy fields used by upsertDocument(typeId:title:url:localFilename:)
        public var typeId: Int?
        public var title: String?
        public var url: String?
        public var localFilename: String?

        // New fields coming from uploadDocument response
        public var serverId: Int?
        public var phone: String?
        public var companyType: String?
        public var documentType: String?
        public var documentUrl: String?
        public var status: String?

        public init(typeId: Int? = nil,
                    title: String? = nil,
                    url: String? = nil,
                    localFilename: String? = nil,
                    serverId: Int? = nil,
                    phone: String? = nil,
                    companyType: String? = nil,
                    documentType: String? = nil,
                    documentUrl: String? = nil,
                    status: String? = nil) {
            self.typeId = typeId
            self.title = title
            self.url = url
            self.localFilename = localFilename
            self.serverId = serverId
            self.phone = phone
            self.companyType = companyType
            self.documentType = documentType
            self.documentUrl = documentUrl
            self.status = status
        }
    }

    public var uploadedDocuments: [UploadedDoc] = []
    public var companyTypeId: Int?
    
    // MARK: - Helpers
    
    @discardableResult
    public func set<T>(_ keyPath: ReferenceWritableKeyPath<SignupDraft, T>, _ value: T) -> Self {
        self[keyPath: keyPath] = value
        return self
    }
    
    public func setContact(businessPhone: String?,
                           altPhone: String?,
                           email: String?,
                           phoneVerified: Bool? = nil,
                           whatsappPhoneVerified: Bool? = nil,
                           emailVerified: Bool? = nil) {
        self.businessPhone = businessPhone
        self.whatsappPhone = altPhone
        self.email = email
        if let v = phoneVerified { self.isBusinessPhoneVerified = v }
        if let v = whatsappPhoneVerified { self.isWhatsappPhoneVerified = v }
        if let v = emailVerified { self.isEmailVerified = v }
    }
    
    public func setBasic(firstName: String?,
                         middleName: String?,
                         lastName: String?,
                         businessName: String?,
                         gender: String?,
                         dobISO: String?,
                         categoryId: Int?,
                         bestSuitedIds: [Int],
                         yearsOfExperience: String?) {
        self.firstName = firstName
        self.middleName = middleName
        self.lastName = lastName
        self.businessName = businessName
        self.gender = gender
        self.dobISO = dobISO
        self.categoryId = categoryId
        self.bestSuitedIds = bestSuitedIds
        self.yearsOfExperience = yearsOfExperience
    }
    
    public func setLocation(stateId: Int?,
                            stateName: String?,
                            cityId: Int?,
                            cityName: String?,
                            addressLine: String?,
                            pincode: String?,
                            latitude: Double?,
                            longitude: Double?) {
        self.stateId = stateId
        self.stateName = stateName
        self.cityId = cityId
        self.cityName = cityName
        self.addressLine = addressLine
        self.pincode = pincode
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public func upsertDocument(typeId: Int,
                               title: String,
                               url: String,
                               localFilename: String? = nil) {
        if let idx = uploadedDocuments.firstIndex(where: { $0.typeId == typeId }) {
            uploadedDocuments[idx] = UploadedDoc(typeId: typeId, title: title, url: url, localFilename: localFilename)
        } else {
            uploadedDocuments.append(UploadedDoc(typeId: typeId, title: title, url: url, localFilename: localFilename))
        }
    }
    
    // MARK: - Persistence
    
    public func save() {
        do {
            let data = try JSONEncoder().encode(self)
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        } catch {
#if DEBUG
            print("SignupDraft save failed: \(error)")
#endif
        }
    }
    
    public static func load() -> SignupDraft {
        guard let data = UserDefaults.standard.data(forKey: Self.storageKey) else {
            return SignupDraft()
        }
        do {
            return try JSONDecoder().decode(SignupDraft.self, from: data)
        } catch {
#if DEBUG
            print("SignupDraft restore failed: \(error)")
#endif
            return SignupDraft()
        }
    }
    
    public func clear() {
        UserDefaults.standard.removeObject(forKey: Self.storageKey)
    }
}
