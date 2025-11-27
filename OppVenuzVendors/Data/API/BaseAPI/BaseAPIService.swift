//
//  BaseAPIService.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 10/11/25.
//
import Foundation

public enum BaseAPIService {

    // Storage keys
    private static let kBaseAPIEnvelope = "base.api.envelope.cached"
    private static let kOnboardingGIFURL = "base.api.onboarding.gif.url"

    /// Fetch from server and cache.
    public static func fetchAndCache() async throws -> BaseAPIEnvelope {
        // Build request using existing APIRequestFactory & VendorAPI
        let req = try APIRequestFactory.make(.baseAPI)
        let envelope: BaseAPIEnvelope = try await NetworkManager.shared.requestJSON(req, decode: BaseAPIEnvelope.self)

        // Cache the full envelope (Codable JSON via DefaultsStore)
        _ = DefaultsStore.setCodable(envelope, for: .baseAPI)

        // Extract GIF URL for quick access later
        if let url = envelope.data?.onboarding?.gif?.media.image {
            DefaultsStore.setString(url, for: .onboardingGIF)
        }
        return envelope
    }

    /// Read cached envelope (if any).
    public static func cachedEnvelope() -> BaseAPIEnvelope? {
        DefaultsStore.getCodable(BaseAPIEnvelope.self, for: .baseAPI)
    }

    /// Quick access to cached GIF URL.
    public static func cachedGIFURL() -> String? {
        DefaultsStore.getString(.onboardingGIF)
    }
}
