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
    
    let rectangle = RoundedRectangle(cornerRadius: 20)
    
    var body: some View {
        NavigationStack {
            Spacer()
            VStack(spacing: 20) {
                Text(viewModel.responseTitle)
                    .font(.title)
                HighlightedText(text: viewModel.responseBody, highlightedText: [viewModel.responseTags: Color.accentColor.gradient])
                    .font(.body)
                    .padding()
//                Text(viewModel.responseBody)
//                    .font(.body)
//                    .padding()
                HStack {
                    ForEach(viewModel.responseTags, id: \.self) { tag in
                        TagView(title: tag)
                            .transition(.blurReplace)
                    }
                }
                Spacer()
                HStack {
                    TextEditor(text: $viewModel.inputText)
                        .focused($isFocused)
                        .frame(height: 100)
                        .clipShape(rectangle)
                        .overlay {
                            rectangle
                                .stroke(lineWidth: 2)
                        }
                        .onSubmit { summarize() }
                    Button("Summarize") {
                        summarize()
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
                LoadingView
            }
        }
    }
    
    @ViewBuilder
    var LoadingView: some View {
        ZStack {
            Rectangle()
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(.ultraThinMaterial)
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(.circular)
                Text("Loading model\nplease, wait...")
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    func summarize() {
        Task {
            await viewModel.startSummarize()
        }
    }
    
}

#Preview {
    ContentView()
}
