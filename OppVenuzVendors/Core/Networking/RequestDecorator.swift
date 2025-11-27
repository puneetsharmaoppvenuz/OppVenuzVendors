//
//  RequestDecorator.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 10/11/25.
//

import Foundation

/// A request decorator can mutate a URLRequest before it is sent.
/// Examples: Authorization header, default headers, locale tagging, etc.
public protocol RequestDecorator {
    func decorate(_ request: inout URLRequest)
}
