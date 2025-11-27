//
//  FinalRequest.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 25/11/25.
//

import Foundation

public struct FinalSignupRequest: Encodable {

    public struct Location: Encodable {
        public let pincode: String?
        public let address: String?
        public let latitude: String?
        public let longitude: String?
    }

    public struct Document: Encodable {
        public let vendor_business_no: String
        public let document_type: String
        public let document_url: String
        public let status: String
    }

    public let first_name: String
    public let middle_name: String?
    public let last_name: String
    public let email: String
    public let contact_no: String
    public let whatsapp_no: String?
    public let gender: String?
    public let date_of_birth: String?
    public let mpin: String

    public let business_name: String?
    public let service_id: Int?
    public let best_suited: Int?
    public let city_id: Int?
    public let state_id: Int?

    public let location: Location?

    public let working_since: String?
    public let year_of_experience: Int?

    public let documents: [Document]

    public let payment_status: String
    public let Profile_status: String
}

// MARK: - Build from SignupDraft
public extension FinalSignupRequest {

    static func fromDraft(_ d: SignupDraft) -> FinalSignupRequest {

        let docs: [Document] = d.uploadedDocuments.map {
            Document(
                vendor_business_no: d.businessPhone ?? "",
                document_type: $0.documentType ?? "",
                document_url: $0.documentUrl ?? "",
                status: $0.status ?? "TEMP"
            )
        }

        let latString = d.latitude.map { String(format: "%.6f", $0) }
        let lonString = d.longitude.map { String(format: "%.6f", $0) }

        let loc = Location(
            pincode: d.pincode,
            address: d.addressLine,
            latitude: latString,
            longitude: lonString
        )

        return FinalSignupRequest(
            first_name: d.firstName ?? "",
            middle_name: d.middleName,
            last_name: d.lastName ?? "",
            email: d.email ?? "",
            contact_no: d.businessPhone ?? "",
            whatsapp_no: d.whatsappPhone,
            gender: d.gender,
            date_of_birth: d.dobISO,
            mpin: d.mpin ?? "",

            business_name: d.businessName,
            service_id: d.categoryId,
            best_suited: d.bestSuitedIds.first,
            city_id: d.cityId,
            state_id: d.stateId,
            location: loc,

            working_since: d.workingSince,
            year_of_experience: Int(d.yearsOfExperience ?? "0"),

            documents: docs,
            payment_status: "PENDING",
            Profile_status: "PENDING"
        )
    }
}
