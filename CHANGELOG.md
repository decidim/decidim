# Changelog

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

### Fixed

- **decidim-core**: Add the missing reciprocal `has_many` associations on `Decidim::Organization` (`action_logs`, `content_blocks`, `contextual_help_sections`, `editor_images`, `identities`, `newsletters`, `searchable_resources`, `share_tokens`, `short_links`). Destroying an organization now cascades the deletion of these records, which previously stayed orphaned.

...

## Previous versions

Please check [0.32-stable](https://github.com/decidim/decidim/blob/release/0.32-stable/CHANGELOG.md) for previous changes.
