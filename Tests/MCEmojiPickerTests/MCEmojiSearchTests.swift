import XCTest
@testable @_spi(JSON) import MCEmojiPicker

final class MCEmojiSearchTests: XCTestCase {
    func testFoldedHandsMatchesPrayerAssociation() {
        let foldedHands = MCEmoji(
            emojiKeys: [0x1F64F],
            isSkinToneSupport: true,
            searchKey: "foldedHands",
            version: 0.6
        )

        XCTAssertTrue(foldedHands.matches(searchText: "pray"))
        XCTAssertTrue(foldedHands.matches(searchText: "thanks"))
        XCTAssertTrue(foldedHands.matches(searchText: "folded hands"))
        XCTAssertFalse(foldedHands.matches(searchText: "prayer beads"))
    }
}
