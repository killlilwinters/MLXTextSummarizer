//
//  ContentView.swift
//  MLXTextSummarizer
//
//  Created by Maks Winters on 19.03.2025.
//
// https://sarunw.com/posts/dismiss-keyboard-in-swiftui/
//

import SwiftUI

struct ContentView: View {
    
    @Bindable private var viewModel = ContentViewModel()
    @FocusState private var isFocused: Bool
    let isModelLoaded = ModelProvider.shared.isContainerLoaded
    
    var body: some View {
        NavigationStack {
            Spacer()
            VStack(spacing: 20) {
                Text(viewModel.responseTitle)
                    .font(.title)
                Text(viewModel.responseBody)
                    .font(.body)
                HStack {
                    ForEach(viewModel.responseTags, id: \.self) { tag in
                        Text(tag)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.blue)
                            }
                    }
                }
                Spacer()
                HStack {
                    let rectangle = RoundedRectangle(cornerRadius: 20)
                    TextEditor(text: $viewModel.inputText)
                        .focused($isFocused)
                        .frame(height: 100)
                        .clipShape(rectangle)
                        .overlay {
                            rectangle
                                .stroke(lineWidth: 2)
                        }
                    Button("Summarize") {
                        Task {
                            await viewModel.startSummarize()
                        }
                    }
                    .disabled(!isModelLoaded)
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                }
                .padding()
                .task {
                    await viewModel.loadModel()
                }
            }
            .toolbar {
                #if os(iOS)
                ToolbarItem {
                    Button("Dismiss keyboard") {
                        isFocused = false
                    }
                }
                #endif
            }
        }
        .overlay {
            if !isModelLoaded {
                ProgressView()
                    .progressViewStyle(.circular)
                
            }
        }
    }
}

#Preview {
    ContentView()
}
