//
//  ErrorView.swift
//  Knob
//
//  Created by Simon on 02/10/2021.
//

import SwiftUI

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text(message)
            Button(L10n.ErrorView.RetryButton.title, action: onRetry)
        }
    }
}
