# Upgrade plan

## Current state

Score: 3/10 (was 1/10) — domain logic + XCTest suite and honest CI exist, but
nothing has been compiled yet (no Swift toolchain was available when this was
written) and the UI is still a placeholder.

## Backlog

- P0: Confirm the macOS CI job is green (`swift build` + `swift test`); fix any
  compile errors it reports first.
- P0: Add an Xcode app target (`@main`) that hosts `LabUI`, and build screens on
  top of `LabCore` (an `@Observable` model wrapping the core API).
- P1: Experiment list + detail UI with a CI chart per variant (Swift Charts).
- P2: Exact t-distribution p-values for small samples; sequential-testing caveats in the UI.
- P2: Add a Linux CI job that runs `swift test --filter LabCoreTests` after
  making the UI target conditional, to keep the core portable.

## Done in this pass

- Split the package into `LabCore` (Foundation-only logic), `LabUI` (existing
  SwiftUI shell) and `LabCoreTests` (6 XCTest cases).
- Removed `@main` from the library target (it belongs in an app target).
- CI: removed `|| echo` / `|| true` so build and test failures are visible.
- README now states what is verified and what is not.
- New Swift sources were syntax-checked with tree-sitter-swift only.
