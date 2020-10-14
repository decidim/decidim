# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

### Added

### Changed

- **Settings `maximum_attachment_size` and `maximum_avatar_size` moved to organization system settings**

As per [\#6377](https://github.com/decidim/decidim/pull/6377), the `maximum_attachment_size` and `maximum_avatar_size` settings will no longer have any effect if configured through the Decidim initializer configurations. Instead, these are now configured from the organization system settings at the `/system` path of your installation.

Note that if you had these previously configured in the initializer, these previous settings have been automatically migrated to all organizations in your installation after running the Decidim upgrade migrations.

- **Comments no longer use react**

As per [\#6498](https://github.com/decidim/decidim/pull/6498), the comments component is no longer implemented with the react component. In case you had customized the react component, it will still work as you would expect as the GraphQL API has not disappeared anywhere. You should, however, gradually migrate to the "new way" (Trailblazer cells) in order to ensure compatibility with future versions too.

### Fixed

### Removed

- **decidim-core**: Remove legacy 'show statistics' checkbox in Appearance. [\#6575](https://github.com/decidim/decidim/pull/6575)

## Previous versions

Please check [release/0.23-stable](https://github.com/decidim/decidim/blob/release/0.23-stable/CHANGELOG.md) for previous changes.
