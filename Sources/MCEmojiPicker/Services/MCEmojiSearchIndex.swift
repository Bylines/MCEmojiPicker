import Foundation

enum MCEmojiSearchIndex {
    private static let keywordsByEmoji: [String: [String]] = {
        guard let url = Bundle.module.url(forResource: "EmojiSearchKeywords", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let keywords = try? JSONDecoder().decode([String: [String]].self, from: data)
        else {
            return [:]
        }
        return keywords
    }()

    static func keywords(for emoji: String) -> [String] {
        keywordsByEmoji[emoji] ?? []
    }
}

extension MCEmoji {
    func matches(searchText: String) -> Bool {
        let tokens = searchText.split(whereSeparator: { $0.isWhitespace }).map(String.init)
        guard !tokens.isEmpty else { return true }

        let baseEmoji = emojiKeys.emoji()
        let terms = [searchKey, baseEmoji] + MCEmojiSearchIndex.keywords(for: baseEmoji)
        return tokens.allSatisfy { token in
            terms.contains { $0.localizedCaseInsensitiveContains(token) }
        }
    }
}
