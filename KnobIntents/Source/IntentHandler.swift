//
//  IntentHandler.swift
//  KnobIntents
//
//  Created by Simon on 02/10/2021.
//

import Intents
import KnobKit

final class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any? {
        if intent is SetVolumeIntent {
            return SetVolumeIntentHandler()
        } else if intent is GetVolumeIntent {
            return GetVolumeIntentHandler()
        } else {
            fatalError("Intent has unexpected type")
        }
    }
}
