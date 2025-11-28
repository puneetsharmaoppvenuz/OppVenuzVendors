//
//  VendorAPI.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 10/11/25.
//
import Foundation

public enum VendorAPI {
    // All paths deduced from Postman collection
    case signup(
        email: String,
        password: String,
        name: String
    )
    case requestEmailOTP(
        email: String
    )
    case requestPhoneOTP(
        phone: String
    )
    case verifyEmailOTP(
        email: String,
        otp: String)
    case verifyPhoneOTP(
        phone: String,
        otp: String)
    case login(
        username: String,
        mpin: String
    )
    case uploadDocument(
        documentType: String,
        fileName: String,
        mime: String,
        data: Data,
        vendorBusinessNo: String,
        companyTypeId: Int
    )
    case completeSignup(body: FinalSignupRequest)
    case baseAPI // GET
}

public struct APIRequestFactory {
    
    public static func make(_ api: VendorAPI) throws -> URLRequest {
        AppConfig.configureFromPlist()
        
        switch api {
        case let .signup(email, password, name):
            let body = ["email": email, "password": password, "name": name]
            let data = try JSONSerialization.data(withJSONObject: body, options: [])
            return try RequestBuilder.make(base: AppConfig.apiRoot,
                                           path: "/vendor/signup/",
                                           method: .POST,
                                           headers: ["Accept":"application/json","Content-Type":"application/json"],
                                           body: data)
            
        case let .requestEmailOTP(email):
            let body = ["email": email]
            let data = try JSONSerialization.data(withJSONObject: body, options: [])
            return try RequestBuilder.make(base: AppConfig.apiRoot,
                                           path: "/vendor/requestEmail-otp/",
                                           method: .POST,
                                           headers: ["Accept":"application/json","Content-Type":"application/json"],
                                           body: data)
            
        case let .requestPhoneOTP(phone):
            let body = ["phone": phone]
            let data = try JSONSerialization.data(withJSONObject: body, options: [])
            return try RequestBuilder.make(base: AppConfig.apiRoot,
                                           path: "/vendor/requestPhone-otp/",
                                           method: .POST,
                                           headers: ["Accept":"application/json","Content-Type":"application/json"],
                                           body: data)
            
        case let .verifyEmailOTP(email, otp):
            let body = ["email": email, "otp": otp]
            let data = try JSONSerialization.data(withJSONObject: body, options: [])
            return try RequestBuilder.make(base: AppConfig.apiRoot,
                                           path: "/vendor/verifyEmail-otp/",
                                           method: .POST,
                                           headers: ["Accept":"application/json","Content-Type":"application/json"],
                                           body: data)
            
        case let .verifyPhoneOTP(phone, otp):
            let body = ["phone": phone, "otp": otp]
            let data = try JSONSerialization.data(withJSONObject: body, options: [])
            return try RequestBuilder.make(base: AppConfig.apiRoot,
                                           path: "/vendor/verifyPhone-otp/",
                                           method: .POST,
                                           headers: ["Accept":"application/json","Content-Type":"application/json"],
                                           body: data)
            
        case let .login(username, mpin):
            let body = ["username": username, "mpin": mpin]
            let data = try JSONSerialization.data(withJSONObject: body, options: [])
            return try RequestBuilder.make(base: AppConfig.apiRoot,
                                           path: "/vendor/login/",
                                           method: .POST,
                                           headers: ["Accept":"application/json","Content-Type":"application/json"],
                                           body: data)
            
        case let .uploadDocument(documentType, fileName, mime, data, vendorBusinessNo, companyTypeId):
            // Text fields
            let fields: [String:String] = [
                "document_type": documentType,
                "vendor_business_no": vendorBusinessNo,
                "company_type": String(companyTypeId)
            ]
            
            // File part
            let filePart = MultipartBody.File(
                filename: fileName,
                mime: mime,
                data: data,
                vendorBusinessNo: vendorBusinessNo,
                companyTypeId: companyTypeId
            )
            
            // NOTE: key is "file" to match Postman body
            let multi = MultipartBody(fields: fields, files: ["file": filePart])
            
            var req = try RequestBuilder.make(
                base: AppConfig.apiRoot,
                path: "/vendor/uploadDocument/",
                method: .POST,
                headers: ["Accept": "application/json"]
            )
            req.setValue(multi.contentType, forHTTPHeaderField: "Content-Type")
            req.httpBody = multi.data
            return req
            
        case let .completeSignup(body):
            let data = try JSONEncoder().encode(body)
            return try RequestBuilder.make(
                base: AppConfig.apiRoot,
                path: "/vendor/signup/",
                method: .POST,
                headers: ["Accept": "application/json", "Content-Type": "application/json"],
                body: data
            )
            
        case .baseAPI:
            var req = URLRequest(url: AppConfig.baseApiURL, timeoutInterval: 30)
            req.httpMethod = HTTPMethod.GET.rawValue
            req.addValue("application/json", forHTTPHeaderField: "Accept")
            return req
        }
    }
}

// MARK: - Loader policy
extension VendorAPI {
    var needsLoader: Bool {
        switch self {
        case .baseAPI: return false
        case .login: return true
        default:       return true
        }
    }
}
