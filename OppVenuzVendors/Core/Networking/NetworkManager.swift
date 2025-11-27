//
//  NetworkManager.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 10/11/25.
//

import Foundation
import UIKit

public final class NetworkManager {

    // MARK: - Singleton
    public static let shared = NetworkManager()

    // MARK: - Decorators
    // Runs in order; AuthRequestDecorator adds Bearer token if available.
    private var decorators: [RequestDecorator] = [AuthRequestDecorator()]

    // MARK: - URLSession
    private let session: URLSession = {
        let cfg = URLSessionConfiguration.default
        cfg.waitsForConnectivity = true
        cfg.timeoutIntervalForRequest = 30
        cfg.timeoutIntervalForResource = 60
        // Add more defaults here if needed (e.g., httpAdditionalHeaders)
        return URLSession(configuration: cfg)
    }()

    private init() {}

    // MARK: - Public API

    /// Adds a custom request decorator (e.g., locale header).
    public func addDecorator(_ decorator: RequestDecorator) {
        decorators.append(decorator)
    }

    /// Perform a request expecting a JSON payload.
    /// - Parameters:
    ///   - req: Prepared URLRequest (use your RequestBuilder/APIRequestFactory).
    ///   - decode: Decodable result type.
    ///   - decoder: Custom JSONDecoder if needed.
    public func requestJSON<T: Decodable>(
        _ req: URLRequest,
        decode: T.Type,
        decoder: JSONDecoder = .init()
    ) async throws -> T {
        var prepared = req
        prepare(&prepared)

        GlobalLoader.shared.show()
        NetLogger.logRequest(prepared)

        let (data, resp) = try await session.data(for: prepared)
        guard let http = resp as? HTTPURLResponse else {
            GlobalLoader.shared.hideAfterResponse(minDelay: 1.0)
            throw NetworkError.noResponse
        }

        NetLogger.logResponse(http, data: data)
        GlobalLoader.shared.hideAfterResponse(minDelay: 1.0)

        try Self.validate(http: http, data: data)

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decoding(error)
        }
    }

    /// Perform a request where the body is not needed (e.g., 204).
    public func requestEmpty(_ req: URLRequest) async throws {
        var prepared = req
        prepare(&prepared)

        GlobalLoader.shared.show()
        NetLogger.logRequest(prepared)

        let (data, resp) = try await session.data(for: prepared)
        guard let http = resp as? HTTPURLResponse else {
            GlobalLoader.shared.hideAfterResponse(minDelay: 1.0)
            throw NetworkError.noResponse
        }

        NetLogger.logResponse(http, data: data)
        GlobalLoader.shared.hideAfterResponse(minDelay: 1.0)

        try Self.validate(http: http, data: data)
    }

    // MARK: - Internals

    /// Applies decorators and refreshes runtime config (BASE_URL).
    private func prepare(_ request: inout URLRequest) {
        // Keep plist-driven changes hot
        AppConfig.configureFromPlist()
        decorators.forEach { $0.decorate(&request) }
    }

    /// Status mapping required by OppVenuz rule.
    private static func validate(http: HTTPURLResponse, data: Data) throws {
        switch http.statusCode {
        case 200, 201:
            return
        case 400: throw NetworkError.status(400, "Bad Request")
        case 401: throw NetworkError.status(401, "Unauthorized")
        case 403: throw NetworkError.status(403, "Forbidden")
        case 404: throw NetworkError.status(404, "Not Found")
        case 500: throw NetworkError.status(500, "Internal Server Error")
        default:
            let msg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NetworkError.status(http.statusCode, msg)
        }
    }
}

/// MARK: - Convenience wrapper that accepts VendorAPI directly
extension NetworkManager {
    @discardableResult
    func requestJSON<T: Decodable>(
        _ api: VendorAPI,
        decode: T.Type
    ) async throws -> T {
        let req = try APIRequestFactory.make(api)
        
        if api.needsLoader {
            await MainActor.run { GlobalLoader.shared.show() }
        }
        defer {
            if api.needsLoader {
                Task { await MainActor.run { GlobalLoader.shared.hide(force: true) } }
            }
        }
        
        return try await requestJSON(req, decode: T.self)
    }
}

