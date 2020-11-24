# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

## Upgrade Notes

- **Bump Ruby to v2.7**

We've bumped the minimum Ruby version to 2.7.1, thanks to 2 PRs:

- [\#6320](https://github.com/decidim/decidim/pull/6320)
- [\#6522](https://github.com/decidim/decidim/pull/6522)

- **Comments no longer use react**

As per [\#6498](https://github.com/decidim/decidim/pull/6498), the comments component is no longer implemented with the react component. In case you had customized the react component, it will still work as you would expect as the GraphQL API has not disappeared anywhere. You should, however, gradually migrate to the "new way" (Trailblazer cells) in order to ensure compatibility with future versions too.

### Added

- **decidim-core**: Adding functionality to report users [\#6696](https://github.com/decidim/decidim/pull/6696)
- **decidim-admin**: Adding possibility of unreporting users [\#6696](https://github.com/decidim/decidim/pull/6696)
- **decidim-core**: Add support for Visual Code Remote Containers and GitHub Codespaces [\6638](https://github.com/decidim/decidim/pull/6638)

### Changed

### Fixed

### Removed

- **decidim-core**: Remove legacy 'show statistics' checkbox in Appearance. [\#6575](https://github.com/decidim/decidim/pull/6575)
- **decidim-system**: Remove migration `FillSmtpFromEmail` [\#6908](https://github.com/decidim/decidim/pull/6908)

## Previous versions

Please check [release/0.23-stable](https://github.com/decidim/decidim/blob/release/0.23-stable/CHANGELOG.md) for previous changes.
