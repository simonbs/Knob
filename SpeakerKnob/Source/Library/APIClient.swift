//
//  APIClient.swift
//  SpeakerKnob
//
//  Created by Simon on 02/10/2021.
//

import Foundation

enum APIClientError: LocalizedError {
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

protocol APIClient {
    var baseURL: URL { get }
    var session: URLSession { get }
}

extension APIClient {
    var session: URLSession {
        return .shared
    }
}

extension APIClient {
    func send<T: Decodable>(
        _ request: URLRequest,
        decoding responseType: T.Type,
        completion: @escaping (Result<T, APIClientError>) -> Void) -> URLSessionTask {
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

    func sendReceivingVoid(_ request: URLRequest, completion: @escaping (Result<Void, APIClientError>) -> Void) -> URLSessionTask {
        return send(request) { result in
            let mappedResult = result.map { _ in }
            completion(mappedResult)
        }
    }

    func makeRequest(httpMethod: String = "GET", path: String) -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        return request
    }

    func makeRequest<T: Encodable>(httpMethod: String = "POST", path: String, body: T) -> Result<URLRequest, APIClientError> {
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

private extension APIClient {
    private func send(_ request: URLRequest, completion: @escaping (Result<Data, APIClientError>) -> Void) -> URLSessionTask {
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

    private func decode<T: Decodable>(_ type: T.Type, from data: Data) -> Result<T, APIClientError> {
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
}
