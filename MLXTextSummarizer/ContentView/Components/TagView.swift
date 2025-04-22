//
//  TagView.swift
//  MLXTextSummarizer
//
//  Created by Maks Winters on 22.04.2025.
//

import SwiftUI

struct TagView: View {
    
    let title: String
    let rectangle = RoundedRectangle(cornerRadius: 10)
    let gradient = LinearGradient(colors: [.accentColor, .accentColor.mix(with: .white, by: 0.2)], startPoint: .bottomLeading, endPoint: .bottomTrailing)
    
    var body: some View {
        Text(title)
            .padding(.horizontal)
            .padding(.vertical, 5)
            .background {
                rectangle
                    .fill(Color.accentColor.opacity(0.7))
            }
            .overlay {
                rectangle
                    .stroke(lineWidth: 3)
                    .fill(gradient)
            }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    TagView(title: "Test")
}
