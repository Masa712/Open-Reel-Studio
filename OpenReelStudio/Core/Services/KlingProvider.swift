//
//  KlingProvider.swift
//  OpenReelStudio
//
//  Created by Masayuki Watanabe on 2026/01/20.
//

import Foundation
import CryptoKit

struct KlingProvider: VideoProviderProtocol {
    let providerId = "kling"

    private let baseURL: URL
    private let accessKey: String
    private let secretKey: String
    private let session: URLSession

    init(baseURL: URL, accessKey: String, secretKey: String, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.session = session
    }

    func startGeneration(prompt: String, config: GenerationConfig) async throws -> String {
        let url = baseURL.appendingPathComponent("v1/generation/video")
        let payload = StartGenerationRequest(
            prompt: prompt,
            aspectRatio: config.aspectRatio,
            duration: config.duration
        )
        let body = try JSONEncoder().encode(payload)

        let request = try makeRequest(url: url, method: "POST", body: body)
        let (data, response) = try await session.data(for: request)
        try validate(response: response, data: data)

        let decoded = try JSONDecoder().decode(StartGenerationResponse.self, from: data)
        return decoded.jobId
    }

    func checkStatus(jobId: String) async throws -> GenerationStatus {
        let url = baseURL.appendingPathComponent("v1/generation/video/\(jobId)")
        let request = try makeRequest(url: url, method: "GET", body: nil)
        let (data, response) = try await session.data(for: request)
        try validate(response: response, data: data)

        let decoded = try JSONDecoder().decode(GenerationStatusResponse.self, from: data)
        switch decoded.status.lowercased() {
        case "queued", "processing", "running":
            return .processing(progress: decoded.progress)
        case "completed", "succeeded", "success":
            guard let urlString = decoded.videoURL, let videoURL = URL(string: urlString) else {
                throw KlingProviderError.missingVideoURL
            }
            return .completed(videoURL: videoURL)
        case "failed", "error":
            return .failed(reason: decoded.errorMessage ?? "Generation failed.")
        default:
            return .failed(reason: "Unknown status: \(decoded.status)")
        }
    }

    private func makeRequest(url: URL, method: String, body: Data?) throws -> URLRequest {
        let token = try makeToken()
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = body
        return request
    }

    private func makeToken(now: Date = Date()) throws -> String {
        let trimmedAccessKey = accessKey.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSecretKey = secretKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedAccessKey.isEmpty, !trimmedSecretKey.isEmpty else {
            throw KlingProviderError.missingCredentials
        }

        let header: [String: String] = [
            "alg": "HS256",
            "typ": "JWT",
        ]
        let payload: [String: Any] = [
            "iss": trimmedAccessKey,
            "exp": Int(now.timeIntervalSince1970) + 1800,
            "nbf": Int(now.timeIntervalSince1970) - 5,
        ]

        guard let headerData = try? JSONSerialization.data(withJSONObject: header, options: []),
              let payloadData = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
            throw KlingProviderError.tokenEncodingFailed
        }

        let headerPart = base64URL(headerData)
        let payloadPart = base64URL(payloadData)
        let signingInput = "\(headerPart).\(payloadPart)"

        let key = SymmetricKey(data: Data(trimmedSecretKey.utf8))
        let signature = HMAC<SHA256>.authenticationCode(for: Data(signingInput.utf8), using: key)
        let signaturePart = base64URL(Data(signature))
        return "\(signingInput).\(signaturePart)"
    }

    private func base64URL(_ data: Data) -> String {
        data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    private func validate(response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else {
            throw KlingProviderError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            let message = KlingErrorResponse.message(from: data) ?? "HTTP \(http.statusCode)"
            throw KlingProviderError.httpError(statusCode: http.statusCode, message: message)
        }
    }
}

enum KlingProviderError: Error {
    case invalidResponse
    case httpError(statusCode: Int, message: String)
    case missingVideoURL
    case missingCredentials
    case tokenEncodingFailed
}

private struct StartGenerationRequest: Encodable {
    let prompt: String
    let aspectRatio: String
    let duration: Int
}

private struct StartGenerationResponse: Decodable {
    let jobId: String

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let jobId = try container.decodeIfPresent(String.self, forKey: .jobId) {
            self.jobId = jobId
        } else if let jobId = try container.decodeIfPresent(String.self, forKey: .id) {
            self.jobId = jobId
        } else {
            throw KlingProviderError.invalidResponse
        }
    }

    private enum CodingKeys: String, CodingKey {
        case jobId = "job_id"
        case id
    }
}

private struct GenerationStatusResponse: Decodable {
    let status: String
    let progress: Double?
    let videoURL: String?
    let errorMessage: String?

    private enum CodingKeys: String, CodingKey {
        case status
        case progress
        case videoURL = "video_url"
        case errorMessage = "error"
    }
}

private struct KlingErrorResponse: Decodable {
    let message: String?
    let error: String?

    static func message(from data: Data) -> String? {
        guard let decoded = try? JSONDecoder().decode(KlingErrorResponse.self, from: data) else {
            return nil
        }
        return decoded.message ?? decoded.error
    }
}
