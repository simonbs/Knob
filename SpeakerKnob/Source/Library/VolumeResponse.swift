//
//  VolumeResponse.swift
//  SpeakerKnob
//
//  Created by Simon on 30/09/2021.
//

import Foundation

struct VolumeResponse: Codable {
    struct Volume: Codable {
        struct Speaker: Codable {
            struct Range: Codable {
                let minimum: Int
                let maximum: Int
            }

            let range: Self.Range
            let level: Int
        }

        let speaker: Speaker
    }

    let volume: Volume
}
