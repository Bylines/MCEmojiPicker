#!/usr/bin/env swift

import Foundation

struct CLDRAnnotations: Decodable {
    struct Container: Decodable {
        let annotations: [String: Entry]
    }

    struct Entry: Decodable {
        let `default`: [String]?
        let tts: [String]?
    }

    let annotations: Container
}

guard CommandLine.arguments.count == 4 else {
    fatalError("Usage: generate-emoji-search-keywords.swift <CLDR annotations.json> <emoji definitions directory> <output.json>")
}

let annotationsURL = URL(fileURLWithPath: CommandLine.arguments[1])
let definitionsURL = URL(fileURLWithPath: CommandLine.arguments[2], isDirectory: true)
let outputURL = URL(fileURLWithPath: CommandLine.arguments[3])
let decoder = JSONDecoder()
let annotations = try decoder.decode(CLDRAnnotations.self, from: Data(contentsOf: annotationsURL))
let definitionURLs = try FileManager.default.contentsOfDirectory(
    at: definitionsURL,
    includingPropertiesForKeys: nil
).filter { $0.pathExtension == "json" }

var keywordsByEmoji: [String: [String]] = [:]
for definitionURL in definitionURLs {
    let object = try JSONSerialization.jsonObject(with: Data(contentsOf: definitionURL))
    guard let category = object as? [String: Any],
          let emojis = category["emojis"] as? [[String: Any]]
    else {
        continue
    }

    for emoji in emojis {
        guard let string = emoji["string"] as? String else { continue }
        let normalized = string.replacingOccurrences(of: "\u{FE0F}", with: "")
        guard let annotation = annotations.annotations.annotations[normalized] else { continue }

        var seen = Set<String>()
        let terms = (annotation.default ?? []) + (annotation.tts ?? [])
        keywordsByEmoji[string] = terms.filter { seen.insert($0).inserted }
    }
}

let output = try JSONSerialization.data(
    withJSONObject: keywordsByEmoji,
    options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
)
try output.write(to: outputURL, options: .atomic)
