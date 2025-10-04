//
//  FAQItem.swift
//  Walnut
//
//  Created by Claude Code on 10/04/25.
//  Copyright © 2025 m. All rights reserved.
//

import Foundation

struct FAQItem: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}

extension FAQItem {
    static let allFAQs: [FAQItem] = [
        FAQItem(
            question: "Is Walnut private and secure?",
            answer: """
            Similar to password managers, Walnut stores your health journal entries in a private database that's encrypted on your phone. Walnut and its team can't see your journal entries and we really, really don't want to! We also don't collect app logs that identify your entries or tie them to any individual.

            When you use AI features in Walnut, like analyzing documents or extracting information, that data may be sent via API calls to LLM providers like OpenAI and Anthropic (Claude).

            API calls come from Walnut's credentials rather than yours, reducing AI vendors' ability to know which entries are associated with which specific people.

            If you don't want to use AI in any way related to your health journal, Walnut isn't a good choice for you.
            """
        ),

        FAQItem(
            question: "How do I try Walnut and what does it cost?",
            answer: """
            Walnut is currently free to use while in development. In the future, we may offer a subscription for advanced AI features. Our hope is to always have a way for people to use the core functionality of Walnut for free, since personal health journaling is important for wellness tracking.

            Walnut is available as an iOS app. You can download it and start using it right away.
            """
        ),

        FAQItem(
            question: "What is Walnut?",
            answer: """
            Walnut is a personal health journal app that helps you document and track your wellness journey. It's designed to help you keep track of health-related information in one place, with optional AI-powered features to make data entry easier.

            Remember: This is a journal app, not a medical or diagnostic tool. Always consult qualified healthcare professionals for medical advice.
            """
        ),

        FAQItem(
            question: "How does AI document parsing work?",
            answer: """
            When you upload a document or image, Walnut can use AI to extract relevant information automatically. This feature uses advanced language models to read and interpret the content.

            Important: AI can make mistakes. Always review and verify the extracted information before relying on it. The AI is a helpful assistant, but you should always double-check its work.
            """
        ),

        FAQItem(
            question: "Is my data backed up?",
            answer: """
            Your Walnut data is stored locally on your device. This means your data is private and secure, but it's important to keep your device backed up using iCloud or iTunes backups.

            We recommend enabling device backups to ensure your health journal is safe even if something happens to your phone.
            """
        ),
    ]
}
