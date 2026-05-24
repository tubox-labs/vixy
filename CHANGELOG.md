# Changelog

All notable public distribution changes to Vixy are documented here.

## [v0.1.0-beta.2] - 2026-05-24

Codename: Signal Lantern

### Added

- Added the beta.2 public release metadata and checksums.
- Added a PowerShell installer for Windows users.

### Changed

- Updated installer defaults for GitHub release asset downloads with a Veyra-hosted latest-version pointer.
- Updated the CLI release metadata to `v0.1.0-beta.2` and codename `Signal Lantern`.

### Fixed

- Fixed free-plan Veyra requests that could send oversized output-token budgets.
- Restored normal terminal text selection in interactive mode by keeping mouse reporting opt-in.

## [v0.1.0-beta.1] - 2026-05-22

Codename: Jolly Roger

### Added

- Added the first beta binary release channel.
- Added public installer, release metadata, and checksum documentation.
- Added source-free public support repository files.
- Added version metadata in the CLI output: version, commit, build date, and codename.

### Fixed

- Fixed ANSI color fragments such as `255m` and `256m` leaking into rendered chat text.
- Restored native terminal text selection in the TUI.
- Added an active-response placeholder telling users to press Esc to interrupt.
