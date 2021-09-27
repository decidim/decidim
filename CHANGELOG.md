# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

#### Unconfirmed access disabled by default
As per [\#8233](https://github.com/decidim/decidim/pull/8233), by default all participants must confirm their email account to sign in. Implementors can change this setting as a [initializer configuration](https://docs.decidim.org/en/configure/initializer/#_unconfirmed_access_for_users):

```ruby
Decidim.configure do |config|
  config.unconfirmed_access_for = 2.days
end
```

### Added
* [#8012](https://github.com/decidim/decidim/pull/8012) Participatory space to comments, to fix the statistics. Use
`rake decidim_comments:update_participatory_process_in_comments` to migrate existing comments to the new structure.

### Changed

### Fixed

### Removed

## Previous versions

Please check [release/0.25-stable](https://github.com/decidim/decidim/blob/release/0.25-stable/CHANGELOG.md) for previous changes.

#### Base64 images migration

PR [\#8250](https://github.com/decidim/decidim/pull/8250) Replaces the default base64 editor images attachment with the use of ActiveStorage attachments. Also adds a task to parse all editor contents and replace existing base64 images with attachments. The task parses all the attributes which can be edited from admin using the WYSIWYG editor. The task requires an argument with the email of an admin used to create EditorImage instances. To run this task execute:

```
rails decidim:active_storage_migrations:migrate_inline_images_to_active_storage[admin_email]
```
