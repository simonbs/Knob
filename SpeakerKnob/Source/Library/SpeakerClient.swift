//
//  SpeakerClient.swift
//  SpeakerKnob
//
//  Created by Simon on 30/09/2021.
//

import Foundation

enum SpeakerClientError: LocalizedError {
    case networkError(Error)
    case invalidResponse
    case invalidStatusCode(Int)
    case dataUnavailable
    case encodingFailed(EncodingError)
    case decodingFailed(DecodingError)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid URL response."
        case .invalidStatusCode(let statusCode):
            return "Invalid HTTP status code: \(statusCode)"
        case .dataUnavailable:
            return "Response data is not available."
        case .encodingFailed(let error):
            return "Failed encoding request body: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "Failed decoding response: \(error.localizedDescription)"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

final class SpeakerClient {
    private let baseURL: URL

    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    @discardableResult
    func loadVolume(_ completion: @escaping (Result<VolumeResponse, SpeakerClientError>) -> Void) -> URLSessionTask? {
        let path = "/BeoZone/Zone/Sound/Volume"
        let request = makeRequest(path: path)
        return send(request, decoding: VolumeResponse.self, completion: completion)
    }

    @discardableResult
    func setVolume(_ volume: Int, _ completion: @escaping (Result<Void, SpeakerClientError>) -> Void) -> URLSessionTask? {
        let path = "/BeoZone/Zone/Sound/Volume/Speaker/Level"
        let requestBody = SetVolumeRequestBody(level: volume)
        let requestResult = makeRequest(httpMethod: "PUT", path: path, body: requestBody)
        switch requestResult {
        case .success(let request):
            return sendReceivingVoid(request, completion: completion)
        case .failure(let error):
            completion(.failure(error))
            return nil
        }
    }
}

private extension SpeakerClient {
    private func send<T: Decodable>(
        _ request: URLRequest,
        decoding responseType: T.Type,
        completion: @escaping (Result<T, SpeakerClientError>) -> Void) -> URLSessionTask {
        return send(request) { result in
            switch result {
            case .success(let data):
                let decodedResult = self.decode(responseType, from: data)
                completion(decodedResult)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func sendReceivingVoid(_ request: URLRequest, completion: @escaping (Result<Void, SpeakerClientError>) -> Void) -> URLSessionTask {
        return send(request) { result in
            let mappedResult = result.map { _ in }
            completion(mappedResult)
        }
    }

    private func send(_ request: URLRequest, completion: @escaping (Result<Data, SpeakerClientError>) -> Void) -> URLSessionTask {
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
            } else if let httpResponse = response as? HTTPURLResponse {
                if (200 ... 299).contains(httpResponse.statusCode) {
                    if let data = data {
                        completion(.success(data))
                    } else {
                        completion(.failure(.dataUnavailable))
                    }
                } else {
                    completion(.failure(.invalidStatusCode(httpResponse.statusCode)))
                }
            } else {
                completion(.failure(.invalidResponse))
            }
        }
        task.resume()
        return task
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data) -> Result<T, SpeakerClientError> {
        do {
            let decoder = JSONDecoder()
            let value = try decoder.decode(type.self, from: data)
            return .success(value)
        } catch let decodingError as DecodingError {
            return .failure(.decodingFailed(decodingError))
        } catch {
            return .failure(.unknown(error))
        }
    }

    private func makeRequest(httpMethod: String = "GET", path: String) -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        return request
    }

    private func makeRequest<T: Encodable>(httpMethod: String = "GET", path: String, body: T) -> Result<URLRequest, SpeakerClientError> {
        var request = makeRequest(httpMethod: httpMethod, path: path)
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(body)
            request.httpBody = data
            return .success(request)
        } catch let encodingError as EncodingError {
            return .failure(.encodingFailed(encodingError))
        } catch {
            return .failure(.unknown(error))
        }
    }
}
