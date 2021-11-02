# Change Log
## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

### Added

### Changed

### Fixed

### Removed

## [0.25.1](https://github.com/decidim/decidim/tree/v0.25.1)

### Added

#### Register assets paths
To prevent Zeitwerk from trying to autoload classes from the `app/packs` folder, it's necesary to register these paths for each module and for the application using the method `Decidim.register_assets_path` on initializers. This is explained in the webpacker migration guides for [applications](https://github.com/decidim/decidim/blob/develop/docs/modules/develop/pages/guide_migrate_webpacker_app.adoc#help-decidim-to-know-the-applications-assets-folder) and [modules](https://github.com/decidim/decidim/blob/develop/docs/modules/develop/pages/guide_migrate_webpacker_module.adoc#help-decidim-to-know-the-modules-assets-folder)), and was implemented in [\#8449](https://github.com/decidim/decidim/pull/8449).

#### Unconfirmed access disabled by default
As per [\#8233](https://github.com/decidim/decidim/pull/8233), by default all participants must confirm their email account to sign in. Implementors can change this setting as a [initializer configuration](https://docs.decidim.org/en/configure/initializer/#_unconfirmed_access_for_users):

### Changed

Nothing.

### Fixed

- **decidim-proposals**: Backport: Any user can access proposal's pages representing the "create a proposal" steps (#8390) [\#8407](https://github.com/decidim/decidim/pull/8407)
- Backport "Increase text contrast in current phase of a participatory process" [\#8436](https://github.com/decidim/decidim/pull/8436)
- **decidim-core**: Backport "Include only public entities in the following page" to 0.25 [\#8406](https://github.com/decidim/decidim/pull/8406)
- **decidim-generators**: Backport "Fix railties requirements on created applications" [\#8439](https://github.com/decidim/decidim/pull/8439)
- **decidim-blogs**: Backport "Add missing translations" [\#8441](https://github.com/decidim/decidim/pull/8441)
- **decidim-core**: Backport "Fix javascript exception when geocoding proposals is disabled" [\#8437](https://github.com/decidim/decidim/pull/8437)
- **decidim-core**: Force Rails version to 6.0 [\#8440](https://github.com/decidim/decidim/pull/8440)
- Backport "Fix CVE-2021-41136" [\#8443](https://github.com/decidim/decidim/pull/8443)
- **decidim-comments**: Backport "Refresh comments component after updating" to v0.25 [\#8446](https://github.com/decidim/decidim/pull/8446)
- **decidim-core**: Backport "Fix webpacker issue when using zeitwerk" to 0.25 [\#8447](https://github.com/decidim/decidim/pull/8447)
- **decidim-core**: Backport "Improve Zeitwerk assets paths to ignore" to 0.25 [\#8454](https://github.com/decidim/decidim/pull/8454)

### Improved

- **decidim-core**: Backport "Enforce redirects to include the organization host" to 0.25 [\#8405](https://github.com/decidim/decidim/pull/8405)
- **decidim-core**: Backport: Disallow redirection to the host when performing redirect_back [\#8402](https://github.com/decidim/decidim/pull/8402)
- **decidim-core**: Backport "Update omniauth gem and dependencies" [\#8442](https://github.com/decidim/decidim/pull/8442)

### Removed

Nothing.

### Developer improvements

- Backport "Fix railties requirements on created applications" [\#8439](https://github.com/decidim/decidim/pull/8439)
- Backport "Fixing generator webpacker issues" [\#8438](https://github.com/decidim/decidim/pull/8438)

## [0.25.0](https://github.com/decidim/decidim/tree/v0.25.0)

### Added

Nothing.

### Changed

Nothing.

### Fixed

- **decidim-debates**: Backport: Fix title meta tag for debates (#8323) [\#8350](https://github.com/decidim/decidim/pull/8350)
- **decidim-proposals**: Backport: Fix machine translated similarity for proposals (#8098) [\#8338](https://github.com/decidim/decidim/pull/8338)
- **decidim-conferences**: Backport "Fix error when accessing the meetings of a conference with speakers related" [\#8371](https://github.com/decidim/decidim/pull/8371)
- **decidim-admin**: Backport "Do not block registered users with InviteUserAgain" to v0.25 [\#8366](https://github.com/decidim/decidim/pull/8366)
- **decidim-proposals**: [Backport] Fix UserAnswersSerializer for CSV exports to v0.25 [\#8370](https://github.com/decidim/decidim/pull/8370)
- **decidim-meetings**: Backport "Define localized fields in Decidim::Meetings:DiffRenderer" to v0.25 [\#8384](https://github.com/decidim/decidim/pull/8384)

### Improved

- **decidim-comments**: Backport "Ignore errors during comments migration task" [\#8365](https://github.com/decidim/decidim/pull/8365)
- **decidim-conferences**: Backport "Fix details on conference speakers: affiliation order, personal URL link, seeds and more info link" to v0.25 [\#8382](https://github.com/decidim/decidim/pull/8382)

### Removed

Nothing.

### Developer improvements

Nothing.

## [0.25.0.rc4](https://github.com/decidim/decidim/tree/v0.25.0.rc4)

### Added

Nothing.

### Changed

Nothing.

### Fixed

Nothing.

### Improved

Nothing.

### Removed

Nothing.

### Developer improvements

- Backport "Update NPM version" [\#8344](https://github.com/decidim/decidim/pull/8344)

## [0.25.0.rc3](https://github.com/decidim/decidim/tree/v0.25.0.rc3)

### Added

Nothing.

### Changed

Nothing.

### Fixed

- **decidim-debates**: Backport "Fix "last comment by" when commenter is a user group" [\#8337](https://github.com/decidim/decidim/pull/8337)
- **decidim-comments**: Backport "Fix issues with dynamic comments polling" to v0.25 [\#8340](https://github.com/decidim/decidim/pull/8340)
- **decidim-core**: Backport "Remove npm decidim packages with dependencies from other decidim packages" [\#8339](https://github.com/decidim/decidim/pull/8339)

### Improved

Nothing.

### Removed

Nothing.

### Developer improvements

- Backport "Fix CSS validation tests caused by a bug on the validation service" [\#8325](https://github.com/decidim/decidim/pull/8325)
- Backport "Remove npm decidim packages with dependencies from other decidim packages" [\#8339](https://github.com/decidim/decidim/pull/8339)

## [0.25.0.rc2](https://github.com/decidim/decidim/tree/v0.25.0.rc2)

### Upgrade Notes

#### Comments statistics change

* [#8012](https://github.com/decidim/decidim/pull/8012) Participatory space to comments, to fix the statistics. Use
`rake decidim_comments:update_participatory_process_in_comments` to migrate existing comments to the new structure.

### Added

Nothing.

### Changed

Nothing.

### Fixed

- Backport "Fix webpacker dependency lock" to v0.25 [\#8289](https://github.com/decidim/decidim/pull/8289)
- Backport "Fix NPM packages versioning during release process" [\#8284](https://github.com/decidim/decidim/pull/8284)
- **decidim-accountability**: Backport "Fix accountability notifications proposal title" to v0.25 [\#8287](https://github.com/decidim/decidim/pull/8287)
- Backport "Fix Luxembourgish locale" to v0.25 [\#8282](https://github.com/decidim/decidim/pull/8282)
- **decidim-debates**, **decidim-meetings**, **decidim-proposals**: Backport - Fix characters not encoded in title to 0.25 [\#8292](https://github.com/decidim/decidim/pull/8292)
- **decidim-core**: Backport "Fix invalid i18n values for diff changeset" to v0.25 [\#8305](https://github.com/decidim/decidim/pull/8305)
- **decidim-meetings**: Backport "Fix live? missing method delegation in online_meeting cell" to v0.25 [\#8309](https://github.com/decidim/decidim/pull/8309)
- **decidim-comments**: Backport: Fix statistics in Comments (#8012) [\#8316](https://github.com/decidim/decidim/pull/8316)
- **decidim-core**: Backport: [CVE-2021-22942] Possible Open Redirect in Host Authorization Middleware [\#8320](https://github.com/decidim/decidim/pull/8320)
- **decidim-core**: Backport "Remove unnecessary spacer from external link indicator" to v0.25 [\#8319](https://github.com/decidim/decidim/pull/8319)
- Backport "Fix CSS validation tests caused by a bug on the validation service" [\#8325](https://github.com/decidim/decidim/pull/8325)
- **decidim-core**: Backport "Fix missing icons after CORS" to v0.25 [\#8318](https://github.com/decidim/decidim/pull/8318)
- Backport "Update foundation-sites to 6.7.0 for better Dart Sass compatibility" to v0.25 [\#8300](https://github.com/decidim/decidim/pull/8300)


### Removed

Nothing.

## [0.25.0.rc1](https://github.com/decidim/decidim/tree/v0.25.0.rc1)

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

### Added

- **decidim-conferences**, **decidim-core**, **decidim-meetings**: Add CSS selectors to emails to improve design customization [\#7493](https://github.com/decidim/decidim/pull/7493)
- **decidim-elections**: Audit vote [\#7442](https://github.com/decidim/decidim/pull/7442)
- **decidim-core**: Let installations delay TranslatorJob initialization [\#7507](https://github.com/decidim/decidim/pull/7507)
- **decidim-budgets**: Add share modal to budgets [\#7519](https://github.com/decidim/decidim/pull/7519)
- **decidim-elections**: Add Votings landing page layout [\#7440](https://github.com/decidim/decidim/pull/7440)
- **decidim-assemblies**, **decidim-conferences**, **decidim-consultations**, **decidim-core**, **decidim-elections**, **decidim-participatory processes**, **decidim-sortitions**, **decidim-surveys**: Add statistics cell to votings landing page and reuse it in other places [\#7413](https://github.com/decidim/decidim/pull/7413)
- **decidim-elections**: Add support for ElectionGuard voting scheme [\#7454](https://github.com/decidim/decidim/pull/7454)
- **decidim-core**: Replace xls with xlsx [\#7421](https://github.com/decidim/decidim/pull/7421)
- **decidim-blogs**: Create blog posts as user group [\#7425](https://github.com/decidim/decidim/pull/7425)
- **decidim-meetings**: Custom message in meeting registration email [\#7416](https://github.com/decidim/decidim/pull/7416)
- **decidim-elections**: See remaining time for voting in election [\#7611](https://github.com/decidim/decidim/pull/7611)
- **decidim-elections**: Mockup design for Check participating rights in a voting [\#7623](https://github.com/decidim/decidim/pull/7623)
- **decidim-core**: Add proper ARIA roles for header and footer [\#7658](https://github.com/decidim/decidim/pull/7658)
- **decidim-comments**: Remove custom focus outlines/backgrounds from the comments elements [\#7656](https://github.com/decidim/decidim/pull/7656)
- **decidim-core**: Add reason fieldset to the report modal for accessibility [\#7665](https://github.com/decidim/decidim/pull/7665)
- **decidim-comments**, **decidim-core**: Add aria-atomic="true" to the alert role elements [\#7666](https://github.com/decidim/decidim/pull/7666)
- **decidim-meetings**: Display map and link for hybrid meetings [\#7065](https://github.com/decidim/decidim/pull/7065)
- **decidim-budgets**, **decidim-comments**, **decidim-core**: Use comments counter cache instead of additional query [\#7627](https://github.com/decidim/decidim/pull/7627)
- **decidim-admin**, **decidim-core**, **decidim-system**: Add accessibility labels to the `<nav>` menus [\#7709](https://github.com/decidim/decidim/pull/7709)
- **decidim-elections**: Evote - Polling station officers flow [\#7705](https://github.com/decidim/decidim/pull/7705)
- **decidim-elections**: Improve vote flow [\#7682](https://github.com/decidim/decidim/pull/7682)
- **decidim-elections**: Feat/evote count votes [\#7769](https://github.com/decidim/decidim/pull/7769)
- **decidim-elections**: Admin voting census original load (csv) [\#7591](https://github.com/decidim/decidim/pull/7591)
- **decidim-elections**: Evote - identify with access code [\#7740](https://github.com/decidim/decidim/pull/7740)
- **decidim-elections**: Evote election log [\#7757](https://github.com/decidim/decidim/pull/7757)
- **decidim-elections**: Generate votings access codes [\#7704](https://github.com/decidim/decidim/pull/7704)
- **decidim-elections**: Mockup design for Remaining time in voting [\#7597](https://github.com/decidim/decidim/pull/7597)
- **decidim-api**: Add categories parent filter to API [\#7609](https://github.com/decidim/decidim/pull/7609)
- **decidim-core**: Fix map accessibility issue - Map bottom position missing label [\#7763](https://github.com/decidim/decidim/pull/7763)
- **decidim-elections**: Add Voting Ballot Styles [\#7779](https://github.com/decidim/decidim/pull/7779)
- **decidim-elections**: Census access codes exportation flow [\#7756](https://github.com/decidim/decidim/pull/7756)
- **decidim-core**: Add copy to clipboard feature to share links [\#7697](https://github.com/decidim/decidim/pull/7697)
- **decidim-elections**: Evote - onboarding workflow [\#7758](https://github.com/decidim/decidim/pull/7758)
- **decidim-elections**: Add Ballot Style to Census Datum [\#7788](https://github.com/decidim/decidim/pull/7788)
- **decidim-admin**, **decidim-assemblies**, **decidim-participatory processes**: Let admins filter participatory space private users [\#7817](https://github.com/decidim/decidim/pull/7817)
- **decidim-initiatives**: Show initiative image in homepage [\#7824](https://github.com/decidim/decidim/pull/7824)
- **decidim-elections**: Identify online voters [\#7777](https://github.com/decidim/decidim/pull/7777)
- **decidim-admin**, **decidim-assemblies**, **decidim-participatory processes**: Let admins disable participatory space filters [\#7819](https://github.com/decidim/decidim/pull/7819)
- **decidim-elections**: Identify in person voters [\#7828](https://github.com/decidim/decidim/pull/7828)
- **decidim-elections**: Ask again for access code [\#7803](https://github.com/decidim/decidim/pull/7803)
- **decidim-elections**: Conditionally render questions in election booth [\#7822](https://github.com/decidim/decidim/pull/7822)
- **decidim-proposals**: Improve proposals import options [\#7669](https://github.com/decidim/decidim/pull/7669)
- Accessibility tool for development environments [\#7810](https://github.com/decidim/decidim/pull/7810)
- **decidim-elections**: Onboarding workflow after voting [\#7839](https://github.com/decidim/decidim/pull/7839)
- **decidim-elections**: Give admin panel access to monitoring committee members [\#7843](https://github.com/decidim/decidim/pull/7843)
- **decidim-elections**: Store election verifiable results data in election [\#7882](https://github.com/decidim/decidim/pull/7882)
- **decidim-comments**: Authorizable comment action for proposals [\#6916](https://github.com/decidim/decidim/pull/6916)
- **decidim-meetings**: Use WYSIWYG editor for registration email custom content [\#7930](https://github.com/decidim/decidim/pull/7930)
- **decidim-core**: Add serializer customization via listener [\#7484](https://github.com/decidim/decidim/pull/7484)
- **decidim-core**: Add cache layer for ActivityCell boxes [\#7967](https://github.com/decidim/decidim/pull/7967)
- **decidim-meetings**: Show confirmation modal when leaving a meeting [\#7970](https://github.com/decidim/decidim/pull/7970)
- **decidim-meetings**: Display meetings count in directory page [\#7972](https://github.com/decidim/decidim/pull/7972)
- **decidim-assemblies**: Add announcements to assemblies [\#7971](https://github.com/decidim/decidim/pull/7971)
- **decidim-elections**: Election log [\#7923](https://github.com/decidim/decidim/pull/7923)
- **decidim-elections**: Polling station officer ballot count [\#7823](https://github.com/decidim/decidim/pull/7823)
- **decidim-elections**: Implement in person vote [\#7878](https://github.com/decidim/decidim/pull/7878)
- **decidim-elections**: Polling station sign closure [\#7891](https://github.com/decidim/decidim/pull/7891)
- **decidim-elections**: Polling station closure attach the physical electoral closure certificate [\#7929](https://github.com/decidim/decidim/pull/7929)
- **decidim-meetings**: Publish and unpublish a meeting [\#7893](https://github.com/decidim/decidim/pull/7893)
- **decidim-elections**: Electoral certificate validation by Monitoring Committee Members [\#7871](https://github.com/decidim/decidim/pull/7871)
- **decidim-elections**: Validate results by Monitoring Committee Members [\#7899](https://github.com/decidim/decidim/pull/7899)
- **decidim-elections**: Mockup design for Participation statistics tables in Votings [\#7879](https://github.com/decidim/decidim/pull/7879)
- **decidim-admin**, **decidim-core**: Security feature external link warning [\#7397](https://github.com/decidim/decidim/pull/7397)
- **decidim-meetings**: Show participants list in meetings [\#7933](https://github.com/decidim/decidim/pull/7933)
- **decidim-meetings**: Meeting calendars providers [\#7944](https://github.com/decidim/decidim/pull/7944)
- **decidim-admin**, **decidim-assemblies**: Add groups as assembly members [\#7993](https://github.com/decidim/decidim/pull/7993)
- **decidim-meetings**: Maps optional in meetings [\#7954](https://github.com/decidim/decidim/pull/7954)
- **decidim-meetings**: Register to meeting via email [\#7947](https://github.com/decidim/decidim/pull/7947)
- **decidim-system**: Improve on boarding as implementer [\#8010](https://github.com/decidim/decidim/pull/8010)
- **decidim-initiatives**: Make collection of initiatives exportable [\#8033](https://github.com/decidim/decidim/pull/8033)
- **decidim-admin**: Filter participants admin [\#8104](https://github.com/decidim/decidim/pull/8104)
- **decidim-meetings**: Polls in meetings [\#8065](https://github.com/decidim/decidim/pull/8065)
- **decidim-participatory processes**: Add comments in participatory space presentation page stats block [\#8034](https://github.com/decidim/decidim/pull/8034)
- **decidim-comments**: Allow users to comment and delete their own comments [\#8072](https://github.com/decidim/decidim/pull/8072)
- **decidim-meetings**: Allow to create online meetings without an URL [\#8152](https://github.com/decidim/decidim/pull/8152)
- **decidim-comments**: Add emojis support [\#8118](https://github.com/decidim/decidim/pull/8118)
- **decidim-core**: Change language preference in account [\#8169](https://github.com/decidim/decidim/pull/8169)
- **decidim-meetings**: Search, filter, pagination and sorting in meetings admin panel [\#7976](https://github.com/decidim/decidim/pull/7976)
- **decidim-meetings**: Allow Frontend user to add attendees count information [\#8205](https://github.com/decidim/decidim/pull/8205)
- **decidim-admin**, **decidim-core**: Make it possible to define SCSS settings overrides from modules [\#8198](https://github.com/decidim/decidim/pull/8198)
- **decidim-comments**, **decidim-consultations**, **decidim-initiatives**: Apply permissions system to comments [\#8035](https://github.com/decidim/decidim/pull/8035)
- **decidim-meetings**: Meetings iframe and iframe URL [\#8096](https://github.com/decidim/decidim/pull/8096)
- **decidim-meetings**: Online meetings iframe visibility with time [\#8097](https://github.com/decidim/decidim/pull/8097)

### Changed

- **decidim-budgets**: Change the order of attachments in budgets [\#7524](https://github.com/decidim/decidim/pull/7524)
- **decidim-admin**, **decidim-assemblies**, **decidim-budgets**, **decidim-conferences**, **decidim-participatory processes**: Rename "weight" to "order position" [\#7445](https://github.com/decidim/decidim/pull/7445)
- **decidim-core**: Chore homepage statistics with title below the number [\#7595](https://github.com/decidim/decidim/pull/7595)
- **decidim-comments**: Make API commentable mutation translation attributes optional [\#7655](https://github.com/decidim/decidim/pull/7655)
- **decidim-core**: Fix announcement cell heading [\#7631](https://github.com/decidim/decidim/pull/7631)
- **decidim-elections**: Move votings answer results to its own table [\#7767](https://github.com/decidim/decidim/pull/7767)
- **decidim-core**: Move searchlight gem to core and remove unnecessary requires [\#7782](https://github.com/decidim/decidim/pull/7782)
- **decidim-assemblies**: Change order by weight in subassemblies [\#7620](https://github.com/decidim/decidim/pull/7620)
- **decidim-proposals**: Enable Proposals Cell to take into account machine translations [\#7629](https://github.com/decidim/decidim/pull/7629)
- **decidim-core**: Redirect unauthenticated users to sign in page for unauthorized views [\#7852](https://github.com/decidim/decidim/pull/7852)
- **decidim-core**: Open attachments in new tab [\#7912](https://github.com/decidim/decidim/pull/7912)
- **decidim-meetings**: Remove creation date from meeting card [\#7922](https://github.com/decidim/decidim/pull/7922)
- Move translations to the module they belong [\#7873](https://github.com/decidim/decidim/pull/7873)
- **decidim-meetings**: Meetings merge minutes and close actions [\#7968](https://github.com/decidim/decidim/pull/7968)

### Fixed

- **decidim-core**: Fix Invalid signature on message decryption [\#7488](https://github.com/decidim/decidim/pull/7488)
- **decidim-proposals**: Fix cost display on proposals [\#7450](https://github.com/decidim/decidim/pull/7450)
- **decidim-budgets**: Fix proposals to budget import [\#7449](https://github.com/decidim/decidim/pull/7449)
- **decidim-assemblies**, **decidim-participatory processes**: Fix NULL error with weight field in assemblies & processes [\#7486](https://github.com/decidim/decidim/pull/7486)
- **decidim-core**: Fix record encryptor hash values JSON parsing for legacy unencrypted hash values [\#7494](https://github.com/decidim/decidim/pull/7494)
- **decidim-admin**: Only share tokens if component exists [\#7499](https://github.com/decidim/decidim/pull/7499)
- **decidim-core**: Invalidate all user sessions when destroying the account [\#7506](https://github.com/decidim/decidim/pull/7506)
- **decidim-admin**, **decidim-budgets**: New Admin users cannot accept Terms and conditions [\#7516](https://github.com/decidim/decidim/pull/7516)
- **decidim-meetings**: Don't allow filtering meetings by user group if setting is disabled [\#7514](https://github.com/decidim/decidim/pull/7514)
- **decidim-proposals**: Fix non-unique IDs element in filter hash cash [\#7531](https://github.com/decidim/decidim/pull/7531)
- **decidim-core**: Fix record encryptor trying to decrypt or decode non-String values [\#7536](https://github.com/decidim/decidim/pull/7536)
- **decidim-core**: Fix record encryptor trying to decrypt empty strings [\#7542](https://github.com/decidim/decidim/pull/7542)
- **decidim-core**, **decidim-proposals**: Fix cells caching by using cache_key_with_version instead of cache version [\#7532](https://github.com/decidim/decidim/pull/7532)
- **decidim-admin**, **decidim-core**: Fix infinite loop when impersonated session time runs out [\#7221](https://github.com/decidim/decidim/pull/7221)
- **decidim-debates**, **decidim-meetings**, **decidim-proposals**: Fix user profile timeline activity cards texts showing "New resource" on updates [\#7555](https://github.com/decidim/decidim/pull/7555)
- **decidim-core**, **decidim-proposals**: Fix announcements when sending an empty translations hash [\#7568](https://github.com/decidim/decidim/pull/7568)
- **decidim-core**: Sanitize address inputs [\#7573](https://github.com/decidim/decidim/pull/7573)
- **decidim-participatory processes**: Fix process serializer to consider nil images [\#7607](https://github.com/decidim/decidim/pull/7607)
- **decidim-proposals**: Add render space to cache hash [\#7596](https://github.com/decidim/decidim/pull/7596)
- **decidim-participatory processes**: Show processes finishing today [\#7594](https://github.com/decidim/decidim/pull/7594)
- **decidim-proposals**: Improve proposals listing performance after cache implementation [\#7581](https://github.com/decidim/decidim/pull/7581)
- **decidim-core**: Make category in the API non-mandatory [\#7624](https://github.com/decidim/decidim/pull/7624)
- **decidim-meetings**: Do not crash if mandatory fields are blank and registrations are enabled [\#7634](https://github.com/decidim/decidim/pull/7634)
- **decidim-proposals**: Don't copy counters when copying proposals [\#7635](https://github.com/decidim/decidim/pull/7635)
- **decidim-proposals**: Fix rendering of proposals in map [\#7642](https://github.com/decidim/decidim/pull/7642)
- **decidim-core**: Fit the map properly on mobile screens with multiple markers [\#7648](https://github.com/decidim/decidim/pull/7648)
- **decidim-proposals**: Add missing migration to fix counters in copied proposals [\#7638](https://github.com/decidim/decidim/pull/7638)
- **decidim-initiatives**: Fix permission for initiative edit and update [\#7647](https://github.com/decidim/decidim/pull/7647)
- **decidim-comments**: Fix comments opinion toggle accessibility [\#7657](https://github.com/decidim/decidim/pull/7657)
- **decidim-proposals**: Show all proposals in map [\#7660](https://github.com/decidim/decidim/pull/7660)
- **decidim-comments**: Fix the missing aria-controls element on pages with comments [\#7664](https://github.com/decidim/decidim/pull/7664)
- **decidim-core**: Don't show deleted users on user group members page [\#7681](https://github.com/decidim/decidim/pull/7681)
- **decidim-core**: Don't overwrite mailer reply_to [\#7641](https://github.com/decidim/decidim/pull/7641)
- **decidim-proposals**: Fix map preview when there is no address [\#7673](https://github.com/decidim/decidim/pull/7673)
- Fix ARIA roles for the SVG images (icons) [\#7663](https://github.com/decidim/decidim/pull/7663)
- **decidim-admin**: Don't render a moderation when its reportable is deleted [\#7684](https://github.com/decidim/decidim/pull/7684)
- **decidim-meetings**: Show newer meetings first [\#7685](https://github.com/decidim/decidim/pull/7685)
- **decidim-admin**: Only show moderations from current organization in Global Moderation panel [\#7686](https://github.com/decidim/decidim/pull/7686)
- **decidim-core**: Don't send emails to deleted users [\#7688](https://github.com/decidim/decidim/pull/7688)
- **decidim-initiatives**: Fix initiative-m card hashtags [\#7679](https://github.com/decidim/decidim/pull/7679)
- **decidim-comments**: Fix the screen reader class name for comments opinion toggle [\#7698](https://github.com/decidim/decidim/pull/7698)
- **decidim-core**: Ensure pagination elements per page is a valid option [\#7680](https://github.com/decidim/decidim/pull/7680)
- **decidim-conferences**: Fix validations for registration related fields in Conference form [\#7675](https://github.com/decidim/decidim/pull/7675)
- **decidim-comments**, **decidim-core**: Fix the aria attribute names (no `aria` prefix) [\#7707](https://github.com/decidim/decidim/pull/7707)
- **decidim-core**: Fix dropdown menu accessibility audits [\#7708](https://github.com/decidim/decidim/pull/7708)
- **decidim-core**: Fix heading order on the home page [\#7710](https://github.com/decidim/decidim/pull/7710)
- **decidim-proposals**: Fix a series of issues with proposal attachments in the public area [\#7699](https://github.com/decidim/decidim/pull/7699)
- **decidim-core**: Fix report mailers when author is a meeting [\#7683](https://github.com/decidim/decidim/pull/7683)
- Fix HTML validation regarding SVG images [\#7721](https://github.com/decidim/decidim/pull/7721)
- **decidim-comments**: Accessibility fixes for comments [\#7741](https://github.com/decidim/decidim/pull/7741)
- Add aria-label to the free search field in the search filters [\#7742](https://github.com/decidim/decidim/pull/7742)
- Add aria-label to the area filter on participatory space pages [\#7743](https://github.com/decidim/decidim/pull/7743)
- Fix HTML validation on standalone content page [\#7744](https://github.com/decidim/decidim/pull/7744)
- Add a landmark ARIA role to the cookie banner [\#7738](https://github.com/decidim/decidim/pull/7738)
- Accessibility fixes for conversations [\#7745](https://github.com/decidim/decidim/pull/7745)
- Fix report modal form accessibility [\#7746](https://github.com/decidim/decidim/pull/7746)
- Validate the HTML for the account page [\#7747](https://github.com/decidim/decidim/pull/7747)
- Fix color contrast against the sidebar navigation background [\#7748](https://github.com/decidim/decidim/pull/7748)
- Remove the opacity from process upcoming/past/all filters for accessible contrast [\#7749](https://github.com/decidim/decidim/pull/7749)
- Change the timeline date color for accessible color contrast against its background [\#7750](https://github.com/decidim/decidim/pull/7750)
- Strip the `<p>` tags from inside the heading elements [\#7732](https://github.com/decidim/decidim/pull/7732)
- **decidim-admin**, **decidim-conferences**: Add Conferences and Admin missing translations [\#7653](https://github.com/decidim/decidim/pull/7653)
- **decidim-admin**: Add admin missing translations [\#7702](https://github.com/decidim/decidim/pull/7702)
- fix elections js assets manifest  [\#7759](https://github.com/decidim/decidim/pull/7759)
- **decidim-elections**: Fix trustees admin menu [\#7772](https://github.com/decidim/decidim/pull/7772)
- **decidim-elections**: Add missing assets to the elections manifest [\#7773](https://github.com/decidim/decidim/pull/7773)
- **decidim-consultations**, **decidim-elections**: Fix showing trustees menu on consultations module [\#7778](https://github.com/decidim/decidim/pull/7778)
- **decidim-admin**: Remove BOM in CSV of private participants [\#7781](https://github.com/decidim/decidim/pull/7781)
- **decidim-budgets**: Make budgets functional without the proposals module [\#7786](https://github.com/decidim/decidim/pull/7786)
- **decidim-accountability**: Make accountability functional without the proposals module [\#7785](https://github.com/decidim/decidim/pull/7785)
- Make meetings functional without the proposals module [\#7784](https://github.com/decidim/decidim/pull/7784)
- **decidim-proposals**: Remove proposals dependency from the debates module [\#7783](https://github.com/decidim/decidim/pull/7783)
- **decidim-elections**: Remove file from elections manifest [\#7795](https://github.com/decidim/decidim/pull/7795)
- **decidim-initiatives**: Fix single initiative type [\#7667](https://github.com/decidim/decidim/pull/7667)
- **decidim-elections**, **decidim-participatory processes**: Show attachment menu as active only when subitem is active [\#7774](https://github.com/decidim/decidim/pull/7774)
- **decidim-initiatives**: Revert "Fix single initiative type" [\#7800](https://github.com/decidim/decidim/pull/7800)
- **decidim-admin**: Fix: Reported users are displayed in all tenants  [\#7628](https://github.com/decidim/decidim/pull/7628)
- **decidim-core**: Fix canceling scope select doesnt open reveal [\#7805](https://github.com/decidim/decidim/pull/7805)
- **decidim-elections**: Show missing election component callout also for in-person votings [\#7809](https://github.com/decidim/decidim/pull/7809)
- **decidim-elections**: Add missing translation for election publish_results admin log [\#7835](https://github.com/decidim/decidim/pull/7835)
- **decidim-core**: CSV exporter should take into account locales from all resources [\#7825](https://github.com/decidim/decidim/pull/7825)
- **decidim-proposals**: Fix proposal form attachment errors [\#7856](https://github.com/decidim/decidim/pull/7856)
- **decidim-meetings**: Fix joining a meetings that the user already follows [\#7854](https://github.com/decidim/decidim/pull/7854)
- **decidim-core**: Fix filter by scopes [\#7858](https://github.com/decidim/decidim/pull/7858)
- **decidim-comments**: Fix TypeError in newsletters [\#7872](https://github.com/decidim/decidim/pull/7872)
- **decidim-core**: Fix editor: shift+enter makes single br tag before link [\#7877](https://github.com/decidim/decidim/pull/7877)
- **decidim-meetings**: Fix meeting registrations questionnaire free text choice answers export [\#7892](https://github.com/decidim/decidim/pull/7892)
- **decidim-core**: Fix not signed in needs permission redirect for internal links [\#7890](https://github.com/decidim/decidim/pull/7890)
- **decidim-comments**: NoMethodError raised when voting comments from threads [\#7880](https://github.com/decidim/decidim/pull/7880)
- **decidim-core**: Fix editor: remove br tags from inside a tags [\#7901](https://github.com/decidim/decidim/pull/7901)
- **decidim-admin**: Fix JS errors in the admin panel [\#7903](https://github.com/decidim/decidim/pull/7903)
- **decidim-core**: Validate nickname using correct regexp [\#7900](https://github.com/decidim/decidim/pull/7900)
- **decidim-proposals**: Cast proposal and collaborative drafts titles to text [\#7925](https://github.com/decidim/decidim/pull/7925)
- **decidim-blogs**: Fix updating blog post author group [\#7934](https://github.com/decidim/decidim/pull/7934)
- **decidim-core**: Fix fragment caching with multiple locales [\#7943](https://github.com/decidim/decidim/pull/7943)
- **decidim-core**: Skip version generation on touch events [\#7978](https://github.com/decidim/decidim/pull/7978)
- **decidim-proposals**: Add comment count to the proposal cache [\#7965](https://github.com/decidim/decidim/pull/7965)
- **decidim-proposals**: Hide moderated proposals from comparator [\#7975](https://github.com/decidim/decidim/pull/7975)
- **decidim-meetings**, **decidim-proposals**: Hide moderated meetings and proposals from admin lists [\#7974](https://github.com/decidim/decidim/pull/7974)
- **decidim-admin**, **decidim-core**: Touch the reportable object when is hidden to reset caches [\#7966](https://github.com/decidim/decidim/pull/7966)
- **decidim-core**: Fix editor when formatting starts with a linebreak [\#7999](https://github.com/decidim/decidim/pull/7999)
- **decidim-core**, **decidim-proposals**: Remove proposals filters cache [\#8032](https://github.com/decidim/decidim/pull/8032)
- **decidim-core**, **decidim-meetings**: Include resources on maps only when the geocoding got valid coords [\#8037](https://github.com/decidim/decidim/pull/8037)
- **decidim-core**: Use correct newsletter cell for web view [\#8025](https://github.com/decidim/decidim/pull/8025)
- **decidim-participatory processes**: Fix attachment title migration generating possibly invalid values [\#8020](https://github.com/decidim/decidim/pull/8020)
- **decidim-meetings**, **decidim-participatory processes**: Fix undetected broken tests because of missing dependencies [\#8050](https://github.com/decidim/decidim/pull/8050)
- **decidim-core**: Fix redirects broken by Terms and Conditions redirect [\#8036](https://github.com/decidim/decidim/pull/8036)
- **decidim-core**: Fix boolean fields for .reported? and .hidden? which is nil if no report exists [\#7990](https://github.com/decidim/decidim/pull/7990)
- **decidim-admin**: Use symbols for polymorphic route arguments in Scope Type admin [\#8052](https://github.com/decidim/decidim/pull/8052)
- **decidim-meetings**: Fix broken test on meetings after merging PR without rebase [\#8076](https://github.com/decidim/decidim/pull/8076)
- **decidim-surveys**: Make surveys matrix tables to scroll when needed [\#8085](https://github.com/decidim/decidim/pull/8085)
- **decidim-consultations**: Fix question preview when no questions published [\#8111](https://github.com/decidim/decidim/pull/8111)
- Use develop branch for generator [\#8113](https://github.com/decidim/decidim/pull/8113)
- **decidim-admin**: Add the map module to the admin styles [\#8043](https://github.com/decidim/decidim/pull/8043)
- Use carryforward flags to improve project coverage calculations [\#8112](https://github.com/decidim/decidim/pull/8112)
- **decidim-meetings**: Fix broken tests on meetings [\#8114](https://github.com/decidim/decidim/pull/8114)
- **decidim-core**: Fix webpacker asset configs for external apps [\#8107](https://github.com/decidim/decidim/pull/8107)
- **decidim-core**: Entering a large message when starting a conversation does not display any error message [\#8095](https://github.com/decidim/decidim/pull/8095)
- Remove the relative paths from the fontface file [\#8108](https://github.com/decidim/decidim/pull/8108)
- **decidim-core**: NoMethodError: undefined method `blocked?' for nil:NilClass  [\#8071](https://github.com/decidim/decidim/pull/8071)
- **decidim-core**: ActionView::Template::ErrorSidekiq/ActionMailer::MailDeliveryJob [\#8075](https://github.com/decidim/decidim/pull/8075)
- **decidim-participatory processes**: Fix formatting issue on process timeline card [\#8092](https://github.com/decidim/decidim/pull/8092)
- **decidim-initiatives**: Fix flaky test on initiatives [\#8128](https://github.com/decidim/decidim/pull/8128)
- **decidim-core**: Add missing translation for authorization_modals [\#8129](https://github.com/decidim/decidim/pull/8129)
- **decidim-admin**: Add missing templates translations [\#8133](https://github.com/decidim/decidim/pull/8133)
- **decidim-admin**: Metric is not shown when value is zero for blocked and reported users [\#8117](https://github.com/decidim/decidim/pull/8117)
- **decidim-core**: Fix user report notification reported user name [\#8130](https://github.com/decidim/decidim/pull/8130)
- **decidim-accountability**: Fix access to import CSV results in accountability [\#8132](https://github.com/decidim/decidim/pull/8132)
- **decidim-core**: Fix dont save timeout path to session [\#8142](https://github.com/decidim/decidim/pull/8142)
- **decidim-verifications**: Fix verification route issues [\#8146](https://github.com/decidim/decidim/pull/8146)
- **decidim-core**: Fix session timeout conflicting with remember me [\#7467](https://github.com/decidim/decidim/pull/7467)
- **decidim-budgets**, **decidim-proposals**: Fix proposal picker remove using "×" [\#8148](https://github.com/decidim/decidim/pull/8148)
- **decidim-admin**: Fix admin log blocked user name [\#8156](https://github.com/decidim/decidim/pull/8156)
- **decidim-surveys**: Fix ordering of question matrix_rows in templates [\#8143](https://github.com/decidim/decidim/pull/8143)
- **decidim-surveys**: Fix create questionnaire from template when no template is selected [\#8173](https://github.com/decidim/decidim/pull/8173)
- **decidim-proposals**: Fix proposals cache bug when participatory process step changes [\#8172](https://github.com/decidim/decidim/pull/8172)
- **decidim-core**: Downgrade postscss version to 2.1.1 [\#8190](https://github.com/decidim/decidim/pull/8190)
- **decidim-core**: Lock the `webpacker` gem to the beta release [\#8191](https://github.com/decidim/decidim/pull/8191)
- **decidim-budgets**: Fix status search on projects page [\#8204](https://github.com/decidim/decidim/pull/8204)
- **decidim-admin**, **decidim-core**, **decidim-system**: W3C does not yet allow svg being loaded via CORS [\#8019](https://github.com/decidim/decidim/pull/8019)
- Fix broken autopublishing of Docker images [\#8212](https://github.com/decidim/decidim/pull/8212)
- **decidim-comments**: Fix visible moderated single comment [\#8196](https://github.com/decidim/decidim/pull/8196)
- **decidim-core**: Fix user activity pagination when there are hidden items [\#8202](https://github.com/decidim/decidim/pull/8202)
- **decidim-elections**: Load JS configuration in elections focus mode layout [\#8213](https://github.com/decidim/decidim/pull/8213)
- **decidim-core**: Fix performance issue in notification settings page [\#8155](https://github.com/decidim/decidim/pull/8155)
- **decidim-core**: Fix don't require inactive authorization handlers [\#8122](https://github.com/decidim/decidim/pull/8122)
- **decidim-comments**: Set current_component as commentable when commentable is a participatory space [\#8189](https://github.com/decidim/decidim/pull/8189)
- **decidim-budgets**, **decidim-comments**, **decidim-core**, **decidim-elections**, **decidim-initiatives**, **decidim-meetings**: Fix broken tests after problematic PRs [\#8224](https://github.com/decidim/decidim/pull/8224)
- **decidim-meetings**: Remove flaky test on meetings [\#8226](https://github.com/decidim/decidim/pull/8226)
- **decidim-proposals**: Fix the proposal data migration for proposals without authors or organization [\#8015](https://github.com/decidim/decidim/pull/8015)
- **decidim-elections**: Evote bug fixing [\#8220](https://github.com/decidim/decidim/pull/8220)
- **decidim-core**: Fix content type delegation to blank attachments [\#8230](https://github.com/decidim/decidim/pull/8230)

### Improved

- **decidim-admin**: Migrate Admin menus to Menu Registry Part 2 [\#7382](https://github.com/decidim/decidim/pull/7382)
- **decidim-elections**: Add unique trustee name [\#7544](https://github.com/decidim/decidim/pull/7544)
- **decidim-elections**: Restore vote tests in the elections module using the real bulletin board [\#7802](https://github.com/decidim/decidim/pull/7802)
- Configure webpacker additional paths and entry points programmatically [\#8066](https://github.com/decidim/decidim/pull/8066)
- Webpacker clean Sprockets and update docs [\#7942](https://github.com/decidim/decidim/pull/7942)
- **decidim-core**: Search user groups [\#8061](https://github.com/decidim/decidim/pull/8061)
- Webpacker: Do not override the application's package.json [\#8094](https://github.com/decidim/decidim/pull/8094)
- **decidim-proposals**: Fix proposal map form [\#8088](https://github.com/decidim/decidim/pull/8088)
- Split NPM dependencies to more granular packages [\#8121](https://github.com/decidim/decidim/pull/8121)
- **decidim-admin**: Fix admin stylesheet dynamic imports [\#8154](https://github.com/decidim/decidim/pull/8154)
- **decidim-core**: Move the webpacker config override to @decidim/webpacker [\#8158](https://github.com/decidim/decidim/pull/8158)
- **decidim-core**: Docs: Update the module webpacker migration guide [\#8180](https://github.com/decidim/decidim/pull/8180)
- **decidim-core**: Remove Sprockets dependant gems [\#8183](https://github.com/decidim/decidim/pull/8183)
- **decidim-core**: Make the `webpacker` gem a core dependency [\#8181](https://github.com/decidim/decidim/pull/8181)
- **decidim-meetings**: Add event organisers and registered users in statistics information [\#8055](https://github.com/decidim/decidim/pull/8055)
- **decidim-core**: Move the customized rails requires to `decidim/rails` [\#8182](https://github.com/decidim/decidim/pull/8182)
- **decidim-forms**, **decidim-templates**: Fully copy question's display_conditions from template [\#8177](https://github.com/decidim/decidim/pull/8177)
- **decidim-admin**, **decidim-budgets**, **decidim-core**, **decidim-meetings**, **decidim-system**: Fix SCSS slash division [\#8203](https://github.com/decidim/decidim/pull/8203)
- **decidim-admin**: Improve Admin English locale [\#8179](https://github.com/decidim/decidim/pull/8179)
- **decidim-core**: Exclude blocked and deleted users from participants stats [\#8147](https://github.com/decidim/decidim/pull/8147)
- Update manual installation guide in documentation [\#8217](https://github.com/decidim/decidim/pull/8217)
- **decidim-core**: Active storage migration [\#7598](https://github.com/decidim/decidim/pull/7598)
- **decidim-accountability**, **decidim-budgets**, **decidim-core**, **decidim-meetings**, **decidim-proposals**, **decidim-surveys**: Improve metrics calculations performance [\#8215](https://github.com/decidim/decidim/pull/8215)
- **decidim-core**: Active storage migrations service [\#7902](https://github.com/decidim/decidim/pull/7902)

### Removed

- **decidim-core**: Remove ja-JP.yml; Use ja.yml for JA locale [\#8208](https://github.com/decidim/decidim/pull/8208)
- Remove obsolete rake webpack task [\#8237](https://github.com/decidim/decidim/pull/8237)

### Developer improvements

- Improve changelog generator [\#7475](https://github.com/decidim/decidim/pull/7475)
- Move specs file to correct folder [\#7476](https://github.com/decidim/decidim/pull/7476)
- Exit on CI workflow dispatch failures [\#7502](https://github.com/decidim/decidim/pull/7502)
- Remove duplicated migration [\#7517](https://github.com/decidim/decidim/pull/7517)
- Remove console warnings from the conversations views [\#7523](https://github.com/decidim/decidim/pull/7523)
- Do not change the global test app configs during specs [\#7525](https://github.com/decidim/decidim/pull/7525)
- Add Votings landing page to the design app [\#7527](https://github.com/decidim/decidim/pull/7527)
- Don't schedule CI jobs for locales PRs [\#7534](https://github.com/decidim/decidim/pull/7534)
- Update the workflow cleanup action to the latest version [\#7535](https://github.com/decidim/decidim/pull/7535)
- Revert "Don't schedule CI jobs for locales PRs (#7534)" [\#7546](https://github.com/decidim/decidim/pull/7546)
- Update Bulletin Board documentation [\#7572](https://github.com/decidim/decidim/pull/7572)
- Add examples on code overriding docs [\#7498](https://github.com/decidim/decidim/pull/7498)
- Ability to administrate the elements from menus  [\#7545](https://github.com/decidim/decidim/pull/7545)
- Refactor map functionality regarding the drag marker maps [\#7649](https://github.com/decidim/decidim/pull/7649)
- Fix puffing-billy timeout error when stopping the event machine [\#7672](https://github.com/decidim/decidim/pull/7672)
- Don't run all jobs on every PR [\#7693](https://github.com/decidim/decidim/pull/7693)
- Fix link to CONTRIBUTING.adoc in PR template [\#7696](https://github.com/decidim/decidim/pull/7696)
- Fix link to "Getting started guide" in README.adoc [\#7695](https://github.com/decidim/decidim/pull/7695)
- Bump mimemagic to 0.3.6 [\#7701](https://github.com/decidim/decidim/pull/7701)
- Upgrade to decidim-bulletin_board 0.15.2 [\#7659](https://github.com/decidim/decidim/pull/7659)
- Fix form builder assuming proposals module availability [\#7689](https://github.com/decidim/decidim/pull/7689)
- Bump mimemagic to 0.3.9 [\#7753](https://github.com/decidim/decidim/pull/7753)
- Move core dependencies from the proposals module to the core [\#7690](https://github.com/decidim/decidim/pull/7690)
- Fix the date cell spec failing randomly close to day changes [\#7703](https://github.com/decidim/decidim/pull/7703)
- Add automated accessibility audit + HTML validation to CI pipeline [\#7751](https://github.com/decidim/decidim/pull/7751)
- Add HTML escaping to the spec expectations as the strings are escaped [\#7760](https://github.com/decidim/decidim/pull/7760)
- Do not modify the controller class in the controller tests that render views [\#7755](https://github.com/decidim/decidim/pull/7755)
- Upgrade rails to 5.2.5 and carrierwave to 2.2.1 in order not to depend on mimemagic [\#7762](https://github.com/decidim/decidim/pull/7762)
- Update README.adoc [\#7687](https://github.com/decidim/decidim/pull/7687)
- Restore vote tests in the elections module using the real bulletin board [\#7802](https://github.com/decidim/decidim/pull/7802)
- Rails 6 upgrade [\#7471](https://github.com/decidim/decidim/pull/7471)
- Change edge and test branch to use develop by default [\#7842](https://github.com/decidim/decidim/pull/7842)
- Migrate to Webpacker [\#7464](https://github.com/decidim/decidim/pull/7464)
- Fix node version for version managers [\#7848](https://github.com/decidim/decidim/pull/7848)
- Fix branch name on generators [\#7849](https://github.com/decidim/decidim/pull/7849)
- Dynamically get all participatory space role tables for the `visible_meeting_for` query [\#7855](https://github.com/decidim/decidim/pull/7855)
- Attempt to fix puffing-billy runtime error [\#7853](https://github.com/decidim/decidim/pull/7853)
- Upgrade decidim-bulletin_board to 0.20.0 [\#7881](https://github.com/decidim/decidim/pull/7881)
- Make webpacker build available in production [\#7915](https://github.com/decidim/decidim/pull/7915)
- Use NPM instead of yarn on CI [\#7919](https://github.com/decidim/decidim/pull/7919)
- Migrate to Webpacker (CSS and images) [\#7733](https://github.com/decidim/decidim/pull/7733)
- Remove reference to custom branch [\#7941](https://github.com/decidim/decidim/pull/7941)
- Update to latest Rails to fix security issues [\#7946](https://github.com/decidim/decidim/pull/7946)
- Design app fixes after Webpacker installation [\#7935](https://github.com/decidim/decidim/pull/7935)
- Improve docs on generating the changelog [\#7962](https://github.com/decidim/decidim/pull/7962)
- Simplify SQL query for endorsement stats [\#7973](https://github.com/decidim/decidim/pull/7973)
- Add 2 additional queues for a better scalling of the application [\#7986](https://github.com/decidim/decidim/pull/7986)
- Add notes to changelog [\#7987](https://github.com/decidim/decidim/pull/7987)
- Fixing failing tests on develop branch [\#7991](https://github.com/decidim/decidim/pull/7991)
- Bump gems versions to fix dependendabot alerts [\#8040](https://github.com/decidim/decidim/pull/8040)
- Amend CSS overwritting [\#8007](https://github.com/decidim/decidim/pull/8007)
- Add missing tests for scope types admin page [\#8053](https://github.com/decidim/decidim/pull/8053)
- Update supported versions in docs [\#8079](https://github.com/decidim/decidim/pull/8079)
- Update bundle for security reasons [\#8080](https://github.com/decidim/decidim/pull/8080)
- Configure webpacker additional paths and entry points programmatically [\#8066](https://github.com/decidim/decidim/pull/8066)
- Webpacker clean Sprockets and update docs [\#7942](https://github.com/decidim/decidim/pull/7942)
- Use develop branch for generator [\#8113](https://github.com/decidim/decidim/pull/8113)
- Use carryforward flags to improve project coverage calculations [\#8112](https://github.com/decidim/decidim/pull/8112)
- Fix webpacker asset configs for external apps [\#8107](https://github.com/decidim/decidim/pull/8107)
- Webpacker: Do not override the application's package.json [\#8094](https://github.com/decidim/decidim/pull/8094)
- Dynamic stylesheet includes with Webpacker [\#8115](https://github.com/decidim/decidim/pull/8115)
- Remove deprecated Bootsnap warnings [\#8091](https://github.com/decidim/decidim/pull/8091)
- Remove the relative paths from the fontface file [\#8108](https://github.com/decidim/decidim/pull/8108)
- Fix flaky test on initiatives [\#8128](https://github.com/decidim/decidim/pull/8128)
- Split NPM dependencies to more granular packages [\#8121](https://github.com/decidim/decidim/pull/8121)
- Fix webpacker issues [\#8136](https://github.com/decidim/decidim/pull/8136)
- Fix admin stylesheet dynamic imports [\#8154](https://github.com/decidim/decidim/pull/8154)
- Move the webpacker config override to @decidim/webpacker [\#8158](https://github.com/decidim/decidim/pull/8158)
- Docs: Update the module webpacker migration guide [\#8180](https://github.com/decidim/decidim/pull/8180)
- Remove Sprockets dependant gems [\#8183](https://github.com/decidim/decidim/pull/8183)
- Make the `webpacker` gem a core dependency [\#8181](https://github.com/decidim/decidim/pull/8181)
- Downgrade postscss version to 2.1.1 [\#8190](https://github.com/decidim/decidim/pull/8190)
- Move the customized rails requires to `decidim/rails` [\#8182](https://github.com/decidim/decidim/pull/8182)
- Lock the `webpacker` gem to the beta release [\#8191](https://github.com/decidim/decidim/pull/8191)
- Fix SCSS slash division [\#8203](https://github.com/decidim/decidim/pull/8203)
- Remove ja-JP.yml; Use ja.yml for JA locale [\#8208](https://github.com/decidim/decidim/pull/8208)
- Fix broken autopublishing of Docker images [\#8212](https://github.com/decidim/decidim/pull/8212)
- Make it possible to define SCSS settings overrides from modules [\#8198](https://github.com/decidim/decidim/pull/8198)
- Remove flaky test on meetings [\#8226](https://github.com/decidim/decidim/pull/8226)
- Bump addressable version because security issues [\#8229](https://github.com/decidim/decidim/pull/8229)
- Active storage migrations service [\#7902](https://github.com/decidim/decidim/pull/7902)
- Remove obsolete rake webpack task [\#8237](https://github.com/decidim/decidim/pull/8237)

## Previous versions

Please check [release/0.24-stable](https://github.com/decidim/decidim/blob/release/0.24-stable/CHANGELOG.md) for previous changes.
