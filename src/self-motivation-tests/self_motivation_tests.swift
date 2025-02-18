//
//  self_motivation_tests.swift
//  self-motivation-tests
//
//  Created by Matthew Manela on 2/1/25.
//

import Testing
@testable import Quick_Motivation

struct self_motivation_tests {

    @Test func testMessageItem() async throws {
        let messageItem: MessageItem = MessageItem(message: "Hello", emoji: "✅")
        #expect(String(describing:   messageItem) == "✅ Hello")
    }

}
