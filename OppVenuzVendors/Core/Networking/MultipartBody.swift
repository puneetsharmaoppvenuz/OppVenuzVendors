//
//  MultipartBody.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 10/11/25.
//

import Foundation

public struct MultipartBody {
    public let data: Data
    public let contentType: String
    
    public init(fields: [String:String], files: [String:File]) {
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
        func append(_ string: String) {
            body.append(string.data(using: .utf8)!)
        }
        
        for (k,v) in fields {
            append("--\(boundary)\r\n")
            append("Content-Disposition: form-data; name=\"\(k)\"\r\n\r\n")
            append("\(v)\r\n")
        }
        
        for (name, file) in files {
            append("--\(boundary)\r\n")
            append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(file.filename)\"\r\n")
            append("Content-Type: \(file.mime)\r\n\r\n")
            body.append(file.data)
            append("\r\n")
        }
        
        append("--\(boundary)--\r\n")
        
        self.data = body
        self.contentType = "multipart/form-data; boundary=\(boundary)"
    }
    
    public struct File {
        public let filename: String
        public let mime: String
        public let data: Data
        public let vendorBusinessNo: String
        public let companyTypeId: Int
        public init(filename: String, mime: String, data: Data, vendorBusinessNo: String, companyTypeId: Int) {
            self.filename = filename; self.mime = mime; self.data = data; self.vendorBusinessNo = vendorBusinessNo; self.companyTypeId = companyTypeId
        }
    }
}
