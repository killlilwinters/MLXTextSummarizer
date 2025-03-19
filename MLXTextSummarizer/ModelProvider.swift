//
//  ModelProvider.swift
//  MLXTextSummarizer
//
//  Created by Maks Winters on 19.03.2025.
//

import MLXLLM
import MLXLMCommon
import Foundation
import Combine

enum ModelError: Error {
    case noModelLoaded
}

class ModelProvider {
    static let shared = ModelProvider()
    
    private var modelContainer: ModelContainer?
    private let modelConfiguration: ModelConfiguration = LLMRegistry.qwen205b4bit
    
    var downloadProgress: Progress?
    
    func prerapeModel() async throws {
            
        modelContainer = try await LLMModelFactory.shared.loadContainer(
            configuration: modelConfiguration
        ) { progress in
            self.downloadProgress = progress
        }
        
    }
    
    func generateSummary(_ prompt: String, _ completion: @escaping (PassthroughSubject<String, Never>) -> Void) async throws {
        let summaryPublisher = PassthroughSubject<String, Never>()
        completion(summaryPublisher)
        
        guard let modelContainer else {
            try await self.prerapeModel()
            throw ModelError.noModelLoaded
        }
        
        let _ = try await modelContainer.perform { context  in
            let prompt = UserInput(prompt: "Summarize this text as compact as possible:" + prompt)
            let input = try await context.processor.prepare(input: prompt)
            
            return try MLXLMCommon.generate(input: input, parameters: .init(), context: context) { tokens in
                let text = context.tokenizer.decode(tokens: tokens)
                
                summaryPublisher.send(text)
                
                return .more
            }
        }
        summaryPublisher.send(completion: Subscribers.Completion.finished)
    }
    
}
