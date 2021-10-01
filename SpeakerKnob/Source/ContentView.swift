//
//  ContentView.swift
//  SpeakerKnob
//
//  Created by Simon on 29/09/2021.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var volumeController: VolumeController
    @State private var haveLoadedVolume = false

    init(speakerBaseURL: URL) {
        self.volumeController = VolumeController(speakerBaseURL: speakerBaseURL)
    }

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
            Knob(
                backgroundStyle: Color(uiColor: .secondarySystemBackground),
                fillStyle: makeAngularGradient(),
                lineWidth: 75,
                value: $volumeController.volumePercentage)
                .opacity(haveLoadedVolume ? 1 : 0.5)
                .allowsHitTesting(haveLoadedVolume)
                .frame(width: 180, height: 180)
        }.onAppear {
            volumeController.loadVolume { success in
                withAnimation {
                    haveLoadedVolume = success
                }
            }
        }
    }
}

private extension ContentView {
    private func makeAngularGradient() -> AngularGradient {
        let colors: [Color] = [.green, .yellow, .orange, .red, .purple]
        let gradient = Gradient(colors: colors)
        return AngularGradient(gradient: gradient, center: .center, startAngle: .degrees(0), endAngle: .degrees(360))
    }
}
