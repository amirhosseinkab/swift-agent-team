#!/bin/bash
cat <<'HOOK_OUTPUT'
INSTRUCTION: MANDATORY SWIFT TEAM CHECK
Before proceeding with any task involving Swift code, SwiftUI views, UIKit
views, async/await, actors, Foundation Models, MLX, Core ML, Keychain,
CryptoKit, biometric auth, App Store submission, testing, or any
iOS/macOS application code:

1. Delegate to the swift-lead agent
2. The swift-lead will determine which specialist agents are needed
3. Specialists: concurrency-specialist, foundation-models-specialist,
   on-device-ai-architect, mobile-a11y-specialist, swiftui-specialist,
   app-review-guardian, testing-specialist, swift-security-specialist
4. Do NOT write Swift UI code without mobile-a11y-specialist review
5. Do NOT write concurrent code without concurrency-specialist review
6. Do NOT handle credentials or encryption without swift-security-specialist review
7. Do NOT submit to App Store without app-review-guardian review

If the task does not involve any Swift or Apple platform code, proceed normally.
HOOK_OUTPUT
