//
//  ContentView.swift
//  SpeakerKnob
//
//  Created by Simon on 29/09/2021.
//

import SwiftUI

struct ContentView: View {
    private enum VolumeState {
        case loading
        case ready
        case failed
    }

    @ObservedObject private var volumeController: VolumeController
    @State private var volumeState: VolumeState = .loading
    @State private var errorMessage: String?

    init(speakerBaseURL: URL) {
        self.volumeController = VolumeController(speakerBaseURL: speakerBaseURL)
    }

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
            if volumeState == .ready || volumeState == .loading {
                makeKnob()
            }
            if volumeState == .loading {
                ProgressView()
            }
            if volumeState == .failed, let errorMessage = errorMessage {
                ErrorView(message: errorMessage) {
                    loadVolume()
                }
            }
        }.onAppear {
            loadVolume()
        }.onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            loadVolume()
        }
    }
}

private extension ContentView {
    private func loadVolume() {
        withAnimation {
            volumeState = .loading
        }
        volumeController.loadVolume { result in
            withAnimation {
                switch result {
                case .success:
                    volumeState = .ready
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    volumeState = .failed
                }
            }
        }
    }

    private func makeKnob() -> some View {
        Knob(
            backgroundStyle: Color(uiColor: .secondarySystemBackground),
            fillStyle: makeAngularGradient(),
            lineWidth: 75,
            value: $volumeController.volumePercentage)
            .opacity(volumeState == .ready ? 1 : 0.7)
            .allowsHitTesting(volumeState == .ready)
            .frame(width: 180, height: 180)
    }

    private func makeAngularGradient() -> AngularGradient {
        let colors: [Color] = [.green, .yellow, .orange, .red, .purple]
        let gradient = Gradient(colors: colors)
        return AngularGradient(gradient: gradient, center: .center, startAngle: .degrees(0), endAngle: .degrees(360))
    }
}
