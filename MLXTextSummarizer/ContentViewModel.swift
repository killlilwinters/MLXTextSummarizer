//
//  ContentViewModel.swift
//  MLXTextSummarizer
//
//  Created by Maks Winters on 19.03.2025.
//

import Combine
import Foundation

@Observable
class ContentViewModel {
    private let modelProvider = ModelProvider.shared
    
    var responses = [String]()
    var inputText = String()
    var summary = "No summary yet..."
    
    var cancellable = Set<AnyCancellable>()
    
    private func summarizationCompleted() {
        responses.append(summary)
    }
    
    func loadModel() async {
        try? await modelProvider.prerapeModel()
    }
    
    func summarize() async {
        try? await modelProvider.generateSummary(inputText) { [weak self] publisher in
            guard let self else { return }
            
            publisher
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    self.summarizationCompleted()
                } receiveValue: { value in
                    self.summary = value
                }
                .store(in: &cancellable)
        }
    }
}

