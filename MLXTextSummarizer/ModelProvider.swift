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

enum ModelPrompt: String {
    case defaultValue = "You are a concise code-generating assistant."
    case summarizeTitle = "Create a very short title for the following text. Do not introduce the summary, do not explain your process, do not use any headings, and do not add any extra comments. Output the title only. Any extra wording will be considered incorrect: \n"
    case summarizeBody = "Summarize the following text. Do not introduce the summary, do not explain your process, do not use any headings, and do not add any extra comments. Output the summary only. Any extra wording will be considered incorrect: \n"
    case summarizeInTags = "Return exactly 3 single-word tags summarizing the text. Output only a JSON array of 3 strings in square brackets, like [\"Tag1\", \"Tag2\", \"Tag3\"]. Do not include any keys, objects, labels, or additional text. Only output the JSON array, or the response is invalid: \n"
}

enum ModelError: Error {
    case noModelLoaded
}

@Observable
class ModelProvider {
    static let shared = ModelProvider()
    
    private var modelContainer: ModelContainer?
    var isContainerLoaded: Bool { modelContainer != nil }
    private var modelConfiguration: ModelConfiguration = LLMRegistry.llama3_2_1B_4bit
    
    var downloadProgress: Progress?
    
    func prerapeModel() async throws {
            
        modelContainer = try await LLMModelFactory.shared.loadContainer(
            configuration: modelConfiguration
        ) { progress in
            self.downloadProgress = progress
        }
        
    }
    
    func generateSummary(
        _ prompt: String,
        preprompt: ModelPrompt,
        _ completion: @escaping (PassthroughSubject<String, Never>) -> Void
    ) async throws {
        
        let summaryPublisher = PassthroughSubject<String, Never>()
        completion(summaryPublisher)
        
        guard let modelContainer else {
            try await self.prerapeModel()
            throw ModelError.noModelLoaded
        }
        
        let _ = try await modelContainer.perform { context  in
            let prompt = UserInput(prompt: preprompt.rawValue + prompt)
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
