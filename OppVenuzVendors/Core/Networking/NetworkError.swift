//
//  NetworkError.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 10/11/25.
//

import Foundation

public enum NetworkError: Error, CustomStringConvertible {
    case badURL
    case noResponse
    case decoding(Error)
    case status(Int, String)
    case underlying(Error)

    public var description: String {
        switch self {
        case .badURL: return "Bad URL"
        case .noResponse: return "No HTTPURLResponse"
        case .decoding(let e): return "Decoding error: \(e)"
        case .status(let code, let msg): return "HTTP \(code): \(msg)"
        case .underlying(let e): return "Underlying error: \(e)"
        }
    }
}
