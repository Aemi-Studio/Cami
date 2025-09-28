# Repository Guidelines

## Project Structure & Refactoring Roadmap
Drive the codebase toward a modular Swift 6.2 workspace. Consolidate runtime features into `Sources/App` with feature folders (`Sources/App/Features/Calendar`, etc.), surface shared domain logic in `Sources/Shared/Core`, and isolate cross-cutting services (permissions, storage, analytics) under `Sources/Shared/Services`. Move widget code into `Sources/Widgets` with shared models imported via Swift packages, and keep assets in `Resources/{App,Widgets}`. Treat existing `Cami/`, `Multiplatform/`, and `CamiWidget/` directories as migration sources—extract functionality into the new modules incrementally while deleting legacy files as they are replaced.

## Build, Test, and Development Commands
- `xcodebuild -scheme Cami -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build SWIFT_VERSION=6.2` validates the app against the latest SDKs.
- `xcodebuild -scheme CamiWidgetExtension -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build SWIFT_VERSION=6.2` ensures widget targets stay in sync.
- `swift build --configuration release --build-tests` (once `Package.swift` lands) gives a reproducible pipeline build.
- `swiftlint lint --strict` and `periphery scan --config .periphery.yml` gate style and dead code during refactors.

## Coding Style, Architecture & Naming
Adopt SOLID, DRY, KISS, LoD, and composition-over-inheritance in every module. Default to actors or `@Observable` view models, isolate state via dependency-injected protocols, and embrace async/await instead of GCD. Use 4-space indentation, wrap lines at 100 characters, and name types UpperCamelCase (`DailyFocusView`), properties lowerCamelCase (`eventStore`), and SwiftUI previews `<Type>Preview`. Keep files focused: one primary type per file plus extensions in `Extensions/`. All UI must respect Apple HIG and Dieter Rams principles—minimal surfaces, accessible typography, and dynamic type compliance.

## Testing Guidelines
Only use Swift Testing suites. Create mirrors of each module under `Tests/<ModuleName>Tests` with `@Suite` declarations and descriptive case names (`testTimelineLoadsWithin200ms`). Prefer deterministic async checks via `#expect` and `await`. Run suites with `xcodebuild test -scheme Cami -destination 'platform=iOS Simulator,name=iPhone 16 Pro'` (Xcode 16+ executes Swift Testing by default) or `swift test --enable-swift-testing` once the package layout is complete. Target >80% coverage on shared logic before approvals.

## Commit & Pull Request Guidelines
Write concise, Title Case commit subjects that capture intent (`Adopt SwiftData Actor Store`). Each PR must explain the architectural move, reference related follow-up tasks, attach before/after captures for UI, and document testing (including Swift Testing command output). Verify lint, builds, and relevant periphery scans before requesting review. Flag any remaining legacy modules so reviewers can prioritize subsequent refactors.

## UX & Interaction Principles
Prototype with Apple design templates, prioritize clarity over ornamentation, and validate adaptive layouts on compact and regular sizes. Prefer system components (SF Symbols, system colors) and ensure interactions remain performant at 120Hz. When introducing new flows, include accessibility notes and VoiceOver copy in the PR description.
