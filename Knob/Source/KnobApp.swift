//
//  KnobApp.swift
//  Knob
//
//  Created by Simon on 29/09/2021.
//

import KnobKit
import SwiftUI

@main
struct KnobApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(speakerBaseURL: Config.speakerBaseURL)
        }
    }
}
