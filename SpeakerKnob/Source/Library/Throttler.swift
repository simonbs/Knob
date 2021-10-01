//
//  Throttler.swift
//  SpeakerKnob
//
//  Created by Simon on 30/09/2021.
//

import Foundation

protocol ThrottlerDelegate: AnyObject {
    func throttlerDidThrottle(_ throttler: Throttler)
}

final class Throttler {
    weak var delegate: ThrottlerDelegate?

    private let delay: TimeInterval
    private var timer: Timer?

    init(delay: TimeInterval) {
        self.delay = delay
    }

    func didReceiveEvent() {
        cancel()
        timer = .scheduledTimer(
            timeInterval: delay,
            target: self,
            selector: #selector(timerTriggered),
            userInfo: nil,
            repeats: false)
    }

    func cancel() {
        timer?.invalidate()
        timer = nil
    }
}

private extension Throttler {
    @objc private func timerTriggered() {
        cancel()
        delegate?.throttlerDidThrottle(self)
    }
}
