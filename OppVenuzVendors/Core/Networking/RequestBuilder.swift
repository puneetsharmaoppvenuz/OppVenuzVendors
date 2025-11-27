//
//  RequestBuilder.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 10/11/25.
//

import Foundation

public struct RequestBuilder {
    public static func make(
        base: URL,
        path: String,
        method: HTTPMethod,
        headers: [String:String]? = nil,
        query: [URLQueryItem]? = nil,
        body: Data? = nil,
        timeout: TimeInterval = 30
    ) throws -> URLRequest {
        guard var comp = URLComponents(url: base.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            throw NetworkError.badURL
        }
        if let query = query, !query.isEmpty { comp.queryItems = query }
        guard let url = comp.url else { throw NetworkError.badURL }

        var req = URLRequest(url: url, timeoutInterval: timeout)
        req.httpMethod = method.rawValue
        headers?.forEach { req.addValue($0.value, forHTTPHeaderField: $0.key) }
        req.httpBody = body
        return req
    }
}
