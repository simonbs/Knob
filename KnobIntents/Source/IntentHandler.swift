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
        } else {
            fatalError("Intent has unexpected type")
        }
    }
}
