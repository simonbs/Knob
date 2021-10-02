//
//  GetVolumeIntentHandler.swift
//  KnobIntents
//
//  Created by Simon on 02/10/2021.
//

import Intents
import KnobKit

final class GetVolumeIntentHandler: NSObject, GetVolumeIntentHandling {
    private let client = SpeakerClient(baseURL: Config.speakerBaseURL)

    func handle(intent: GetVolumeIntent, completion: @escaping (GetVolumeIntentResponse) -> Void) {
        client.loadVolume { result in
            switch result {
            case .success(let volumeResponse):
                let response = GetVolumeIntentResponse(code: .success, userActivity: nil)
                response.volume = volumeResponse.volume.speaker.levelPercentage * 100 as NSNumber
                completion(response)
            case .failure:
                let response = GetVolumeIntentResponse(code: .failure, userActivity: nil)
                completion(response)
            }
        }
    }
}
