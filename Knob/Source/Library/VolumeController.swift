//
//  VolumeController.swift
//  Knob
//
//  Created by Simon on 30/09/2021.
//

import Combine
import KnobKit

final class VolumeController: ObservableObject {
    @Published var volumePercentage: Double = 0 {
        didSet {
            if volumePercentage != oldValue {
                setOptimisticVolume(toPercentage: volumePercentage)
            }
        }
    }

    private let client: SpeakerClient
    private var volumeResponse: VolumeResponse?
    private var actualVolume = 0
    private var optimisticVolume = 0
    private var queuedVolume = 0
    private let throttler = Throttler(delay: 0.5)
    private var isSendingVolume = false
    private var cancellables: [AnyCancellable] = []

    init(speakerBaseURL: URL) {
        self.client = SpeakerClient(baseURL: speakerBaseURL)
        self.throttler.delegate = self
    }

    func loadVolume(_ completion: ((Result<Void, APIClientError>) -> Void)? = nil) {
        client.loadVolume { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.actualVolume = response.volume.speaker.level
                    self.optimisticVolume = response.volume.speaker.level
                    self.queuedVolume = response.volume.speaker.level
                    self.volumeResponse = response
                    self.updateVolumePercentageFromOptimisticVolume()
                case .failure(let error):
                    print(error)
                    self.volumeResponse = nil
                }
                let mappedResult = result.map { _ in }
                completion?(mappedResult)
            }
        }
    }
}

private extension VolumeController {
    private func setOptimisticVolume(toPercentage percentage: Double) {
        if let volumeResponse = volumeResponse {
            optimisticVolume = volumeResponse.volume.speaker.volumeLevel(fromPercentage: percentage)
            queueOptimisticVolumeIfNecessary()
        }
    }

    private func updateVolumePercentageFromOptimisticVolume() {
        if let volumeResponse = volumeResponse {
            volumePercentage = volumeResponse.volume.speaker.levelPercentage
        }
    }

    private func queueOptimisticVolumeIfNecessary() {
        if queuedVolume != optimisticVolume && !isSendingVolume {
            queuedVolume = optimisticVolume
            throttler.didReceiveEvent()
        }
    }

    private func sendQueuedVolume() {
        isSendingVolume = true
        client.setVolume(queuedVolume) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.isSendingVolume = false
                    self.actualVolume = self.optimisticVolume
                    self.queueOptimisticVolumeIfNecessary()
                case .failure(let error):
                    print(error)
                    self.isSendingVolume = false
                    self.optimisticVolume = self.actualVolume
                    self.updateVolumePercentageFromOptimisticVolume()
                }
            }
        }
    }
}

extension VolumeController: ThrottlerDelegate {
    func throttlerDidThrottle(_ throttler: Throttler) {
        sendQueuedVolume()
    }
}
