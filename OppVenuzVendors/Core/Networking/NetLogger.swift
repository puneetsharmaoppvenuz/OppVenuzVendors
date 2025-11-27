//
//  NetLogger.swift
//  OppVenuzVendors
//
//  Created by oppvenuz1 on 10/11/25.
//

import Foundation

public enum NetLogger {

    public static func logRequest(_ req: URLRequest) {
        var out: [String] = []
        out.append("➡️ REQUEST: \(req.httpMethod ?? "GET") \(req.url?.absoluteString ?? "")")
        if let h = req.allHTTPHeaderFields, !h.isEmpty { out.append("Headers: \(h)") }
        if let body = req.httpBody, !body.isEmpty {
            if let json = try? JSONSerialization.jsonObject(with: body, options: []),
               let pretty = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted]),
               let text = String(data: pretty, encoding: .utf8) {
                out.append("Body:\n\(text)")
            } else if let text = String(data: body, encoding: .utf8) {
                out.append("Body(raw):\n\(text)")
            } else {
                out.append("Body: <\(body.count) bytes>")
            }
        }
        if let curl = curlCommand(from: req) {
            out.append("cURL:\n\(curl)")
        }
        print(out.joined(separator: "\n"))
    }

    public static func logResponse(_ http: HTTPURLResponse, data: Data) {
        var out: [String] = []
        out.append("⬅️ RESPONSE: \(http.statusCode) \(http.url?.absoluteString ?? "")")
        let headers = http.allHeaderFields.reduce(into: [String:String]()) { dict, kv in
            dict[String(describing: kv.key)] = String(describing: kv.value)
        }
        out.append("Headers: \(headers)")
        if !data.isEmpty {
            if let json = try? JSONSerialization.jsonObject(with: data, options: []),
               let pretty = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted]),
               let text = String(data: pretty, encoding: .utf8) {
                out.append("Body:\n\(text)")
            } else if let text = String(data: data, encoding: .utf8) {
                out.append("Body(raw):\n\(text)")
            } else {
                out.append("Body: <\(data.count) bytes>")
            }
        }
        print(out.joined(separator: "\n"))
    }

    // MARK: - cURL

    private static func curlCommand(from request: URLRequest) -> String? {
        guard let url = request.url else { return nil }
        var parts: [String] = []
        parts.append("curl \"\(url.absoluteString)\"")

        if let method = request.httpMethod, method.uppercased() != "GET" {
            parts.append("-X \(method)")
        }

        if let headers = request.allHTTPHeaderFields {
            for (key, value) in headers {
                parts.append("-H \"\(key): \(value)\"")
            }
        }

        if let body = request.httpBody, !body.isEmpty {
            if let bodyString = String(data: body, encoding: .utf8) {
                // Bash-safe single-quote escaping: replace ' with '"'"'
                let escaped = bodyString.replacingOccurrences(of: "'", with: "'\"'\"'")
                parts.append("-d '\(escaped)'")
            } else {
                parts.append("# Body: <\(body.count) bytes binary omitted>")
            }
        }

        return parts.joined(separator: " \\\n  ")
    }
}
