//
//  SpeakerClient.swift
//  Knob
//
//  Created by Simon on 30/09/2021.
//

import Foundation

public final class SpeakerClient: APIClient {
    let baseURL: URL

    public init(baseURL: URL) {
        self.baseURL = baseURL
    }

    @discardableResult
    public func loadVolume(completion: @escaping (Result<VolumeResponse, APIClientError>) -> Void) -> URLSessionTask? {
        let path = "/BeoZone/Zone/Sound/Volume"
        let request = makeRequest(path: path)
        return send(request, decoding: VolumeResponse.self, completion: completion)
    }

    @discardableResult
    public func setVolume(_ volume: Int, completion: @escaping (Result<Void, APIClientError>) -> Void) -> URLSessionTask? {
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
