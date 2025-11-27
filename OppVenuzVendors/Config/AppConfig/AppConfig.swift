//
//  AppConfig.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 10/11/25.
//

import Foundation

public enum AppConfig {
    // Primary API root, e.g. https://oppvenuz-backend.onrender.com
    public static var apiRoot: URL = URL(string: "https://oppvenuz-backend-new.onrender.com")!

    // Base API (special config endpoint) full URL if backend demands exact path
    public static var baseApiURL: URL = URL(string: "https://oppvenuz-backend-new.onrender.com/admin-master/baseApi/")!
    
    public static func configureFromPlist() {
        let bundle = Bundle.main
        if let root = bundle.object(forInfoDictionaryKey: "BASE_URL") as? String,
           let url = URL(string: root), !root.isEmpty {
            // If user provided a full path ending with /admin-master/baseApi/ we still keep apiRoot as host root
            if url.path.contains("/admin-master/baseApi") {
                // Derive the host root
                if let hostRoot = URL(string: url.scheme! + "://" + (url.host ?? "") ) {
                    apiRoot = hostRoot
                }
                baseApiURL = url
            } else {
                apiRoot = url
                // derive default baseApiURL
                baseApiURL = url.appendingPathComponent("admin-master/baseApi/")
            }
        }
        if let baseApi = bundle.object(forInfoDictionaryKey: "BASE_API_URL") as? String,
           let url = URL(string: baseApi), !baseApi.isEmpty {
            baseApiURL = url
        }
    }
}
