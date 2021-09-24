# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

## Upgrade Notes

- **decidim-core**: Add support for Visual Code Remote Containers and GitHub Codespaces [\6638](https://github.com/decidim/decidim/pull/6638)

### Changed

- **Bump Ruby to v2.7**

We've bumped the minimum Ruby version to 2.7.1, thanks to 2 PRs:

- [\#6320](https://github.com/decidim/decidim/pull/6320)
- [\#6522](https://github.com/decidim/decidim/pull/6522)

- **Comments no longer use react**

As per [\#6498](https://github.com/decidim/decidim/pull/6498), the comments component is no longer implemented with the react component. In case you had customized the react component, it will still work as you would expect as the GraphQL API has not disappeared anywhere. You should, however, gradually migrate to the "new way" (Trailblazer cells) in order to ensure compatibility with future versions too.

- **Consultations module deprecation**

As the new `Votings` module is being developed and will eventually replace the `Consultations` module, the latter enters the deprecation phase.

### Added

- **decidim-meetings**: Add functionality to enable/disable registration code [\#6698](https://github.com/decidim/decidim/pull/6698)
- **decidim-core**: Adding functionality to report users [\#6696](https://github.com/decidim/decidim/pull/6696)
- **decidim-admin**: Adding possibility of unreporting users [\#6696](https://github.com/decidim/decidim/pull/6696)
- **decidim-core**: Add support for Visual Code Remote Containers and GitHub Codespaces [\6638](https://github.com/decidim/decidim/pull/6638)
### Notes
#### Statistics change 
As per [\#8147](https://github.com/decidim/decidim/pull/8147), the participants stats will not take into account deleted and blocked users.   

#### Webpacker migration
As per [#7464](https://github.com/decidim/decidim/pull/7464), [#7733](https://github.com/decidim/decidim/pull/7733) Decidim has been upgraded to use Webpacker to manage its assets. It's a huge change that requires some updates in your applications. Please refer to the guide [Migrate to Webpacker an instance app](https://github.com/decidim/decidim/blob/develop/docs/modules/develop/pages/guide_migrate_webpacker_app.adoc) and follow the steps described.

#### Improved menu api
As per [\#7368](https://github.com/decidim/decidim/pull/7368), [\#7382](https://github.com/decidim/decidim/pull/7382) the entire admin structure has been migrated from menus being rendered in partials, to the existing menu structure. Before, this change adding a new menu item to an admin submenu required partial override.

As per [\#7545](https://github.com/decidim/decidim/pull/7545) the menu api has been enhanced to support removal of elements and reordering. All the menu items have an identifier that allow any developer to interact without overriding the entire menu structure. As a result of this change, the old ```menu.item``` function has been deprecated in favour of a more verbose version ```menu.add_item ```, of which first argument is the menu identifier.

Example on adding new elements to a menu:
```ruby
Decidim.menu :menu do |menu|
  menu.add_item :root,
                I18n.t("menu.home", scope: "decidim"),
                decidim.root_path,
                position: 1,
                active: :exclusive

  menu.add_item :pages,
                I18n.t("menu.help", scope: "decidim"),
                decidim.pages_path,
                position: 7,
                active: :inclusive
end
```

Example Customizing the elements of a menu:

```ruby
Decidim.menu :menu do |menu|
  # Completely remove a menu item
  menu.remove_item :my_item

  # Change the items order
  menu.move :root, after: :pages
  # alternative
  menu.move :pages, before: :root
end
```

#### Meetings merge minutes and close actions

With changes introduced in [\#7968](https://github.com/decidim/decidim/pull/7968) the `Decidim::Meetings::Minutes` model and related table are removed and the attributes of the previously existing minutes are migrated to `Decidim::Meetings::Meeting` model in the `closing_report`, `video_url`, `audio_url` and `closing_visible` columns. These are the different results of the merge according to the initial data:

* It there was no minutes data and the meeting was not closed nothing changes
* If there was no minutes data and the meeting was closed, the meeting remains closed with the `closing_visible` attribute to true. In this way the closing data will remain visible.
* If there was minutes data and the meeting was not closed, the meeting is closed and the minutes `description` value is copied to the meeting `closing_report`, the `video_url` and `audio_url` minutes attributes values are copied to the respective meeting attributes and the minutes `visible` attribute value is copied to the meeting `closing_visible` attribute.
* If there was minutes data and the meeting was closed, the meeting remains closed and the meeting `closing_report` value remains if present. Elsewere the minutes `description` value is copied to the meeting `closing_report`. the `video_url` and `audio_url` minutes attributes values are copied to the respective meeting attributes and the minutes `visible` attribute value is copied to the meeting `closing_visible` attribute. In this case the visibility of closing report may change to false if there was a minutes with `visible` set to false.

Please, note that if there was previously `minutes_description` and `closing_report` data for a meeting, after applying the changes of this release, the `minutes_description` data will be lost.

If there is previous activity of creation or edition of minutes, `Decidim::ActionLog` instances and an associated `PaperTrail::Version` instance for each one will have been created pointing to these elements in their polymorphic associations. To avoid errors, the migration includes changing those associations to point to the meeting and changing the action to `close` in the action log items. This change is not reversible

#### New Job queues

PR [\#7986](https://github.com/decidim/decidim/pull/7986) splits some jobs from the `:default` queue to two new queues:

- `:exports`
- `:translations`

If your application uses Sidekiq and you set a manual configuration file, you'll need to update it to add these two new queues. Otherwise these queues [will never run](https://github.com/mperham/sidekiq/issues/4897).

#### User groups in global search

PR [\#8061](https://github.com/decidim/decidim/pull/8061) adds user groups to the global search and previously existing groups need to be indexed, otherwise it won't be available as search results. Run in a rails console or create a migration with:

```ruby
  Decidim::UserGroup.find_each(&:try_update_index_for_search_resource)
```

Please be aware that it could take a while if your database has a lot of groups.

#### ActiveStorage migration

PR [\#7598](https://github.com/decidim/decidim/pull/7598) migrates attachments from `CarrierWave` to `ActiveStorage`. There was a migration to move some organization fields to a content block (decidim-core/db/migrate/20180810092428_move_organization_fields_to_hero_content_block.rb) including the use of `CarrierWave` to migrate an image. This part has been removed. Please, if your application has the old migration replace its content with the changed file to avoid errors in the future because `CarrierWave` dependency will be eliminated.

PR[\#7902](https://github.com/decidim/decidim/pull/7902) provides a task to migrate existing `CarrierWave` attachment files to `ActiveStorage`. Keep in mind that the `ActiveStorage` migration PRs don't delete `CarrierWave` attachments and preserve the columns used by it. To guarantee the access to `CarrierWave` files the gem must be installed (the current core engine maintains that dependency) and configured as it was before the migration to `ActiveStorage`. The task downloads each file using `CarrierWave` uploaders and uploads it again using `ActiveStorage`. This PR provides 2 tasks:

* The task to copy files to `ActiveStorage`. The task generates a log file in `log/` with a line with the result of each migration. The result can be:
  * `[OK] Migrated - [OK] Checksum identical` if the file was copied successfully and the checksums of the origin and copied files are identical. This should be the expected result.
  * `[KO] Migrated - [KO] Checksum different` if the file was copied successfully but the checksums are different.
  * `[SKIP] Migrated` The migration was skipped because the task detected that there was already an existing file attached with `ActiveStorage` (the other task allows us to check if `CarrierWave` and `ActiveStorage` files are identical.
  * `[ERROR] Exception` if any error prevents the migration of the file. The error message is included in the result.

The task also creates a mapping of paths in `tmp/attachment_mappings.csv` with the id of the instance, the name of the `CarrierWave` attribute and its origin path and the destination path in `ActiveStorage`. To run this task execute:

```
rails decidim:active_storage_migrations:migrate_from_carrierwave_to_active_storage
```

Note that the migration generates instances of `ActiveStorage::Attachment` in case they are not yet created. To repeat the migration from scratch it would be enough to delete all `ActiveStorage::Attachment` items (be careful not to delete attachments that were created earlier with `ActiveStorage`)


* The task to check migration and compare files. This task finds each `CarrierWave` attachment file and looks for corresponding `ActiveStorage` attachment and compares them if possible. The result for each attachment can be:
  * `[OK] Checksum identical` if both files exist and checkums are identical.
  * `[KO] Checksum different` if both files exist but checkums are different.
  * `[SKIP] Pending migration` if the `ActiveStorage` file is not present.
  * `[ERROR] Exception` if there is any error in the checking process. The error message is included in the result.


To run this task execute:

```
rails decidim:active_storage_migrations:check_migration_from_carrierwave_to_active_storage
```

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
