# Lab — Mobile

## Template copy

This repo is one of the name-substituted SwiftUI template copies in
`bookchaowalit-mobile`: it shares the SwiftPM layout (`<Name>Core` +
`<Name>UI` + XCTest target), the placeholder tab shell and the CI of the
canonical template, [`bookchaowalit-mobile/marketing-linktree-mobile`](https://github.com/bookchaowalit-mobile/marketing-linktree-mobile).
Only the small `Core` domain module differs. Consolidation or archiving is
pending owner decision D5 (BD-033), see
`repository-catalog/portfolio/MOBILE-CONSOLIDATION-2026-10.md` in solo-empire.

CI (`.github/workflows/build.yml`): `swift build` + `swift test` on macOS 14
with Xcode 15.4 (Swift 5.10), fail-closed, plus the shared `security.yml`
scans (gitleaks, Semgrep, OSV-Scanner, Trivy) from `platform-ci-workflows` v1.1.1.

SwiftUI app for **Lab** — run and log small product experiments.

Part of [Chaowalit Greepoke](https://bookchaowalit.com)'s 101 Portfolio Projects.

## Status

This is a Swift package, not yet a shippable app:

- `Sources/LabCore` — Foundation-only domain logic, unit-tested in
  `Tests/LabCoreTests` (XCTest).
- `Sources/LabUI` — SwiftUI tab shell (Home / Explore / Profile). It does not
  use `LabCore` yet, and there is no Xcode app target (`@main`) yet.

The code has **not been compiled outside CI** (it was written without a Swift
toolchain); the macOS CI job is the first real build. See
[docs/UPGRADE-PLAN.md](docs/UPGRADE-PLAN.md).

## Core features (`LabCore`)

- Experiments with a hypothesis, named variants and recorded measurements (non-finite values rejected)
- Summary statistics: mean, sample standard deviation, standard error, 95% confidence interval
- Variant comparison: lift %, Welch's t statistic, and a verdict (`needsMoreData` below 30 samples, `noClearDifference` when |t| < 1.96, otherwise `better`/`worse` depending on whether higher is better)

## Tech Stack

- **UI:** SwiftUI (iOS 17+ / macOS 14+)
- **Language:** Swift 5.10
- **Tests:** XCTest via SwiftPM

## Getting Started

```bash
swift build
swift test          # runs LabCoreTests
open Package.swift  # opens in Xcode 15+
```

CI (`.github/workflows/build.yml`, macOS 14) runs `swift build` and
`swift test`; failures fail the workflow.

## Related

- **Frontend:** [bookchaowalit-website/lab-frontend](https://github.com/bookchaowalit-website/bookchaowalit-lab-frontend)
- **Portfolio:** [bookchaowalit.com](https://bookchaowalit.com)

## License

MIT
