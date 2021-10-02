//
//  SetVolumeIntentHandler.swift
//  KnobIntents
//
//  Created by Simon on 02/10/2021.
//

import Intents
import KnobKit

final class SetVolumeIntentHandler: NSObject, SetVolumeIntentHandling {
    private let client = SpeakerClient(baseURL: Config.speakerBaseURL)

    func handle(intent: SetVolumeIntent, completion: @escaping (SetVolumeIntentResponse) -> Void) {
        if let volume = intent.volume?.intValue {
            client.setVolume(volume) { result in
                switch result {
                case .success:
                    let response = SetVolumeIntentResponse(code: .success, userActivity: nil)
                    completion(response)
                case .failure:
                    let response = SetVolumeIntentResponse(code: .failure, userActivity: nil)
                    completion(response)
                }
            }
        } else {
            let response = SetVolumeIntentResponse(code: .failure, userActivity: nil)
            completion(response)
        }
    }

    func resolveVolume(for intent: SetVolumeIntent, with completion: @escaping (SetVolumeVolumeResolutionResult) -> Void) {
        if let volume = intent.volume?.doubleValue {
            if volume < 0 {
                completion(.unsupported(forReason: .negativeNumbersNotSupported))
            } else if volume > 100 {
                completion(.unsupported(forReason: .greaterThanMaximumValue))
            } else {
                completion(.success(with: volume))
            }
        } else {
            completion(.needsValue())
        }
    }
}
