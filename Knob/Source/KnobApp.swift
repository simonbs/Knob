//
//  KnobApp.swift
//  Knob
//
//  Created by Simon on 29/09/2021.
//

import SwiftUI

@main
struct KnobApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(speakerBaseURL: URL(string: "http://192.168.1.99:8080")!)
        }
    }
}
