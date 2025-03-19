//
//  ContentView.swift
//  MLXTextSummarizer
//
//  Created by Maks Winters on 19.03.2025.
//

import SwiftUI

struct ContentView: View {
    
    @Bindable private var viewModel = ContentViewModel()
    
    var body: some View {
        
        VStack {
            List {
                Section("Previous responses") {
                    ForEach(viewModel.responses, id: \.self) { response in
                        Text(response)
                    }
                }
                Section("Latest response") {
                    Text(viewModel.summary)
                }
            }
            HStack {
                let rectangle = RoundedRectangle(cornerRadius: 20)
                TextEditor(text: $viewModel.inputText)
                    .frame(height: 100)
                    .clipShape(rectangle)
                    .overlay {
                        rectangle
                            .stroke(lineWidth: 2)
                    }
                Button("Summarize") {
                    Task {
                        await viewModel.summarize()
                    }
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
            }
            .padding()
            .task {
                await viewModel.loadModel()
            }
        }
    }
}

#Preview {
    ContentView()
}
