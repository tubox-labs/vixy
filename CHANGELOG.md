# Changelog

All notable public distribution changes to Vixy are documented here.

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
