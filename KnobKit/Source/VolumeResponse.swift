//
//  VolumeResponse.swift
//  Knob
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

public extension VolumeResponse.Volume.Speaker {
    var levelPercentage: Double {
        return Double(level - range.minimum) / Double(range.maximum - range.minimum)
    }

    func volumeLevel(fromPercentage percentage: Double) -> Int {
        return range.minimum + Int(round(Double(range.maximum - range.minimum) * percentage))
    }
}
