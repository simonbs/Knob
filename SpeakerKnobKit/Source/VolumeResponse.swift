//
//  VolumeResponse.swift
//  SpeakerKnob
//
//  Created by Simon on 30/09/2021.
//

import Foundation

public struct VolumeResponse: Codable {
    public struct Volume: Codable {
        public struct Speaker: Codable {
            public struct Range: Codable {
                public let minimum: Int
                public let maximum: Int
            }

            public let range: Self.Range
            public let level: Int
        }

        public let speaker: Speaker
    }

    public let volume: Volume
}
