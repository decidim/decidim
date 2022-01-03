# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

#### Register assets paths
To prevent Zeitwerk from trying to autoload classes from the `app/packs` folder, it's necesary to register these paths for each module and for the application using the method `Decidim.register_assets_path` on initializers. This is explained in the webpacker migration guides for [applications](https://github.com/decidim/decidim/blob/develop/docs/modules/develop/pages/guide_migrate_webpacker_app.adoc#help-decidim-to-know-the-applications-assets-folder) and [modules](https://github.com/decidim/decidim/blob/develop/docs/modules/develop/pages/guide_migrate_webpacker_module.adoc#help-decidim-to-know-the-modules-assets-folder)), and was implemented in [\#8449](https://github.com/decidim/decidim/pull/8449).

#### Unconfirmed access disabled by default
As per [\#8233](https://github.com/decidim/decidim/pull/8233), by default all participants must confirm their email account to sign in. Implementors can change this setting as a [initializer configuration](https://docs.decidim.org/en/configure/initializer/#_unconfirmed_access_for_users):

```ruby
Decidim.configure do |config|
  config.unconfirmed_access_for = 2.days
end
```

#### User workflows change to prevent user enumeration attacks

Until now it was possible to see if an email account was registered in Decidim, by using features like "Forgot your password", as the response changed if the email existed ("`You will receive an email with instructions on how to reset your password in a few minutes`") that's different to a non-existing user account ("`could not be found. Did you sign up previously?`"). This allows User Enumration attacks, where a malicious actor can check if anyone has an acount in the platform. As per [\#8537](https://github.com/decidim/decidim/pull/8537), anyone has the same answer always "`If your email address exists in our database, you will receive a password recovery link at your email address in a few minutes`".

#### Blocked user in global search

PR [\#8658](https://github.com/decidim/decidim/pull/8658) Blocked users are present in global search, to update the search and make them disappear, Run in a rails console or create a migration with:

```ruby
  Decidim::User.find_each(&:try_update_index_for_search_resource)
```

Please be aware that it could take a while if your database has a lot of Users.

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

#### Custom icons new uploader

PR [\#8645](https://github.com/decidim/decidim/pull/8645) we now only allow PNG images at Favicon so we can provide higher quality versions to mobile devices.
