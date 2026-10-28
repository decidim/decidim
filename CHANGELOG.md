# Changelog

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

### Fixed

- **decidim-core**: Add the missing reciprocal `has_many` associations on `Decidim::Organization` (`action_logs`, `content_blocks`, `contextual_help_sections`, `editor_images`, `identities`, `newsletters`, `searchable_resources`, `share_tokens`, `short_links`). Destroying an organization now cascades the deletion of these records, which previously stayed orphaned.
- **decidim-core**: Add the missing reciprocal associations on `Decidim::UserBaseEntity` and `Decidim::User` (`action_logs`, `amendments`, `authorization_transfers`, `authorizations`, `badge_scores`, `editor_images`, `members`, `messages`, `newsletters`, `participations`, `receipts`, `reports`, `share_tokens`, `source_transfers`, `user_moderation`, `user_reports_made`). Destroying a user now cascades the deletion of these records, which previously stayed orphaned. `user_reports_made` reports the records a user has created, as `user_reports` already reports the records about the user.

...

## Previous versions

Please check [0.32-stable](https://github.com/decidim/decidim/blob/release/0.32-stable/CHANGELOG.md) for previous changes.
