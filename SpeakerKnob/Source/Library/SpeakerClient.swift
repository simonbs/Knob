//
//  SpeakerClient.swift
//  SpeakerKnob
//
//  Created by Simon on 30/09/2021.
//

import Foundation

final class SpeakerClient: APIClient {
    let baseURL: URL

    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    @discardableResult
    func loadVolume(_ completion: @escaping (Result<VolumeResponse, APIClientError>) -> Void) -> URLSessionTask? {
        let path = "/BeoZone/Zone/Sound/Volume"
        let request = makeRequest(path: path)
        return send(request, decoding: VolumeResponse.self, completion: completion)
    }

    @discardableResult
    func setVolume(_ volume: Int, _ completion: @escaping (Result<Void, APIClientError>) -> Void) -> URLSessionTask? {
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
