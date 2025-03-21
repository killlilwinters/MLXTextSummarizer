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
    
    private let hapticEngine: HapticProvider?
    
    var responseTitle = String()
    var responseBody = String()
    var responseTags = [String]()
    
    var inputText = String()
    
    var cancellable = Set<AnyCancellable>()
    
    init() {
        guard let hapticEngine = try? HapticProvider() else { self.hapticEngine = nil; return }
        self.hapticEngine = hapticEngine
    }
    
    
    func loadModel() async {
        try? await modelProvider.prerapeModel()
    }
    
    func startSummarize() async {
        
        await summarize(preprompt: .summarizeTitle)
        await summarize(preprompt: .summarizeBody)
        
        await summarizeInTags()
        
    }
    
    private func summarize(preprompt: ModelPrompt) async {
        try? await modelProvider.generateSummary(inputText, preprompt: preprompt) { [weak self] publisher in
            guard let self else { return }
            
            publisher
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        self.hapticEngine?.performSuccess()
                    }
                } receiveValue: { value in
                    switch preprompt {
                    case .summarizeTitle:
                        self.responseTitle = value
                        try? self.hapticEngine?.performLightTap()
                    case .summarizeBody:
                        self.responseBody = value
                    default:
                        break
                    }
                }
                .store(in: &cancellable)
        }
    }
    
    private func summarizeInTags() async {
        responseTags.removeAll()
        try? await modelProvider.generateSummary(responseBody, preprompt: .summarizeInTags) { [weak self] publisher in
            guard let self else { return }
            
            var finalValue: String = ""
            
            publisher
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    print(finalValue)
                    let decoded = try? JSONDecoder().decode([String].self, from: Data(finalValue.utf8))
                    
                    if let tags = decoded, !tags.isEmpty {
                        self.responseTags = tags
                    } else {
                        Task { await self.summarizeInTags() }
                    }
                } receiveValue: { value in
                    finalValue = value
                }
                .store(in: &cancellable)
            
        }
    }
}
