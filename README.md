# Swift Agent Team

**A team of specialized Swift agents for Claude Code.**

Built by [Taylor Arndt](https://github.com/taylorarndt) for Swift developers who want AI that actually understands modern Swift. Swift 6.2 strict concurrency, Apple Foundation Models, on-device AI, SwiftUI best practices, and mobile accessibility -- enforced on every prompt.

## The Problem

AI coding tools write Swift like it is 2020. They use ObservableObject when @Observable exists. They ignore actor isolation. They produce views with no accessibility modifiers. They have never heard of Apple Foundation Models or @Generable. They use Task.detached for no reason. They put heavy work on @MainActor. They write custom controls that VoiceOver cannot read.

## The Solution

Swift Agent Team is a set of nine specialized agents plus a hook that evaluates every prompt. Each agent has deep knowledge of one domain and cannot forget it. The Swift Lead orchestrator coordinates the team and ensures the right specialists review every task.

## The Team

| Agent | Role |
|-------|------|
| **swift-lead** | Orchestrator. Routes tasks to the right specialists. Every Swift task goes through the lead first. |
| **concurrency-specialist** | Swift 6.2 strict concurrency. Actors, Sendable, async/await, structured concurrency, Task.immediate, @concurrent, approachable concurrency. Prevents data races at compile time. |
| **foundation-models-specialist** | Apple Foundation Models framework (iOS 26+). LanguageModelSession, @Generable structured output, @Guide constraints, tool calling, prompt design, guardrails, context management. |
| **on-device-ai-architect** | On-device AI deployment. MLX Swift, llama.cpp, Core ML, model selection by device tier, memory management, quantization, multi-backend fallback strategies. |
| **mobile-a11y-specialist** | iOS and macOS accessibility. VoiceOver labels and traits, element grouping, focus management, Dynamic Type, custom actions, rotors, system preferences (Reduce Motion, Increase Contrast). |
| **swiftui-specialist** | Modern SwiftUI patterns. @Observable, proper state management, NavigationStack, environment, view composition, performance, async data loading with .task. |
| **app-review-guardian** | App Store Review Guidelines. Catches rejection risks: privacy manifests, IAP rules, HIG violations, entitlements, metadata, common guideline misinterpretations. |
| **testing-specialist** | Swift Testing and XCTest. @Test, @Suite, #expect, parameterized tests, UI testing, mocking patterns, testable architecture, snapshot testing, code coverage. |
| **swift-security-specialist** | iOS/macOS security. Keychain Services, CryptoKit, biometric auth (Face ID/Touch ID), ATS, privacy manifests, certificate pinning, Secure Enclave, data protection. |

## How It Works

A `UserPromptSubmit` hook fires on every prompt. If the task involves Swift code, the hook instructs Claude to delegate to the **swift-lead** first. The lead evaluates the task and invokes the relevant specialists. Multiple specialists can review a single task -- a SwiftUI view with async data loading and accessibility needs gets reviewed by the swiftui-specialist, concurrency-specialist, and mobile-a11y-specialist.

For tasks that don't involve Swift code, the hook is ignored and Claude proceeds normally.

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed
- A Claude Code subscription (Pro, Max, or Team)

## Installation

### Project-Level (Recommended for Swift Projects)

Copy the `.claude` folder into your Swift project root:

```bash
git clone https://github.com/taylorarndt/swift-agent-team.git
cp -r swift-agent-team/.claude /path/to/your/swift-project/
```

The agents and hook travel with the repo. Your whole team benefits.

### Global Install

Install to `~/.claude/` so the agents are available across all projects:

```bash
git clone https://github.com/taylorarndt/swift-agent-team.git
cp -r swift-agent-team/.claude/agents/*.md ~/.claude/agents/
mkdir -p ~/.claude/hooks
cp swift-agent-team/.claude/hooks/swift-team-eval.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/swift-team-eval.sh
```

Then merge the hook into your `~/.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/Users/yourname/.claude/hooks/swift-team-eval.sh"
          }
        ]
      }
    ]
  }
}
```

Use the absolute path for global installs.

### Verify

Start Claude Code in your Swift project and type `/agents`. You should see:

```
/agents
  swift-lead
  concurrency-specialist
  foundation-models-specialist
  on-device-ai-architect
  mobile-a11y-specialist
  swiftui-specialist
  app-review-guardian
  testing-specialist
  swift-security-specialist
```

## Usage

### Automatic (via hook)

Just write code normally. The hook fires on every prompt and the swift-lead routes to the right specialists.

```
You: Build a settings screen with a toggle for notifications

Claude: [Hook fires, swift-lead activates]
        [swift-lead invokes swiftui-specialist, mobile-a11y-specialist]

        The settings screen uses @Observable for state, Toggle with
        proper accessibility label, Dynamic Type support, and
        .accessibilityHint describing what the toggle does...
```

### Manual (invoke directly)

```
/concurrency-specialist review the async code in NetworkService.swift
/foundation-models-specialist help me implement @Generable for recipe output
/on-device-ai-architect which model should I use for an iPhone 15 Pro?
/mobile-a11y-specialist audit the accessibility of ProfileView.swift
/swiftui-specialist review the navigation stack implementation
/swift-lead full review of the chat feature
/app-review-guardian check this app for App Store rejection risks
/testing-specialist write tests for the UserService
/swift-security-specialist audit how we store auth tokens
```

## What Each Agent Covers

### concurrency-specialist
- Swift 6.2 approachable concurrency (SE-0466, SE-0461, SE-0472)
- Actor isolation, @MainActor, nonisolated, @concurrent
- Sendable protocol, sending parameters (SE-0430)
- Structured concurrency: Task, TaskGroup, async let
- Actor reentrancy dangers
- AsyncSequence, AsyncStream, continuation bridging
- Common mistakes: blocking MainActor, unnecessary actors, semaphore deadlocks, missing cancellation

### foundation-models-specialist
- LanguageModelSession creation, instructions, transcripts
- @Generable macro for structured output
- @Guide constraints (description, range, anyOf, count, constant, regex)
- Tool protocol implementation
- 4096-token context window budgeting
- Prompt design best practices
- Guardrail handling and error recovery
- Model availability checking and graceful fallback

### on-device-ai-architect
- MLX Swift: model loading, streaming generation, GPU cache management
- llama.cpp: GGUF format, Swift bindings, quantization levels
- Core ML: model deployment, compute unit selection, async prediction
- Natural Language framework: NER, sentiment, tokenization
- Vision framework: OCR, classification, face detection
- Device-tier model selection (iPhone 12 through Mac Pro)
- Memory management: 60% RAM limit on iOS, background unloading
- Multi-backend fallback architecture

### mobile-a11y-specialist
- SwiftUI accessibility modifiers (labels, hints, values, traits)
- Element grouping (.combine, .ignore, .contain)
- .accessibilityRepresentation for custom controls
- Focus management with @AccessibilityFocusState
- Sheet/dialog focus return
- Custom actions and rotors
- Dynamic Type with @ScaledMetric and adaptive layouts
- 44x44pt minimum tap targets
- System preferences: Reduce Motion, Reduce Transparency, Increase Contrast, Bold Text
- Decorative content hiding

### swiftui-specialist
- @Observable vs ObservableObject (when to use which)
- State management: @State, @Bindable, @Environment, let
- NavigationStack and programmatic navigation
- View composition and custom ViewModifiers
- .task modifier for async data loading
- LazyVStack/LazyHStack for performance
- Common mistakes (wrong property wrappers, heavy body computation, index-based ForEach IDs)

### app-review-guardian
- Top rejection reasons and how to avoid them (2.1 Completeness, 2.3 Metadata, 4.0 Design, 5.1.1 Privacy)
- Privacy manifest (PrivacyInfo.xcprivacy) required API reason codes
- In-App Purchase rules (what requires IAP, what does not)
- Human Interface Guidelines compliance (navigation, modals, Dark Mode, Dynamic Type)
- Entitlement justification (camera, location, push, HealthKit, background modes)
- Widgets and Live Activities requirements
- App Tracking Transparency implementation
- EU Digital Markets Act considerations

### testing-specialist
- Swift Testing framework: @Test, @Suite, #expect, #require, confirmation
- Parameterized tests and custom tags
- Test scoping traits and serialized suites
- XCTest for UI testing and performance testing
- Page object pattern for UI test maintainability
- Protocol-based dependency injection for testable architecture
- Mock patterns and environment-based injection
- Deterministic async testing with clock injection
- Snapshot testing with swift-snapshot-testing (Dark Mode, Dynamic Type)
- Common mistakes: flaky async tests, shared mutable state, testing implementation instead of behavior

### swift-security-specialist
- Keychain Services: SecItemAdd, SecItemCopyMatching, SecItemUpdate, SecItemDelete
- kSecAttrAccessible values and when to use each
- Data Protection file encryption classes
- CryptoKit: AES-GCM, ChaChaPoly, SHA-256, HMAC, P256 signing, Curve25519 key agreement
- Secure Enclave key storage
- Biometric authentication (Face ID, Touch ID) with LocalAuthentication
- App Transport Security configuration and exception domains
- Privacy manifest (PrivacyInfo.xcprivacy) required API declarations
- Certificate pinning for sensitive API connections
- Secure coding: no logged secrets, memory clearing, input validation, path traversal prevention

## Using with A11y Agent Team

If you also use the [A11y Agent Team](https://github.com/taylorarndt/a11y-agent-team) for web accessibility, both can coexist. Install the Swift agents at the project level in your Swift projects and the A11y agents globally or in your web projects. The hooks are different and do not conflict.

## Configuration

### Character Budget

If agents stop loading silently, increase the budget:

```bash
export SLASH_COMMAND_TOOL_CHAR_BUDGET=50000
```

Add to your `~/.zshrc` or `~/.bashrc` to make it permanent.

## Project Structure

```
swift-agent-team/
  .claude/
    agents/
      swift-lead.md                  # Orchestrator
      concurrency-specialist.md      # Swift 6.2 concurrency
      foundation-models-specialist.md # Apple Foundation Models
      on-device-ai-architect.md      # MLX, llama.cpp, Core ML
      mobile-a11y-specialist.md      # iOS/macOS accessibility
      swiftui-specialist.md          # SwiftUI patterns
      app-review-guardian.md         # App Store review compliance
      testing-specialist.md          # Swift Testing, XCTest
      swift-security-specialist.md   # Security, Keychain, CryptoKit
    hooks/
      swift-team-eval.sh             # Hook (macOS/Linux)
      swift-team-eval.ps1            # Hook (Windows)
    settings.json                    # Example hook config
  LICENSE
  README.md
```

## Contributing

Found a gap? Open an issue or PR. Contributions welcome:

- Additional Swift evolution proposals coverage
- Framework-specific patterns (MapKit, HealthKit, StoreKit)
- watchOS and visionOS specialist knowledge
- Xcode build system and SPM best practices
- Performance profiling and optimization patterns

If you find this useful, please star the repo.

## License

MIT

## About the Author

Built by [Taylor Arndt](https://github.com/taylorarndt), a developer and accessibility specialist who uses assistive technology daily. I build AI tools that write code the way it should be written -- accessible, concurrent, and modern.
