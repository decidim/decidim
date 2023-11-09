# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

### Upgrade notes

#### Deduplicating endorsements

We have identified a case when the same user can endorse the same resource multiple times. This is a bug that we have fixed in this release, but we need to clean up the existing duplicated endorsements. We have added a new task that helps you clean the duplicated endorsements.

```bash
bundle exec rails decidim:upgrade:fix_duplicate_endorsements
```

You can see more details about this change on PR [\#11853](https://github.com/decidim/decidim/pull/11853)

### Added

Nothing.

### Changed

Nothing.

### Fixed

Nothing.

### Removed

Nothing.

### Developer improvements

Nothing.

### Internal

Nothing.

## [0.26.8](https://github.com/decidim/decidim/tree/v0.26.8)

### Security fixes

This release addresses one security issue:

* CVE-2023-36465

The details regarding the security vulnerability will be published on September 25th 2023, which is two months after the release date of this version. For more information, please refer to our [Security Policy](https://github.com/decidim/decidim/blob/develop/SECURITY.md).

We highly recommend updating to this version as soon as possible to ensure the security of your system.

### Upgrade notes

#### Orphans valuator assignments cleanup

We have added a new task that helps you clean the valuator assignements records of roles that have been deleted.

You can run the task with the following command:

```console
bundle exec rake decidim:proposals:upgrade:remove_valuator_orphan_records
```

You can see more details about this change on PR [\#10607](https://github.com/decidim/decidim/pull/10607)

### Added

Nothing.

### Changed

Nothing.

### Fixed

- **decidim-verifications**: Backport 'Fix missing translations for SMS confirmation when signing a petition' to v0.26 [\#11012](https://github.com/decidim/decidim/pull/11012)
- **decidim-initiatives**: Backport 'Fix for initiative menu not active on creation' to v0.26 [\#11020](https://github.com/decidim/decidim/pull/11020)
- **decidim-elections**: Backport 'Allow to publish an Election even if it hasn't valid Questions' to v0.26 [\#11032](https://github.com/decidim/decidim/pull/11032)
- **decidim-core**: Backport 'Fix to Proposal cards CSS in Processes' to v0.26 [\#11022](https://github.com/decidim/decidim/pull/11022)
- **decidim-core**: Backport 'Add translation string for URL error message' to v0.26 [\#11014](https://github.com/decidim/decidim/pull/11014)
- **decidim-blogs**: Backport 'Add possibility of reporting blog posts ' to v0.26 [\#11026](https://github.com/decidim/decidim/pull/11026)
- **decidim-core**, **decidim-debates**, **decidim-initiatives**, **decidim-proposals**, **decidim-sortitions**: Backport 'Fix user and group related migrations calling the actual record classes' to v0.26 [\#11010](https://github.com/decidim/decidim/pull/11010)
- **decidim-budgets**: Backport 'Fix budgets zero single view' to v0.26 [\#11016](https://github.com/decidim/decidim/pull/11016)
- **decidim-conferences**: Backport 'Fix partner type in Conferences' partners edit form' to v0.26 [\#11018](https://github.com/decidim/decidim/pull/11018)
- **decidim-core**: Backport 'Fix do not count blocked users to stats' to v0.26 [\#11028](https://github.com/decidim/decidim/pull/11028)
- **decidim-elections**: Backport 'Fix error message mismatch in election' to v0.26 [\#11034](https://github.com/decidim/decidim/pull/11034)
- **decidim-admin**: Backport 'Don't allow access to admin panel without ToS acceptance' to v0.26 [\#11047](https://github.com/decidim/decidim/pull/11047)
- **decidim-core**: Backport 'Fix webpacker crashes on missing icons' to v0.26 [\#11045](https://github.com/decidim/decidim/pull/11045)
- **decidim-core**: Backport 'Fix error when SVG icon is not available in the file system' to v0.26 [\#11008](https://github.com/decidim/decidim/pull/11008)
- **decidim-elections**: Backport 'Fix Admin dashboard disappear if you are in Trustee Zone' to v0.26 [\#11113](https://github.com/decidim/decidim/pull/11113)
- **decidim-budgets**: Backport 'Show all projects if none is selected when the voting has finished' to v0.26 [\#11119](https://github.com/decidim/decidim/pull/11119)
- **decidim-proposals**: Backport 'Fix flaky collaborative drafts spec' to v0.26 [\#11128](https://github.com/decidim/decidim/pull/11128)
- Backport 'Fix webpack version to <5.83.0' to v0.26 [\#11134](https://github.com/decidim/decidim/pull/11134)
- **decidim-participatory processes**: Backport 'Fix the active filter for process groups' to v0.26 [\#11129](https://github.com/decidim/decidim/pull/11129)
- **decidim-core**: Backport 'Fix uninitialized constant errors with custom set of modules' to v0.26 [\#11168](https://github.com/decidim/decidim/pull/11168)
- **decidim-core**: Backport 'Verify modules are installed in StatsParticipantsCount query' to v0.26 [\#11158](https://github.com/decidim/decidim/pull/11158)
- **decidim-core**: Backport 'Fix issues with overriding maps and loading Leaflet' to v0.26 [\#11132](https://github.com/decidim/decidim/pull/11132)
- **decidim-elections**: Backport 'Fix for saving an Election that wasn't blocked' to v0.26 [\#11188](https://github.com/decidim/decidim/pull/11188)
- **decidim-elections**, **decidim-initiatives**: Backport 'CSV & JSON export function fix' to v0.26 [\#11186](https://github.com/decidim/decidim/pull/11186)
- **decidim-budgets**: Backport 'Fix the unused keyword arguments for the budgets workflows' to v0.26 [\#11227](https://github.com/decidim/decidim/pull/11227)
- **decidim-budgets**, **decidim-elections**: Backport 'Budgets component fix for Votings module' to v0.26 [\#11230](https://github.com/decidim/decidim/pull/11230)
- **decidim-admin**: Backport 'Fix blocked users not present in global moderation panel' to v0.26 [\#11235](https://github.com/decidim/decidim/pull/11235)
- **decidim-core**, **decidim-meetings**, **decidim-proposals**: Backport 'Always allow image upload in WYSWYG editor' to v0.26 [\#11238](https://github.com/decidim/decidim/pull/11238)
- **decidim-assemblies**, **decidim-conferences**, **decidim-participatory processes**, **decidim-proposals**: Backport 'Fix proposals' valuators assignments not deleted when space admin is removed' to v0.26 [\#11331](https://github.com/decidim/decidim/pull/11331)
- **decidim-admin**: Backport 'Fix HTML titles in admin panel' to v0.26 [\#11334](https://github.com/decidim/decidim/pull/11334)
- **decidim-admin**: Backport 'Fix HTML titles in admin panel (part 2)' to v0.26 [\#11335](https://github.com/decidim/decidim/pull/11335)
- **decidim-admin**, **decidim-assemblies**, **decidim-blogs**, **decidim-conferences**, **decidim-core**, **decidim-elections**, **decidim-initiatives**, **decidim-participatory processes**, **decidim-templates**: Backport 'Enforce resources being found in the organization scope' to v0.26 [\#11231](https://github.com/decidim/decidim/pull/11231)

### Removed

Nothing.

### Internal

- Backport 'Fix flaky collaborative drafts spec' to v0.26 [\#11128](https://github.com/decidim/decidim/pull/11128)

### Developer improvements

Nothing.

## [0.26.7](https://github.com/decidim/decidim/tree/v0.26.7)

### Security fixes

This release addresses several security issues, including the following:

* [CVE-2023-32693](https://github.com/decidim/decidim/security/advisories/GHSA-469h-mqg8-535r)
* [CVE-2023-34089](https://github.com/decidim/decidim/security/advisories/GHSA-5652-92r9-3fx9)

The details regarding the security vulnerability will be published on July 11th 2023, which is two months after the release date of this version. For more information, please refer to our [Security Policy](https://github.com/decidim/decidim/blob/develop/SECURITY.md).

We highly recommend updating to this version as soon as possible to ensure the security of your system.

### Added

Nothing.

### Changed

- **decidim-core**: Backport 'Improve the link handling' to v0.26 [\#10734](https://github.com/decidim/decidim/pull/10734)

### Fixed

- **decidim-core**: Backport 'Fix sass syntax errors' to v0.26 [\#10446](https://github.com/decidim/decidim/pull/10446)
- **decidim-admin**: Backport 'Fix deleting all content from help section triggers error' to v0.26 [\#10454](https://github.com/decidim/decidim/pull/10454)
- **decidim-admin**: Backport 'Fix deprecation warning in the `html5sortable` NPM package' to v0.26 [\#10456](https://github.com/decidim/decidim/pull/10456)
- **decidim-proposals**: Backport 'Fix participatory texts sections required field indicators' to v0.26 [\#10528](https://github.com/decidim/decidim/pull/10528)
- **decidim-initiatives**: Backport 'Remove email from initiative's print page' to v0.26 [\#10534](https://github.com/decidim/decidim/pull/10534)
- **decidim-core**, **decidim-participatory processes**: Backport 'Fix destroying scope types that have been associated with processes' to v0.26 [\#10529](https://github.com/decidim/decidim/pull/10529)
- **decidim-meetings**: Backport 'Fix meeting form for admin to update registrations_enabled field' to v0.26 [\#10533](https://github.com/decidim/decidim/pull/10533)
- **decidim-admin**, **decidim-core**, **decidim-system**: Backport 'Remove actions from admin and blocked users' to v0.26 [\#10537](https://github.com/decidim/decidim/pull/10537)
- **decidim-core**: Backport 'Make buttons respect the organizations' primary color' to v0.26 [\#10545](https://github.com/decidim/decidim/pull/10545)
- **decidim-proposals**: Backport 'Export proposal body without HTML tags' to v0.26 [\#10538](https://github.com/decidim/decidim/pull/10538)
- **decidim-proposals**: Backport 'Fix: Set required to proposal limit field in Proposal component' to v0.26 [\#10550](https://github.com/decidim/decidim/pull/10550)
- Fix missing documentation link [\#10622](https://github.com/decidim/decidim/pull/10622)
- **decidim-comments**: Backport 'Fix for exporting deleted and hidden comments' to v0.26 [\#10659](https://github.com/decidim/decidim/pull/10659)
- **decidim-proposals**: Backport 'Fix for exporting hidden moderated proposals' to v0.26 [\#10660](https://github.com/decidim/decidim/pull/10660)
- **decidim-proposals**: Backport 'Fix flaky collaborative drafts specs' to v0.26 [\#10668](https://github.com/decidim/decidim/pull/10668)
- **decidim-admin**: Backport 'Change I18n captions on moderation module' to v0.26 [\#10663](https://github.com/decidim/decidim/pull/10663)
- **decidim-proposals**: Backport 'Fix empty proposals component configuration limits' to v0.26 [\#10665](https://github.com/decidim/decidim/pull/10665)
- **decidim-admin**, **decidim-core**, **decidim-elections**, **decidim-meetings**: Backport 'Fix Redundant notifications when a component is (re)published' to v0.26 [\#10737](https://github.com/decidim/decidim/pull/10737)
- **decidim-initiatives**: Backport 'Fix initiatives display when not initialized' to v0.26 [\#10741](https://github.com/decidim/decidim/pull/10741)
- **decidim-admin**, **decidim-assemblies**, **decidim-blogs**, **decidim-budgets**, **decidim-conferences**, **decidim-consultations**, **decidim-core**, **decidim-elections**, **decidim-forms**, **decidim-initiatives**, **decidim-meetings**, **decidim-pages**, **decidim-proposals**, **decidim-sortitions**: Backport 'Fix editor toolbar' to v0.26 [\#10744](https://github.com/decidim/decidim/pull/10744)
- **decidim-participatory processes**: Backport 'Fix Empty participatory process group is created when importing a PP …' to v0.26 [\#10733](https://github.com/decidim/decidim/pull/10733)
- Backport 'Fix menu spec after #9928' to v0.26 [\#10768](https://github.com/decidim/decidim/pull/10768)
- **decidim-consultations**: Backport 'Add missing translations in consultations' to v0.26 [\#10789](https://github.com/decidim/decidim/pull/10789)
- **decidim-budgets**, **decidim-proposals**: Backport 'Supports no longer visible for linked proposals if supports are disabled' to v0.26 [\#10776](https://github.com/decidim/decidim/pull/10776)
- **decidim-initiatives**: Backport 'Fix initiative creation missing form fields' to v0.26 [\#10786](https://github.com/decidim/decidim/pull/10786)
- **decidim-initiatives**: Backport 'Fix edge case in initiative creation' to v0.26 [\#10783](https://github.com/decidim/decidim/pull/10783)
- **decidim-proposals**: Backport 'Fix notifications for the proposal answers importer' to v0.26 [\#10788](https://github.com/decidim/decidim/pull/10788)
- **decidim-comments**: Backport 'Fix missing hide and show comments by threads' to v0.26 [\#10780](https://github.com/decidim/decidim/pull/10780)
- **decidim-meetings**, **decidim-proposals**: Backport 'Fix invalid rendering of meeting and proposal body texts' to v0.26 [\#10806](https://github.com/decidim/decidim/pull/10806)
- **decidim-core**, **decidim-meetings**: Backport 'Fix iframe disabling producing invalid HTML' to v0.26 [\#10764](https://github.com/decidim/decidim/pull/10764)
- **decidim-participatory processes**: Backport 'Fix issues with unexpected date filter params for the process listing' to v0.26 [\#10808](https://github.com/decidim/decidim/pull/10808)
- **decidim-initiatives**: Backport 'Fix edit form in intitiatives' to v0.26 [\#10782](https://github.com/decidim/decidim/pull/10782)
- **decidim-participatory processes**: Backport 'Fix usages of sanitize helper methods for editable content provided by admins' to v0.26 [\#10059](https://github.com/decidim/decidim/pull/10059)
- **decidim-debates**, **decidim-meetings**, **decidim-proposals**: Backport 'Fix iframes stripped from admin entered proposals, meetings and debates' to v0.26 [\#10559](https://github.com/decidim/decidim/pull/10559)
- **decidim-core**: Backport 'Fix: Inconsistent datetime distance_in_words translations' to 0.26 [\#10795](https://github.com/decidim/decidim/pull/10795)
- **decidim-assemblies**, **decidim-blogs**, **decidim-budgets**, **decidim-consultations**, **decidim-debates**, **decidim-elections**, **decidim-forms**, **decidim-pages**, **decidim-participatory processes**, **decidim-proposals**, **decidim-sortitions**: Backport 'Fix Video embeds are not shown in short_description field' to v0.26 [\#10746](https://github.com/decidim/decidim/pull/10746)
- **decidim-budgets**: Backport 'Fix budget summary mail when a scope is defined and enabled' to v0.26 [\#10840](https://github.com/decidim/decidim/pull/10840)
- **decidim-initiatives**: Backport 'Change the participant initiatives editor toolbars type' to v0.26 [\#10845](https://github.com/decidim/decidim/pull/10845)

### Removed

Nothing.

### Internal

- Backport 'Switch to the official Codecov action for CI' to v0.26 [\#10463](https://github.com/decidim/decidim/pull/10463)
- Backport 'Fix flaky collaborative drafts specs' to v0.26 [\#10668](https://github.com/decidim/decidim/pull/10668)
- Backport 'Fix menu spec after #9928' to v0.26 [\#10768](https://github.com/decidim/decidim/pull/10768)

### Developer improvements

Nothing.

## [0.26.5](https://github.com/decidim/decidim/tree/v0.26.5)
### Added

Nothing.

### Changed

Nothing.

### Fixed

- **decidim-core**: Backport 'Fix: The i18n locales selector is showing a dropdown with 3 languages' to v0.26 [\#10086](https://github.com/decidim/decidim/pull/10086)
- Backport 'Lock GitHub actions to Ubuntu 20.04 due to OpenSSL 3.0 issues' to v0.26 [\#10226](https://github.com/decidim/decidim/pull/10226)
- **decidim-api**, **decidim-core**: Backport 'Fix machine translations at the API' to v0.26 [\#10292](https://github.com/decidim/decidim/pull/10292)
- **decidim-budgets**: Backport 'Correct the "voted for this" string in the budgets component' to v0.26 [\#10301](https://github.com/decidim/decidim/pull/10301)
- **decidim-conferences**, **decidim-core**: Backport 'Fix translations missing on admin log' to v0.26 [\#10293](https://github.com/decidim/decidim/pull/10293)
- **decidim-conferences**: Backport 'Add correct call for conference speaker' to v0.26 [\#10294](https://github.com/decidim/decidim/pull/10294)
- **decidim-meetings**: Backport 'Fix missing fields on duplicate meetings functionality' to v0.26 [\#10295](https://github.com/decidim/decidim/pull/10295)
- **decidim-core**: Backport 'Fix resource_icon with component or manifest nil' to v0.26 [\#10296](https://github.com/decidim/decidim/pull/10296)
- **decidim-core**: Backport 'Add missing logs for UserGroup block and unblock actions' to v0.26 [\#10313](https://github.com/decidim/decidim/pull/10313)
- **decidim-admin**, **decidim-core**: Backport 'Don't show the 'unreport' action when user is blocked' to v0.26 [\#10300](https://github.com/decidim/decidim/pull/10300)
- **decidim-core**: Backport 'Add order by in linked_participatory_space_resources' to v0.26 [\#10303](https://github.com/decidim/decidim/pull/10303)
- **decidim-blogs**: Backport 'Move i18n attribute key of Post's body' to v0.26 [\#10298](https://github.com/decidim/decidim/pull/10298)
- **decidim-core**: Improve link handling of the redirect engine (#10306) [\#10306](https://github.com/decidim/decidim/pull/10306)
- **decidim-proposals**: Backport 'Removed "disabled" status from proposals' main categories' to v0.26 [\#10305](https://github.com/decidim/decidim/pull/10305)
- **decidim-initiatives**: Backport 'Respect "rich text editor" setting in Initiatives' to v0.26 [\#10304](https://github.com/decidim/decidim/pull/10304)
- **decidim-proposals**: Backport 'Prevent sending proposal create event until is commited' to v0.26 [\#10309](https://github.com/decidim/decidim/pull/10309)
- **decidim-initiatives**: Backport 'Fix initiatives count in initiatives index page' to v0.26 [\#10310](https://github.com/decidim/decidim/pull/10310)
- **decidim-blogs**: Backport 'Remove unused permissions on Blogs' to v0.26 [\#10299](https://github.com/decidim/decidim/pull/10299)
- **decidim-admin**, **decidim-assemblies**, **decidim-elections**, **decidim-initiatives**, **decidim-pages**, **decidim-participatory processes**: Backport 'Fix wrong capitalization in i18n values and add missing keys' to v0.26 [\#10302](https://github.com/decidim/decidim/pull/10302)
- **decidim-accountability**, **decidim-initiatives**, **decidim-participatory processes**: Backport 'Added missing localizations' to v0.26 [\#10308](https://github.com/decidim/decidim/pull/10308)
- **decidim-core**: Backport 'Allow blocking a UserGroup' to v0.26 [\#10315](https://github.com/decidim/decidim/pull/10315)
- **decidim-budgets**, **decidim-core**, **decidim-debates**, **decidim-meetings**, **decidim-proposals**, **decidim-sortitions**: Backport 'Fix filter URL not updated with the text search input' to v0.26 [\#10297](https://github.com/decidim/decidim/pull/10297)
- **decidim-admin**, **decidim-core**: Backport 'Fix bug when blocking two UserGroups' to v0.26 [\#10312](https://github.com/decidim/decidim/pull/10312)
- **decidim-core**: Backport 'Fix bug regarding user group moderation action logs' to v0.26 [\#10314](https://github.com/decidim/decidim/pull/10314)
- **decidim-core**: Backport 'User's group endorsement no longer disappears after personal endorsement removed' to v0.26 [\#10311](https://github.com/decidim/decidim/pull/10311)
- **decidim-assemblies**, **decidim-conferences**, **decidim-participatory processes**: Backport 'Do not display unpublished spaces in linked spaces' to v0.26 [\#10345](https://github.com/decidim/decidim/pull/10345)
- **decidim-assemblies**, **decidim-meetings**: Backport 'Display Published meetings in Assembly cell' to v0.26 [\#10341](https://github.com/decidim/decidim/pull/10341)
- **decidim-admin**, **decidim-core**: Backport 'Fix newsletters unwanted CSS and 404 page on preview' to v0.26 [\#10355](https://github.com/decidim/decidim/pull/10355)
- **decidim-admin**: Backport 'A Valuator should not be able to access Global Moderation' to v0.26 [\#10349](https://github.com/decidim/decidim/pull/10349)
- **decidim-initiatives**: Backport 'Fixing some typos in the english translations' to v0.26 [\#10362](https://github.com/decidim/decidim/pull/10362)

### Removed

Nothing.

### Internal

- Backport 'Lock GitHub actions to Ubuntu 20.04 due to OpenSSL 3.0 issues' to v0.26 [\#10226](https://github.com/decidim/decidim/pull/10226)

### Developer improvements

Nothing.

### Unsorted

Nothing.

## [0.26.4](https://github.com/decidim/decidim/tree/v0.26.4)

### Added

Nothing.

### Changed

Nothing.

### Fixed

- **decidim-core**: Backport 'Prevent the account edit route through Devise' to v0.26 [\#9932](https://github.com/decidim/decidim/pull/9932)
- **decidim-participatory processes**: Backport 'Fix unpublished processes shown in the group process count' to v0.26 [\#9934](https://github.com/decidim/decidim/pull/9934)
- **decidim-admin**: Backport 'Fix global moderation types not translated' to v0.26 [\#9937](https://github.com/decidim/decidim/pull/9937)
- **decidim-admin**: Backport 'Fix updating organization settings in case there were errors' to v0.26 [\#9938](https://github.com/decidim/decidim/pull/9938)
- **decidim-budgets**, **decidim-core**, **decidim-elections**, **decidim-proposals**: Backport 'Do not import resources multiple times' to v0.26 [\#9942](https://github.com/decidim/decidim/pull/9942)
- **decidim-forms**, **decidim-surveys**: Backport 'Fix form answer attachments breaking the answer view' to v0.26 [\#9945](https://github.com/decidim/decidim/pull/9945)
- **decidim-comments**: Backport 'Fix "disappearing" underscores with comments' to v0.26 [\#9949](https://github.com/decidim/decidim/pull/9949)
- **decidim-admin**, **decidim-core**: Backport 'Fix editor content saving when the content has only one video' to v0.26 [\#9951](https://github.com/decidim/decidim/pull/9951)
- **decidim-proposals**: Backport 'Fix collaborative drafts page when there are errors on the form' to v0.26 [\#9955](https://github.com/decidim/decidim/pull/9955)
- **decidim-debates**: Backport 'Fix the finite value on the debate form when editing an existing debate' to v0.26 [\#9957](https://github.com/decidim/decidim/pull/9957)
- **decidim-pages**: Backport 'Fix exporting and importing a page component' to v0.26 [\#9959](https://github.com/decidim/decidim/pull/9959)
- **decidim-participatory processes**: Backport 'Fix importing participatory process from legacy format' to v0.26 [\#9964](https://github.com/decidim/decidim/pull/9964)
- **decidim-assemblies**, **decidim-core**, **decidim-participatory processes**: Backport 'Fix duplicate stats on home page and participatory space main page' to v0.26 [\#9966](https://github.com/decidim/decidim/pull/9966)
- **decidim-budgets**, **decidim-core**, **decidim-proposals**, **decidim-templates**: Backport 'Address Crowdin feedback' to v0.26 [\#9970](https://github.com/decidim/decidim/pull/9970)
- **decidim-core**: Backport 'Limit invitation redirects only to paths within the application' to v0.26 [\#9973](https://github.com/decidim/decidim/pull/9973)
- **decidim-initiatives**: Backport 'Fix initiative sign if the authorization metadata is set to `nil`' to v0.26 [\#9981](https://github.com/decidim/decidim/pull/9981)
- **decidim-initiatives**: Backport 'Add missing i18n key in Initiatives' to v0.26 [\#9983](https://github.com/decidim/decidim/pull/9983)
- **decidim-core**: Backport 'Fix correct resource linking for amendments' to v0.26 [\#9988](https://github.com/decidim/decidim/pull/9988)
- **decidim-core**: Backport 'Fix user sign up with invalid name' to v0.26 [\#9991](https://github.com/decidim/decidim/pull/9991)
- **decidim-initiatives**: Backport 'Make initiatives order translatable' to v0.26 [\#9995](https://github.com/decidim/decidim/pull/9995)
- **decidim-core**: Backport 'Make ToS agreement translatable' to v0.26 [\#9997](https://github.com/decidim/decidim/pull/9997)
- **decidim-debates**: Backport 'Make Scopes field in debates translatable' to v0.26 [\#9999](https://github.com/decidim/decidim/pull/9999)
- **decidim-core**: Backport 'Remove invitations badge' to v0.26 [\#10001](https://github.com/decidim/decidim/pull/10001)
- **decidim-conferences**: Backport 'Fix conference invitations' to v0.26 [\#10004](https://github.com/decidim/decidim/pull/10004)
- **decidim-admin**, **decidim-core**: Backport 'Fix preserving bold text in the rich text editor when pasting content' to v0.26 [\#9962](https://github.com/decidim/decidim/pull/9962)
- **decidim-admin**, **decidim-assemblies**, **decidim-initiatives**, **decidim-participatory processes**, **decidim-verifications**: Backport 'Add missing active actions on admin navigation menu' to v0.26 [\#9993](https://github.com/decidim/decidim/pull/9993)
- **decidim-core**: Backport 'Fix disappearing sub-lists in rich text editors' to v0.26 [\#9968](https://github.com/decidim/decidim/pull/9968)
- **decidim-elections**: Backport 'Define the component import routes, permissions and controller at votings' to v0.26 [\#9977](https://github.com/decidim/decidim/pull/9977)
- **decidim-core**, **decidim-proposals**: Backport 'Fix proposal etiquette and length validator with base64 images' to v0.26 [\#10010](https://github.com/decidim/decidim/pull/10010)
- **decidim-core**, **decidim-debates**, **decidim-meetings**, **decidim-proposals**: Backport 'Refactor cell titles' to v0.26 [\#10041](https://github.com/decidim/decidim/pull/10041)
- **decidim-admin**, **decidim-comments**: Backport 'Fix moderations for comments that are mapped to deleted resources' to v0.26 [\#9941](https://github.com/decidim/decidim/pull/9941)
- **decidim-comments**, **decidim-core**, **decidim-verifications**: Backport 'Fix user related absolute URLs' to v0.26 [\#9947](https://github.com/decidim/decidim/pull/9947)
- **decidim-core**: Backport 'Fix duplicate user activity records when public spaces have private users' to v0.26 [\#9979](https://github.com/decidim/decidim/pull/9979)
- **decidim-meetings**: Backport 'Refactor the meeting list item title display' to v0.26 [\#10047](https://github.com/decidim/decidim/pull/10047)
- **decidim-accountability**, **decidim-admin**, **decidim-proposals**: Backport 'Reformat CSV help for import files on Accountability and Proposals' to v0.26 [\#10055](https://github.com/decidim/decidim/pull/10055)
- **decidim-system**: Backport 'Fix organization SMTP password not saved (became blank) in system panel' to v0.26 [\#10053](https://github.com/decidim/decidim/pull/10053)
- **decidim-budgets**, **decidim-elections**, **decidim-proposals**, **decidim-sortitions**: Backport 'Fix usages of `reorder` and `paginate`' to v0.26 [\#10051](https://github.com/decidim/decidim/pull/10051)
- **decidim-admin**: Backport 'Show only ToS acceptance when admin hasn't accepted it' to v0.26 [\#10057](https://github.com/decidim/decidim/pull/10057)
- **decidim-debates**, **decidim-meetings**, **decidim-proposals**: Backport 'Refactor admin listing titles' to v0.26 [\#10049](https://github.com/decidim/decidim/pull/10049)
- **decidim-core**: Backport 'Fix date/time formats at component forms' to v0.26 [\#9953](https://github.com/decidim/decidim/pull/9953)

### Removed

Nothing.

### Internal

- Backport 'Fix importing a page component without a body' to v0.26 [\#10023](https://github.com/decidim/decidim/pull/10023)

### Developer improvements

Nothing.

## [0.26.3](https://github.com/decidim/decidim/tree/v0.26.3)

### Added

Nothing.

### Changed

Nothing.

### Fixed

- **decidim-core**: Backport 'Fix / Expose createMapController properly to let overriding' to v0.26 [\#9520](https://github.com/decidim/decidim/pull/9520)
- **decidim-elections**: Backport 'Capture unhandled errors from JS promises and inform the user' to v0.26 [\#9521](https://github.com/decidim/decidim/pull/9521)
- **decidim-elections**: Backport 'Remove description from questions in elections' to v0.26 [\#9522](https://github.com/decidim/decidim/pull/9522)
- **decidim-initiatives**: Backport 'Return 404 when there isn't an initiative' to v0.26 [\#9523](https://github.com/decidim/decidim/pull/9523)
- **decidim-forms**, **decidim-meetings**, **decidim-surveys**: Backport 'Fix rollback questionnaire answer when file is invalid' to v0.26 [\#9524](https://github.com/decidim/decidim/pull/9524)
- **decidim-elections**: Backport 'Make sure component is published when starting an election' to v0.26 [\#9525](https://github.com/decidim/decidim/pull/9525)
- **decidim-core**, **decidim-meetings**, **decidim-proposals**: Backport 'Fix email subject when resource title has special characters' to v0.26 [\#9526](https://github.com/decidim/decidim/pull/9526)
- **decidim-core**: Backport 'Prevent users to validate nicknames/emails taken by user groups' to v0.26 [\#9527](https://github.com/decidim/decidim/pull/9527)
- **decidim-elections**: Backport 'Fix hardcoded hour in election dashboard' to v0.26 [\#9528](https://github.com/decidim/decidim/pull/9528)
- **decidim-comments**, **decidim-core**: Backport 'Fix long word breaking on comments and cards' to v0.26 [\#9529](https://github.com/decidim/decidim/pull/9529)
- **decidim-assemblies**, **decidim-conferences**, **decidim-consultations**, **decidim-core**, **decidim-elections**, **decidim-initiatives**, **decidim-participatory processes**: Backport 'Fix background-image URLs with weird characters' to v0.26 [\#9531](https://github.com/decidim/decidim/pull/9531)
- **decidim-assemblies**, **decidim-conferences**, **decidim-elections**: Backport 'Fix cache hash on Hightlighted spaces' to v0.26 [\#9536](https://github.com/decidim/decidim/pull/9536)
- **decidim-accountability**: Backport 'Add short format to result date' to v0.26 [\#9540](https://github.com/decidim/decidim/pull/9540)
- **decidim-elections**: Backport 'Advertise users if BB connection is lost in trustees/admin zones' to v0.26 [\#9535](https://github.com/decidim/decidim/pull/9535)
- **decidim-core**: Backport 'Fix email subject when participatory space title is present' to v0.26 [\#9573](https://github.com/decidim/decidim/pull/9573)
- **decidim-conferences**: Backport 'Fix published conferences order' to v0.26 [\#9688](https://github.com/decidim/decidim/pull/9688)
- **decidim-comments**: Backport 'Fix creation notification when editing a comment ' to v0.26 [\#9690](https://github.com/decidim/decidim/pull/9690)
- **decidim-elections**: Backport 'Remove margin-bottom on votings navigation' to v0.26 [\#9692](https://github.com/decidim/decidim/pull/9692)
- **decidim-initiatives**: Backport 'Use public link on initiatives mailer' to v0.26 [\#9694](https://github.com/decidim/decidim/pull/9694)
- **decidim-accountability**: Backport 'Disallow creating grandchildren results' to v0.26 [\#9698](https://github.com/decidim/decidim/pull/9698)
- **decidim-forms**, **decidim-meetings**: Backport 'Prevent showing announcement on meetings registrations' to v0.26 [\#9700](https://github.com/decidim/decidim/pull/9700)
- **decidim-initiatives**: Backport 'Fix for initiative mailer when promoting committee is disabled' to v0.26 [\#9696](https://github.com/decidim/decidim/pull/9696)
- **decidim-elections**: Backport 'Improve steps election check page with census' to v0.26 [\#9702](https://github.com/decidim/decidim/pull/9702)
- **decidim-core**: Backport 'Fix translated attributes field type change' to v0.26 [\#9704](https://github.com/decidim/decidim/pull/9704)
- **decidim-core**: Backport 'Prevent missing ActionLog entries to break the application' to v0.26 [\#9706](https://github.com/decidim/decidim/pull/9706)
- **decidim-proposals**: Backport 'Fix publish event on official proposals' to v0.26 [\#9708](https://github.com/decidim/decidim/pull/9708)
- **decidim-admin**, **decidim-proposals**: Backport 'Add help text for proposals' 'publish answers immediately' setting ' to v0.26 [\#9712](https://github.com/decidim/decidim/pull/9712)
- **decidim-conferences**: Backport 'Return 404 when there isn't a valid component in program' to v0.26 [\#9717](https://github.com/decidim/decidim/pull/9717)
- **decidim-budgets**: Backport 'Fix budgets seeds on non development apps' to v0.26 [\#9719](https://github.com/decidim/decidim/pull/9719)
- **decidim-core**: Backport 'Fix creating automatic nicknames when taken by user_groups' to v0.26 [\#9721](https://github.com/decidim/decidim/pull/9721)
- **decidim-debates**: Backport 'Fix resource endorsed notification with Debates' to v0.26 [\#9723](https://github.com/decidim/decidim/pull/9723)
- **decidim-meetings**: Backport 'Fix agenda_item association with agenda' to v0.26 [\#9728](https://github.com/decidim/decidim/pull/9728)
- **decidim-verifications**: Backport 'Fix absolute urls on 'managed user error' event' to v0.26 [\#9730](https://github.com/decidim/decidim/pull/9730)
- **decidim-core**: Backport 'Fix mobile notifications switch component overlaps' to v0.26 [\#9732](https://github.com/decidim/decidim/pull/9732)
- **decidim-core**: Backport 'Fix blocked user nickname and avatar in user presenter' to v0.26 [\#9741](https://github.com/decidim/decidim/pull/9741)
- **decidim-admin**: Backport 'Fix form error overlap with character counter in the admin panel' to v0.26 [\#9749](https://github.com/decidim/decidim/pull/9749)
- **decidim-core**: Backport 'Fix the endorsement permissions' to v0.26 [\#9734](https://github.com/decidim/decidim/pull/9734)
- **decidim-meetings**: Backport 'Fix order when filtering Meetings' to v0.26 [\#9751](https://github.com/decidim/decidim/pull/9751)
- **decidim-proposals**: Backport 'Fix redundant notification on comments with linked proposals' to v0.26 [\#9746](https://github.com/decidim/decidim/pull/9746)
- **decidim-core**: Backport 'Make the HERE Map display in the currently selected language' to v0.26 [\#9714](https://github.com/decidim/decidim/pull/9714)
- **decidim-admin**, **decidim-forms**: Backport 'Fix admin language selector with more than 4 locales' to v0.26 [\#9710](https://github.com/decidim/decidim/pull/9710)
- **decidim-meetings**: Backport 'Ignore participatory spaces without models in meetings visible_for scope' to v0.26 [\#9794](https://github.com/decidim/decidim/pull/9794)
- **decidim-admin**: Backport 'Fix leaking emails on admin user search controller' to 0.26 [\#9797](https://github.com/decidim/decidim/pull/9797)
- **decidim-assemblies**, **decidim-participatory processes**: Backport 'Fix import of images on spaces' to v0.26 [\#9803](https://github.com/decidim/decidim/pull/9803)
- **decidim-core**: Backport 'Fix hashtags not recognized at the beginning of the string' to v0.26 [\#9811](https://github.com/decidim/decidim/pull/9811)
- **decidim-accountability**, **decidim-core**, **decidim-debates**, **decidim-initiatives**, **decidim-meetings**, **decidim-proposals**: Backport 'Fix version pages showing a HTTP 500 error when the version does not exist' to v0.26 [\#9809](https://github.com/decidim/decidim/pull/9809)
- **decidim-core**: Backport 'Fix hidden error messages on the registration form' to v0.26 [\#9813](https://github.com/decidim/decidim/pull/9813)
- **decidim-core**: Backport 'Fix multitenant organizations stats cache' to v0.26 [\#9807](https://github.com/decidim/decidim/pull/9807)
- **decidim-admin**, **decidim-initiatives**: Backport 'Fix initiatives components' to v0.26 [\#9825](https://github.com/decidim/decidim/pull/9825)
- Backport 'Fix doorkeeper initialization after 5.6.0 release' to v0.26 [\#9788](https://github.com/decidim/decidim/pull/9788)

### Removed

Nothing.

### Internal

- Backport 'Fix invalid translation in spec' to v0.26 [\#9435](https://github.com/decidim/decidim/pull/9435)
- Backport 'Remove the description field from the elections component seeds' to v0.26 [\#9553](https://github.com/decidim/decidim/pull/9553)
- Fix API GraphiQL system spec for 0.26 with newer ChromeDriver [\#9556](https://github.com/decidim/decidim/pull/9556)
- Backport 'Update `rokroskar/workflow-run-cleanup-action` GitHub action to v0.3.3' to v0.26 [\#9829](https://github.com/decidim/decidim/pull/9829)
- Backport 'Split parallel test coverage reports into their own folders' to v0.26 [\#9819](https://github.com/decidim/decidim/pull/9819)
- Backport 'Improve release process' to v0.26 [\#9864](https://github.com/decidim/decidim/pull/9864)

### Developer improvements

Nothing.

## [0.26.2](https://github.com/decidim/decidim/tree/v0.26.2)

### Added

Nothing.

### Changed

Nothing.

### Fixed

- **decidim-comments**, **decidim-core**, **decidim-meetings**: Backport "Fix timeout in comment view and during meetings" to v0.26 [\#9091](https://github.com/decidim/decidim/pull/9091)
- **decidim-core**: Backport "Dont add external link container inside editor" to v0.26 [\#9108](https://github.com/decidim/decidim/pull/9108)
- **decidim-core**: Backport "Add base URI to meta image URLs" to v0.26 [\#9153](https://github.com/decidim/decidim/pull/9153)
- **decidim-initiatives**: Backport "Remove 'edit link' in topbar for initiative's authors" to v0.26 [\#9239](https://github.com/decidim/decidim/pull/9239)
- **decidim-elections**: Backport 'Clarify message to user when checking census' to v0.26 [\#9240](https://github.com/decidim/decidim/pull/9240)
- **decidim-participatory processes**: Backport 'Fix processes count in processes group title cell' to v0.26 [\#9242](https://github.com/decidim/decidim/pull/9242)
- **decidim-elections**: Backport 'Improve wording when casting your vote' to v0.26 [\#9243](https://github.com/decidim/decidim/pull/9243)
- **decidim-proposals**: Backport 'Add 'not answered' as a possible answer in proposals' to v0.26 [\#9246](https://github.com/decidim/decidim/pull/9246)
- **decidim-meetings**: Backport 'Fix meetings minutes migration' to v0.26 [\#9247](https://github.com/decidim/decidim/pull/9247)
- **decidim-assemblies**, **decidim-proposals**: Backport "Fix absolute urls on 'assembly member' and 'collaborative drafts' events" to v0.26 [\#9248](https://github.com/decidim/decidim/pull/9248)
- **decidim-accountability**, **decidim-consultations**: Backport 'Fix components navbar in consultations mobile ' to v0.26 [\#9249](https://github.com/decidim/decidim/pull/9249)
- **decidim-meetings**: Backport 'Move modal to body and fix condition' to v0.26 [\#9250](https://github.com/decidim/decidim/pull/9250)
- **decidim-meetings**: Backport 'Do not send upcoming meeting notification for hidden or withdrawn meetings' to v0.26 [\#9251](https://github.com/decidim/decidim/pull/9251)
- **decidim-core**: Backport 'Show only current organization in verification conflicts with multitenants' to v0.26 [\#9252](https://github.com/decidim/decidim/pull/9252)
- **decidim-elections**: Backport 'Send email to newly added trustees' to v0.26 [\#9253](https://github.com/decidim/decidim/pull/9253)
- **decidim-meetings**: Backport 'Fix registration type field highlighted in admin meeting creation form' to v0.26 [\#9254](https://github.com/decidim/decidim/pull/9254)
- **decidim-surveys**: Backport 'Fix contradictory form errors on survey form' to v0.26 [\#9257](https://github.com/decidim/decidim/pull/9257)
- **decidim-initiatives**: Backport 'Add edit and delete actions in InitiativeType admin table' to v0.26 [\#9260](https://github.com/decidim/decidim/pull/9260)
- **decidim-surveys**: Backport 'Clarify unregistered answers on surveys behavior' to v0.26 [\#9261](https://github.com/decidim/decidim/pull/9261)
- **decidim-elections**: Backport 'Fix voting with single election' to v0.26 [\#9262](https://github.com/decidim/decidim/pull/9262)
- **decidim-initiatives**: Backport 'Fix initiative print link, margin, and organization logo' to v0.26 [\#9263](https://github.com/decidim/decidim/pull/9263)
- **decidim-elections**: Backport 'Remove show more button on elections' to v0.26 [\#9264](https://github.com/decidim/decidim/pull/9264)
- **decidim-surveys**: Backport 'Fix survey activity log entries' to v0.26 [\#9265](https://github.com/decidim/decidim/pull/9265)
- **decidim-budgets**: Backport 'Remove beforeunload confirmation panel from the budgets voting' to v0.26 [\#9266](https://github.com/decidim/decidim/pull/9266)
- **decidim-admin**, **decidim-elections**: Backport 'Fix newsletters and Decidim Votings' to v0.26 [\#9258](https://github.com/decidim/decidim/pull/9258)
- **decidim-core**: Backport 'Fix notifications where resources are missing' to v0.26 [\#9256](https://github.com/decidim/decidim/pull/9256)
- **decidim-core**: Backport 'Enforce password validation rules on 'Forgot your password?' form' to v0.26 [\#9245](https://github.com/decidim/decidim/pull/9245)
- **decidim-core**: Backport 'Fix displaying blocked users in account follow pages' to v0.26 [\#9255](https://github.com/decidim/decidim/pull/9255)
- **decidim-core**: Backport 'Fix Leaflet trying to load "infinite amount of tiles"' to v0.26  [\#9269](https://github.com/decidim/decidim/pull/9269)
- **decidim-system**: Backport 'Enforce password validation rules on system admins' to v0.26 [\#9259](https://github.com/decidim/decidim/pull/9259)
- **decidim-meetings**: Backport 'Remove presenters in the meetings admin backoffice' to v0.26 [\#9323](https://github.com/decidim/decidim/pull/9323)
- **decidim-elections**: Backport 'Correctly show trustees and votings menu' to v0.26 [\#9324](https://github.com/decidim/decidim/pull/9324)
- **decidim-core**: Backport 'Fix hashtag parsing on URLs with fragments' to v0.26 [\#9326](https://github.com/decidim/decidim/pull/9326)
- **decidim-comments**, **decidim-core**: Backport 'Add missing events locales' to v0.26 [\#9327](https://github.com/decidim/decidim/pull/9327)
- **decidim-conferences**: Backport 'Make conference's partners logos always mandatory' to v0.26 [\#9328](https://github.com/decidim/decidim/pull/9328)
- **decidim-admin**: Backport 'Fix margin around warning message in colour settings' to v0.26 [\#9329](https://github.com/decidim/decidim/pull/9329)
- **decidim-elections**: Backport 'Hide more information link when there's no description on an election' to v0.26 [\#9331](https://github.com/decidim/decidim/pull/9331)
- **decidim-admin**, **decidim-assemblies**, **decidim-budgets**, **decidim-core**, **decidim-elections**, **decidim-meetings**, **decidim-pages**, **decidim-proposals**: Backport 'Apply crowdin feedback' to v0.26 [\#9333](https://github.com/decidim/decidim/pull/9333)
- **decidim-comments**, **decidim-core**: Backport 'Don't show deleted resources in last activities ' to v0.26 [\#9330](https://github.com/decidim/decidim/pull/9330)
- **decidim-elections**: Backport 'Fix election label translations' to v0.26 [\#9343](https://github.com/decidim/decidim/pull/9343)
- **decidim-verifications**: Backport 'Allow to renew expired verifications (if renewable)' to v0.26 [\#9344](https://github.com/decidim/decidim/pull/9344)
- **decidim-elections**: Backport 'Add error message when adding question and election has started' to v0.26 [\#9404](https://github.com/decidim/decidim/pull/9404)
- **decidim-core**: Backport 'Fix user interests' to v0.26 [\#9406](https://github.com/decidim/decidim/pull/9406)
- **decidim-elections**: Backport 'Fix regular expression on census check' to v0.26 [\#9408](https://github.com/decidim/decidim/pull/9408)
- **decidim-elections**: Backport 'Enforce YYYYmmdd format in birthdate when uploading census' to v0.26 [\#9410](https://github.com/decidim/decidim/pull/9410)
- **decidim-consultations**: Backport 'Return 404 when there isn't a question' to v0.26 [\#9414](https://github.com/decidim/decidim/pull/9414)
- **decidim-consultations**: Backport 'Return 404 when there isn't a consultation' to v0.26 [\#9413](https://github.com/decidim/decidim/pull/9413)
- **decidim-elections**: Backport 'Return 404 when there isn't a voting in elections_log' to v0.26 [\#9415](https://github.com/decidim/decidim/pull/9415)
- **decidim-proposals**: Backport 'Fix proposals creation with Participatory Texts ' to v0.26 [\#9416](https://github.com/decidim/decidim/pull/9416)
- **decidim-elections**: Backport 'Fix ActionLog when a ballot style is deleted' to v0.26 [\#9411](https://github.com/decidim/decidim/pull/9411)
- **decidim-elections**: Backport 'Only show that the code can be requested via SMS if its true' to v0.26 [\#9409](https://github.com/decidim/decidim/pull/9409)
- **decidim-budgets**, **decidim-proposals**: Backport 'Add missing translation keys proposals import and proposals picker' to v0.26 [\#9412](https://github.com/decidim/decidim/pull/9412)
- **decidim-elections**: Backport 'Fix HTML safe content in election voting' to v0.26 [\#9405](https://github.com/decidim/decidim/pull/9405)
- **decidim-core**: Backport 'Fix for internal links not displaying on page title' to v0.26 [\#9407](https://github.com/decidim/decidim/pull/9407)

### Removed

Nothing.

### Internal

- Backport 'Fix generators specs target branch' to v0.26 [\#9290](https://github.com/decidim/decidim/pull/9290)

### Developer improvements

Nothing.

## [0.26.1](https://github.com/decidim/decidim/tree/v0.26.1)

### Added

Nothing.

### Changed

Nothing.

### Fixed

- **decidim-meetings**: Backport "Fix the meetings export to also include unpublished meetings" to v0.26 [\#8939](https://github.com/decidim/decidim/pull/8939)
- **decidim-system**, **decidim-verifications**: Backport "Fix verification report with multitenants" to v0.26 [\#8940](https://github.com/decidim/decidim/pull/8940)
- **decidim-core**: Backport "Fix officialized user event missing translations" to v0.26 [\#8942](https://github.com/decidim/decidim/pull/8942)
- **decidim-verifications**: Backport "Fix email for verification conflict with managed users" to v0.26 [\#8945](https://github.com/decidim/decidim/pull/8945)
- **decidim-core**: Backport "Fix profile notifications" to v0.26 [\#8949](https://github.com/decidim/decidim/pull/8949)
- **decidim-assemblies**, **decidim-budgets**, **decidim-comments**, **decidim-consultations**, **decidim-core**, **decidim-elections**, **decidim-forms**, **decidim-initiatives**, **decidim-participatory processes**, **decidim-proposals**: Backport several accessibility fixes to v0.26 [\#8950](https://github.com/decidim/decidim/pull/8950)
- **decidim-core**: Backport "Add missing 'Locale' string in i18n in account page" to v0.26 [\#8980](https://github.com/decidim/decidim/pull/8980)
- **decidim-meetings**: Backport "Truncate the meetings card description" to v0.26 [\#8979](https://github.com/decidim/decidim/pull/8979)
- **decidim-proposals**: Backport "Fix proposals' cards with big images" to v0.26 [\#8978](https://github.com/decidim/decidim/pull/8978)
- **decidim-initiatives**: Backport "Fix link to docs in initiatives admin" to v0.26 [\#8975](https://github.com/decidim/decidim/pull/8975)
- **decidim-comments**: Backport "Fix budget hard dependency and caching flag issues in comments" to v0.26 [\#8973](https://github.com/decidim/decidim/pull/8973)
- **decidim-participatory processes**: Backport "Fix processes creation form with stats, metrics and announcements" to v0.26 [\#8977](https://github.com/decidim/decidim/pull/8977)
- **decidim-initiatives**: Backport "Show signatures in answered initiatives" to v0.26 [\#8991](https://github.com/decidim/decidim/pull/8991)
- **decidim-core**: Backport "Add missing reveal__title classes" to v0.26 [\#8999](https://github.com/decidim/decidim/pull/8999)
- **decidim-core**: Backport "Remove the label from the dropdown menu opener" to v0.26 [\#9002](https://github.com/decidim/decidim/pull/9002)
- **decidim-core**: Backport "Fix mobile nav keyboard focus" to v0.26 [\#9001](https://github.com/decidim/decidim/pull/9001)
- **decidim-core**: Backport "Fix main navigation aria-current attribute" to v0.26 [\#9000](https://github.com/decidim/decidim/pull/9000)
- **decidim-core**: Backport "Show character counter when replying to message" to v0.26 [\#9003](https://github.com/decidim/decidim/pull/9003)
- **decidim-core**: Backport "Fix character counter with emoji picker close to maximum characters" to v0.26 [\#9012](https://github.com/decidim/decidim/pull/9012)
- **decidim-api**, **decidim-assemblies**, **decidim-conferences**, **decidim-consultations**, **decidim-initiatives**, **decidim-meetings**, **decidim-participatory processes**, **decidim-proposals**: Backport "Fix API when meetings have proposal linking disabled" to v0.26 [\#8992](https://github.com/decidim/decidim/pull/8992)
- **decidim-core**: Backport "Fix Devise flash messages translation" to v0.26 [\#9043](https://github.com/decidim/decidim/pull/9043)
- **decidim-core**: Backport "Disable new conversation next button when no users selected" to v0.26 [\#9054](https://github.com/decidim/decidim/pull/9054)
- **decidim-initiatives**: Backport "Fix initiatives signatures issues" to v0.26 [\#8974](https://github.com/decidim/decidim/pull/8974)
- **decidim-blogs**, **decidim-core**, **decidim-debates**, **decidim-proposals**: Backport "Fix for endorsed_by with other user group's member" to v0.26 [\#9062](https://github.com/decidim/decidim/pull/9062)
- **decidim-proposals**: Backport "Fix footer actions caching on proposals' card" to v0.26 [\#9063](https://github.com/decidim/decidim/pull/9063)
- **decidim-admin**: Backport "Add missing 'Locale' string in i18n in selective newsletter" to v0.26 [\#9064](https://github.com/decidim/decidim/pull/9064)
- **decidim-core**: Backport "Fix social share button sharing" to v0.26 [\#9065](https://github.com/decidim/decidim/pull/9065)
- **decidim-meetings**: Backport "Use published meetings scope on processes landing and proposal's form" to v0.26 [\#9066](https://github.com/decidim/decidim/pull/9066)
- **decidim-core**: Backport "Require omniauth/rails_csrf_protection explicitly" to v0.26 [\#9067](https://github.com/decidim/decidim/pull/9067)
- **decidim-core**, **decidim-proposals**: Backport "Fix amendable events title" to v0.26 [\#9079](https://github.com/decidim/decidim/pull/9079)
- **decidim-proposals**: Backport "Create admin log records when proposals are imported from a file" to v0.26 [\#9077](https://github.com/decidim/decidim/pull/9077)
- **decidim-comments**, **decidim-core**, **decidim-proposals**: Backport "Add noreferrer and ugc to links" to v0.26 [\#9078](https://github.com/decidim/decidim/pull/9078)
- **decidim-meetings**: Backport "Fix submit in meetings admin form" to v0.26 [\#9076](https://github.com/decidim/decidim/pull/9076)
- **decidim-core**: Backport "Fix session cookie SameSite policy" to v0.26 [\#9059](https://github.com/decidim/decidim/pull/9059)
- **decidim-budgets**, **decidim-core**, **decidim-debates**, **decidim-meetings**, **decidim-proposals**: Backport "Fix cache URLs on cards" to v0.26 [\#9074](https://github.com/decidim/decidim/pull/9074)
- **decidim-assemblies**, **decidim-conferences**, **decidim-consultations**, **decidim-core**, **decidim-initiatives**, **decidim-participatory processes**: Backport "Fix Twitter hashtag search when it starts with a number" to v0.26 [\#9075](https://github.com/decidim/decidim/pull/9075)

### Removed

Nothing.

### Internal

- Backport "Fix ActionMailer preview loading" to v0.26 [\#8963](https://github.com/decidim/decidim/pull/8963)
- Backport "Fix flaky spec in meetings multi-date selectors" to v0.26 [\#8976](https://github.com/decidim/decidim/pull/8976)
- Backport "Local HTML validator for the CI" to v0.26 [\#9004](https://github.com/decidim/decidim/pull/9004)
- Backport "Fix API when meetings have proposal linking disabled" to v0.26 [\#8992](https://github.com/decidim/decidim/pull/8992)

### Developer improvements

- Backport "Fix Devise configs that depend on Decidim configs" to v0.26 [\#9022](https://github.com/decidim/decidim/pull/9022)
- Backport "Fix Faker address country code in seeds" to v0.26 [\#9046](https://github.com/decidim/decidim/pull/9046)

## [0.26.0](https://github.com/decidim/decidim/tree/v0.26.0)

### Added

Nothing.

### Changed

- **decidim-comments**: Backport "Show hidden comments replies" to v0.26 [\#8868](https://github.com/decidim/decidim/pull/8868)

### Fixed

- **decidim-proposals**: Backport "Fix geocoding NaN values" to v0.26 [\#8778](https://github.com/decidim/decidim/pull/8778)
- **decidim-core**: Backport "Add 'nofollow noopener' rel to the profile personal URL" to v0.26 [\#8780](https://github.com/decidim/decidim/pull/8780)
- **decidim-generators**: Backport "Add .keep file to empty directory to include on git committing" to v0.26 [\#8788](https://github.com/decidim/decidim/pull/8788)
- **decidim-core**: Backport "Fix avatar upload validation errors are displayed twice" to v0.26 [\#8798](https://github.com/decidim/decidim/pull/8798)
- **decidim-meetings**: Backport "Fix displaying hidden meetings in homepage's 'upcoming meetings' content block" to v0.26 [\#8819](https://github.com/decidim/decidim/pull/8819)
- **decidim-participatory processes**: Backport "Fix characters not encoded in highlighted participatory processes groups title" to v0.26 [\#8824](https://github.com/decidim/decidim/pull/8824)
- **decidim-comments**: Backport "Fix displaying hidden related resources" to v0.26 [\#8835](https://github.com/decidim/decidim/pull/8835)
- **decidim-generators**: Backport "Add natively a .keep file to empty directory to include on git committing" to v0.26 [\#8836](https://github.com/decidim/decidim/pull/8836)
- **decidim-consultations**, **decidim-core**, **decidim-elections**: Backport "Fix report moderation for all the spaces" to v0.26 [\#8841](https://github.com/decidim/decidim/pull/8841)
- **decidim-meetings**, **decidim-participatory processes**: Backport "Fix displaying hidden meetings in show process page" to v0.26 [\#8843](https://github.com/decidim/decidim/pull/8843)
- **decidim-meetings**: Backport "Fix displaying hidden resources in global search" to v0.26  [\#8850](https://github.com/decidim/decidim/pull/8850)
- **decidim-core**: Backport "Fix activity cell disappearing author images" to v0.26 [\#8848](https://github.com/decidim/decidim/pull/8848)
- **decidim-initiatives**: Backport "Fix scope validation on initiative's creation" to v0.26 [\#8857](https://github.com/decidim/decidim/pull/8857)
- **decidim-accountability**: Backport "Fix accountability categories' colors" to v0.26 [\#8858](https://github.com/decidim/decidim/pull/8858)
- **decidim-debates**: Backport "Remove actions from debates' cards" to v0.26 [\#8861](https://github.com/decidim/decidim/pull/8861)
- **decidim-assemblies**: Backport "Fix assemblies title when there are unpublished children" to v0.26 [\#8860](https://github.com/decidim/decidim/pull/8860)
- **decidim-core**: Backport "Fix cache_hash generation in AuthorCell" to v0.26 [\#8862](https://github.com/decidim/decidim/pull/8862)
- **decidim-meetings**, **decidim-participatory processes**: Backport "Fix displaying hidden meetings in processes group's 'upcoming meetings' content block" to v0.26 [\#8864](https://github.com/decidim/decidim/pull/8864)
- **decidim-assemblies**, **decidim-conferences**, **decidim-consultations**, **decidim-proposals**: Backport "Fix notifications when there is a note proposal in other spaces than processes" to v0.26 [\#8865](https://github.com/decidim/decidim/pull/8865)
- **decidim-proposals**: Backport "Fix answered proposals display" to v0.26 [\#8863](https://github.com/decidim/decidim/pull/8863)
- **decidim-comments**: Backport "Show hidden comments replies" to v0.26 [\#8868](https://github.com/decidim/decidim/pull/8868)
- **decidim-meetings**: Backport "Fix meetings iframe embed code" to v0.26 [\#8884](https://github.com/decidim/decidim/pull/8884)

### Removed

Nothing.

### Internal

- Backport "Fix flaky test in UpdateAssemblyMember" to v0.26 [\#8803](https://github.com/decidim/decidim/pull/8803)

### Developer improvements

Nothing.

## [0.26.0.rc2](https://github.com/decidim/decidim/tree/v0.26.0.rc2)

### Added

Nothing.
#### Moderated content can now be removed from search index
PR [\#8811](https://github.com/decidim/decidim/pull/8811) is addressing an issue when the moderated resources are not removed from the general search index.

This will automatically work for new moderated resources. For already existing ones, we have introduced a new task that will remove the moderated content from being displayed in search:

```ruby
bin/rails decidim:upgrade:moderation:remove_from_search
```

#### Default Decidim app fully configurable via ENV vars

### Changed

Nothing.

### Fixed

- **decidim-meetings**: Backport "Fix for preview unpublished meetings by admin user" to v0.26 [\#8724](https://github.com/decidim/decidim/pull/8724)
- **decidim-comments**: Backport "Adds emojis when user edits a comment" to v0.26 [\#8743](https://github.com/decidim/decidim/pull/8743)
- **decidim-core**: Backport "Properly mark sender and recipient in Conversation" to v0.26 [\#8746](https://github.com/decidim/decidim/pull/8746)
- **decidim-participatory processes**: Backport "Fix order by weight in processes groups' processes content block" to v0.26 [\#8771](https://github.com/decidim/decidim/pull/8771)
- **decidim-core**: Backport "Don't display blocked users in mentions" to v0.26 [\#8770](https://github.com/decidim/decidim/pull/8770)

### Removed

Nothing.

### Internal

- Backport "Revert the i18n-tasks initialization syntax" to v0.26 [\#8696](https://github.com/decidim/decidim/pull/8696)
- Backport "Lock graphql version to 1.12 minor" to v0.26 [\#8695](https://github.com/decidim/decidim/pull/8695)
- Disable codeclimate's stylelint [\#8711](https://github.com/decidim/decidim/pull/8711)

### Developer improvements

- Backport "Fix webpacker generator for modules" to v0.26 [\#8750](https://github.com/decidim/decidim/pull/8750)

## [0.26.0.rc1](https://github.com/decidim/decidim/tree/v0.26.0.rc1)

### Migration notes
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

#### Fix statistics in Comments

As per [#8012](https://github.com/decidim/decidim/pull/8012), for fixing statistic in comments. There's a rake task that you need to run:

```ruby
rake decidim_comments:update_participatory_process_in_comments
```

#### Base64 images migration

As per [\#8250](https://github.com/decidim/decidim/pull/8250), we've replaced the default base64 editor images attachment with the use of ActiveStorage attachments. This PR also adds a task to parse all editor contents and replace existing base64 images with attachments. The task parses all the attributes which can be edited from admin using the WYSIWYG editor. The task requires an argument with the email of an admin used to create EditorImage instances. To run this task execute:

```
rails decidim:active_storage_migrations:migrate_inline_images_to_active_storage[admin_email]
```

### Added

- **decidim-budgets**: Port decidim-budgets improvements from AjuntamentdeBarcelona/decidim [\#8249](https://github.com/decidim/decidim/pull/8249)
- **decidim-elections**: Improve evote admin logs [\#8263](https://github.com/decidim/decidim/pull/8263)
- **decidim-blogs**, **decidim-meetings**: Add card images to meetings and blog posts [\#8276](https://github.com/decidim/decidim/pull/8276)
- **decidim-admin**: Align UI groups filtering with the rest of decidim  [\#8105](https://github.com/decidim/decidim/pull/8105)
- **decidim-admin**, **decidim-proposals**: Improve error messages in admin panel [\#8193](https://github.com/decidim/decidim/pull/8193)
- **decidim-elections**: Allow to mark trustees as missing [\#8314](https://github.com/decidim/decidim/pull/8314)
- **decidim-admin**: Add sorting to private participants in a participatory space [\#8242](https://github.com/decidim/decidim/pull/8242)
- **decidim-comments**: Improve control of comments in meetings and debates [\#8027](https://github.com/decidim/decidim/pull/8027)
- **decidim-proposals**: Offer a way to see all proposals in withdrawn proposal list [\#8251](https://github.com/decidim/decidim/pull/8251)
- **decidim-admin**, **decidim-proposals**: Configurable default order for proposals [\#8295](https://github.com/decidim/decidim/pull/8295)
- **decidim-assemblies**: Filter assemblies by assembly type in admin [\#7153](https://github.com/decidim/decidim/pull/7153)
- **decidim-assemblies**: Non participant assembly members avatar [\#8277](https://github.com/decidim/decidim/pull/8277)
- **decidim-core**: Add image file upload in QuillJS editor [\#8250](https://github.com/decidim/decidim/pull/8250)
- **decidim-meetings**: Make meeting report editable by the author in front-end [\#8209](https://github.com/decidim/decidim/pull/8209)
- **decidim-core**: Improve dialog accessibility [\#8294](https://github.com/decidim/decidim/pull/8294)
- **decidim-meetings**: Ability for users to withdraw their meetings [\#8248](https://github.com/decidim/decidim/pull/8248)
- **decidim-admin**: Add colors accessibility warning in admin Appearance [\#8354](https://github.com/decidim/decidim/pull/8354)
- **decidim-proposals**: Import proposal answers [\#8271](https://github.com/decidim/decidim/pull/8271)
- **decidim-core**: Add more actions in QuillJS toolbar [\#8120](https://github.com/decidim/decidim/pull/8120)
- **decidim-meetings**: Add more filter options to directory meetings page [\#8333](https://github.com/decidim/decidim/pull/8333)
- **decidim-assemblies**, **decidim-conferences**, **decidim-participatory processes**: Add filters for Participatory process admins section [\#8106](https://github.com/decidim/decidim/pull/8106)
- **decidim-budgets**: Show modal when user is trying to leave with pending vote [\#8387](https://github.com/decidim/decidim/pull/8387)
- **decidim-meetings**: Meetings iframe visibility [\#8307](https://github.com/decidim/decidim/pull/8307)
- **decidim-budgets**: Add search, filters and sorting to admin panel budget projects [\#8592](https://github.com/decidim/decidim/pull/8592)
- **decidim-core**: Describe the notifications' time with words [\#8564](https://github.com/decidim/decidim/pull/8564)
- **decidim-comments**, **decidim-core**: Add link to comments in Notifications [\#8607](https://github.com/decidim/decidim/pull/8607)
- **decidim-comments**, **decidim-core**: Add full content of comments in notifications [\#8581](https://github.com/decidim/decidim/pull/8581)
- **decidim-core**: Change colors on mobile navigation bar [\#8628](https://github.com/decidim/decidim/pull/8628)
- **decidim-core**, **decidim-proposals**: Add author to proposals in notifications [\#8603](https://github.com/decidim/decidim/pull/8603)
- **decidim-comments**, **decidim-core**, **decidim-meetings**, **decidim-proposals**: Allow participants to receive translated content by email [\#8174](https://github.com/decidim/decidim/pull/8174)
- **decidim-admin**: Add search, filters, pagination and sorting to moderated users [\#8620](https://github.com/decidim/decidim/pull/8620)
- **decidim-surveys**: Add "title and description" in surveys [\#8588](https://github.com/decidim/decidim/pull/8588)

### Changed

- **decidim-elections**: Validate census CSV headers [\#8264](https://github.com/decidim/decidim/pull/8264)
- **decidim-meetings**: Improve Attendees count error handling on frontend [\#8238](https://github.com/decidim/decidim/pull/8238)
- **decidim-core**: Disable unconfirmed access by default [\#8233](https://github.com/decidim/decidim/pull/8233)
- **decidim-meetings**: Rename 'upcoming events' content block to 'upcoming meetings' [\#8412](https://github.com/decidim/decidim/pull/8412)
- **decidim-core**: Change user workflows to prevent user enumeration attacks [\#8537](https://github.com/decidim/decidim/pull/8537)

### Fixed

- **decidim-accountability**: Fix accountability notifications proposal title [\#8240](https://github.com/decidim/decidim/pull/8240)
- **decidim-elections**: Remove white spaces in Census [\#8262](https://github.com/decidim/decidim/pull/8262)
- **decidim-debates**, **decidim-meetings**, **decidim-proposals**: Fix characters not encoded in title [\#8253](https://github.com/decidim/decidim/pull/8253)
- **decidim-proposals**: Fix flaky test on proposals splitting [\#8302](https://github.com/decidim/decidim/pull/8302)
- **decidim-core**: Fix invalid i18n values for diff changeset [\#8299](https://github.com/decidim/decidim/pull/8299)
- **decidim-meetings**: Fix live? missing method delegation in online_meeting cell [\#8241](https://github.com/decidim/decidim/pull/8241)
- **decidim-comments**: Fix statistics in Comments [\#8012](https://github.com/decidim/decidim/pull/8012)
- **decidim-budgets**: Fix some explore budgets specs [\#8303](https://github.com/decidim/decidim/pull/8303)
- **decidim-core**: Fix missing icons after CORS [\#8290](https://github.com/decidim/decidim/pull/8290)
- **decidim-core**: Remove unnecessary spacer from external link indicator [\#8291](https://github.com/decidim/decidim/pull/8291)
- **decidim-core**: [CVE-2021-22942] Possible Open Redirect in Host Authorization Middleware [\#8265](https://github.com/decidim/decidim/pull/8265)
- **decidim-debates**: Fix "last comment by" when commenter is a user group [\#8279](https://github.com/decidim/decidim/pull/8279)
- **decidim-proposals**: Similar proposal functionality breaks when the machine translation is enabled.  [\#8098](https://github.com/decidim/decidim/pull/8098)
- **decidim-core**: Fix regex that parses users and groups references inside content. [\#8297](https://github.com/decidim/decidim/pull/8297)
- **decidim-assemblies**: Fix birthday attribute type in Assembly Members [\#8311](https://github.com/decidim/decidim/pull/8311)
- **decidim-comments**: Fix issues with dynamic comments polling [\#8317](https://github.com/decidim/decidim/pull/8317)
- **decidim-assemblies**: Fix "Edit" and "View public page" in Assembly Members [\#8312](https://github.com/decidim/decidim/pull/8312)
- **decidim-comments**: Fix "View all comments" link in single comment page [\#8308](https://github.com/decidim/decidim/pull/8308)
- **decidim-budgets**: Fix dont allow budget exceeding in project view [\#8261](https://github.com/decidim/decidim/pull/8261)
- **decidim-debates**: Fix title meta tag for debates [\#8323](https://github.com/decidim/decidim/pull/8323)
- **decidim-proposals**: Fix UserAnswersSerializer for CSV exports [\#8329](https://github.com/decidim/decidim/pull/8329)
- **decidim-admin**: Do not block registered users with InviteUserAgain [\#8268](https://github.com/decidim/decidim/pull/8268)
- **decidim-conferences**: Fix error when accessing the meetings of a conference with speakers related  [\#8369](https://github.com/decidim/decidim/pull/8369)
- **decidim-conferences**: Fix details on conference speakers: affiliation order, personal URL link, seeds and more info link  [\#8378](https://github.com/decidim/decidim/pull/8378)
- **decidim-meetings**: Define localized fields in Decidim::Meetings:DiffRenderer [\#8381](https://github.com/decidim/decidim/pull/8381)
- **decidim-core**: Include only public entities in the following page [\#8361](https://github.com/decidim/decidim/pull/8361)
- **decidim-proposals**: Any user can access proposal's pages representing the "create a proposal" steps [\#8390](https://github.com/decidim/decidim/pull/8390)
- **decidim-core**: Fix localized faker with single locale [\#8394](https://github.com/decidim/decidim/pull/8394)
- **decidim-core**: Fix user activity page error message with missing username [\#8403](https://github.com/decidim/decidim/pull/8403)
- **decidim-core**: Fix conversation with deleted account [\#8409](https://github.com/decidim/decidim/pull/8409)
- **decidim-core**: Fix javascript exception when geocoding proposals is disabled [\#8413](https://github.com/decidim/decidim/pull/8413)
- **decidim-blogs**: Add missing translations [\#8426](https://github.com/decidim/decidim/pull/8426)
- **decidim-comments**: Refresh comments component after updating [\#8362](https://github.com/decidim/decidim/pull/8362)
- **decidim-core**: Fix webpacker issue when using zeitwerk [\#8444](https://github.com/decidim/decidim/pull/8444)
- **decidim-core**: Improve Zeitwerk assets paths to ignore [\#8449](https://github.com/decidim/decidim/pull/8449)
- **decidim-surveys**: Fix notification after creating survey [\#8463](https://github.com/decidim/decidim/pull/8463)
- **decidim-budgets**, **decidim-comments**: Fix comment's get link in project view [\#8450](https://github.com/decidim/decidim/pull/8450)
- **decidim-elections**: Fix report missing trustee admin log entry [\#8468](https://github.com/decidim/decidim/pull/8468)
- **decidim-system**: Add `pptx` in allowed_file_extensions (of admin) [\#8502](https://github.com/decidim/decidim/pull/8502)
- **decidim-core**: Fix 404 link in 'how to participate' home content block [\#8513](https://github.com/decidim/decidim/pull/8513)
- **decidim-meetings**: Fix meetings with multiple dates [\#8497](https://github.com/decidim/decidim/pull/8497)
- **decidim-core**: Fix pt-BR issue [\#8523](https://github.com/decidim/decidim/pull/8523)
- **decidim-generators**: Freezing webpacker to RC.5 until RC.7 is fixed [\#8531](https://github.com/decidim/decidim/pull/8531)
- **decidim-conferences**: Fix conference speakers when there isn't any avatar [\#8520](https://github.com/decidim/decidim/pull/8520)
- **decidim-assemblies**, **decidim-participatory processes**: Fix the copy of components weights in participatory processes and assemblies [\#8498](https://github.com/decidim/decidim/pull/8498)
- **decidim-meetings**: Fix meetings input when rich text editor is disabled [\#8534](https://github.com/decidim/decidim/pull/8534)
- **decidim-meetings**: Fix showing created meetings in 'my public profile' [\#8519](https://github.com/decidim/decidim/pull/8519)
- **decidim-meetings**, **decidim-proposals**: Fix various proposal picker issues when there are thousands of proposals [\#8558](https://github.com/decidim/decidim/pull/8558)
- **decidim-core**: Remove border on all the fieldsets [\#8561](https://github.com/decidim/decidim/pull/8561)
- **decidim-initiatives**: Remove wrong </div> in initiatives header [\#8563](https://github.com/decidim/decidim/pull/8563)
- **decidim-core**: Fix CSS layout wrapper top padding [\#8562](https://github.com/decidim/decidim/pull/8562)
- **decidim-forms**, **decidim-surveys**: Fix duplicated answers in surveys [\#8560](https://github.com/decidim/decidim/pull/8560)
- **decidim-meetings**: Fix the meeting copy functionality [\#8430](https://github.com/decidim/decidim/pull/8430)
- **decidim-core**: Move social login buttons to the top of the login modal [\#8574](https://github.com/decidim/decidim/pull/8574)
- **decidim-comments**, **decidim-meetings**: Fix HTML injection in comments and meeting's description [\#8511](https://github.com/decidim/decidim/pull/8511)
- **decidim-core**: Fix avatar thumbnail in participants' profile [\#8577](https://github.com/decidim/decidim/pull/8577)
- **decidim-core**: Rename index to avoid conflicts with decidim_awesome module migrations [\#8613](https://github.com/decidim/decidim/pull/8613)
- **decidim-core**: Fix group mentions in notifications [\#8598](https://github.com/decidim/decidim/pull/8598)
- **decidim-forms**, **decidim-surveys**: Fix surveys exports with free text in multiple option [\#8582](https://github.com/decidim/decidim/pull/8582)
- **decidim-core**: Fix reply to a conversation with deleted participants [\#8635](https://github.com/decidim/decidim/pull/8635)
- **decidim-admin**, **decidim-debates**, **decidim-proposals**: Fix consistency in creation actions phrasing: "Participants can create XXX" [\#8650](https://github.com/decidim/decidim/pull/8650)
- **decidim-core**: Fix wrong display of deleted accounts in conversations [\#8641](https://github.com/decidim/decidim/pull/8641)
- **decidim-core**: Fix cache key on ActivityCell [\#8654](https://github.com/decidim/decidim/pull/8654)
- **decidim-participatory processes**: Fix participatory groups leaks on other organizations/tenants [\#8651](https://github.com/decidim/decidim/pull/8651)
- **decidim-core**: Fix blocked users appear in search [\#8658](https://github.com/decidim/decidim/pull/8658)
- **decidim-meetings**: Don't start poll meetings component when DOM elements are not present [\#8676](https://github.com/decidim/decidim/pull/8676)
- **decidim-initiatives**, **decidim-proposals**: Fix initiative attachments [\#7452](https://github.com/decidim/decidim/pull/7452)
- **decidim-assemblies**: Fix performance issues on assemblies page when having many private users [\#8509](https://github.com/decidim/decidim/pull/8509)
- **decidim-proposals**: Add location data to proposals export and import [\#8679](https://github.com/decidim/decidim/pull/8679)
- **decidim-meetings**: Fix meetings form embed type visibility [\#8602](https://github.com/decidim/decidim/pull/8602)
- **decidim-meetings**: Do not send upcoming meeting events notification for past events [\#8665](https://github.com/decidim/decidim/pull/8665)

### Removed

- **decidim-proposals**: Remove "Allow card image" setting from Proposals [\#8281](https://github.com/decidim/decidim/pull/8281)
- **decidim-assemblies**: Remove designation_mode field from Assembly Members [\#8310](https://github.com/decidim/decidim/pull/8310)
- **decidim-participatory processes**: Remove admin show page in Participatory Process Groups [\#8313](https://github.com/decidim/decidim/pull/8313)

### Developer improvements

- Fix Luxembourgish locale [\#8270](https://github.com/decidim/decidim/pull/8270)
- Fix ARIA roles for dialogs and tooltips [\#8293](https://github.com/decidim/decidim/pull/8293)
- Add selectors on edit_form_fields [\#8353](https://github.com/decidim/decidim/pull/8353)
- Fix HTTPOnly and secure flag on the cookie acceptance cookie [\#8358](https://github.com/decidim/decidim/pull/8358)
- Add Brakeman to GitHub Actions for improving security [\#6832](https://github.com/decidim/decidim/pull/6832)
- Disallow redirection to the host when performing redirect_back [\#8296](https://github.com/decidim/decidim/pull/8296)
- Improve performance on the serializers by using includes, query counter [\#8278](https://github.com/decidim/decidim/pull/8278)
- Enforce redirects to include the organization host [\#8385](https://github.com/decidim/decidim/pull/8385)
- Fix issues with the session/environment security configs [\#8360](https://github.com/decidim/decidim/pull/8360)
- Improve extendability on some controllers [\#8398](https://github.com/decidim/decidim/pull/8398)
- Add avatar eager logging to UserEntityFinder #8416 [\#8417](https://github.com/decidim/decidim/pull/8417)
- Increase text contrast in current phase of a participatory process [\#8422](https://github.com/decidim/decidim/pull/8422)
- Fix CVE-2021-41136 (HTTP Request Smuggling in puma) [\#8431](https://github.com/decidim/decidim/pull/8431)
- Remove anchored dependency [\#8453](https://github.com/decidim/decidim/pull/8453)
- Fix pt-BR issue [\#8523](https://github.com/decidim/decidim/pull/8523)
- Add rendered view instrumentation information [\#8530](https://github.com/decidim/decidim/pull/8530)
- Optimize open data exporter for large amount of data [\#8503](https://github.com/decidim/decidim/pull/8503)
- Add cache key separator to cache_hash [\#8559](https://github.com/decidim/decidim/pull/8559)
- Improve generation of the opendata export [\#8593](https://github.com/decidim/decidim/pull/8593)
- Add several cache keys to cells [\#8566](https://github.com/decidim/decidim/pull/8566)
- Update password strength check [\#8455](https://github.com/decidim/decidim/pull/8455)
- Remove etherpad-lite dependency [\#8541](https://github.com/decidim/decidim/pull/8541)
- Fix Rack::Attack initializer custom parameter configuration [\#8643](https://github.com/decidim/decidim/pull/8643)

### Internal

- Fix dependencies locks after 0.26.0.dev bump [\#8247](https://github.com/decidim/decidim/pull/8247)
- Add modules recommendations in documentation [\#8218](https://github.com/decidim/decidim/pull/8218)
- Fix webpacker dependency lock [\#8272](https://github.com/decidim/decidim/pull/8272)
- Improve README with examples [\#8244](https://github.com/decidim/decidim/pull/8244)
- Update foundation-sites to 6.7.0 for better Dart Sass compatibility [\#8273](https://github.com/decidim/decidim/pull/8273)
- Fix NPM packages versioning during release process [\#8280](https://github.com/decidim/decidim/pull/8280)
- Add 'Lint PR title' workflow to CI [\#8285](https://github.com/decidim/decidim/pull/8285)
- Don't trigger PR linting on pushes, only on PRs [\#8304](https://github.com/decidim/decidim/pull/8304)
- Prevent root package.json to be treated as a package [\#8315](https://github.com/decidim/decidim/pull/8315)
- Fix CSS validation tests caused by a bug on the validation service [\#8322](https://github.com/decidim/decidim/pull/8322)
- **decidim-core**: Remove npm decidim packages with dependencies from other decidim packages [\#8330](https://github.com/decidim/decidim/pull/8330)
- **decidim-core**: Fix problems introduced by #8330 [\#8341](https://github.com/decidim/decidim/pull/8341)
- Update Node and NPM version [\#8343](https://github.com/decidim/decidim/pull/8343)
- Remove hack for CSS validation [\#8326](https://github.com/decidim/decidim/pull/8326)
- Update docs in migrating to webpacker [\#8349](https://github.com/decidim/decidim/pull/8349)
- **decidim-comments**: Ignore errors during comments migration task [\#8351](https://github.com/decidim/decidim/pull/8351)
- **decidim-meetings**: Fix published and title in seeded meetings [\#8359](https://github.com/decidim/decidim/pull/8359)
- **decidim-core**: Fix SQL to make version display faster [\#8393](https://github.com/decidim/decidim/pull/8393)
- Remove GraphQL deprecated API call [\#8432](https://github.com/decidim/decidim/pull/8432)
- **decidim-generators**: Fixing generator webpacker issues [\#8427](https://github.com/decidim/decidim/pull/8427)
- **decidim-generators**: Fix railties requirements on created applications [\#8415](https://github.com/decidim/decidim/pull/8415)
- **decidim-core**: Update omniauth gem and dependencies [\#8388](https://github.com/decidim/decidim/pull/8388)
- Document how to enable machine translations on organization [\#8458](https://github.com/decidim/decidim/pull/8458)
- **decidim-dev**: Improves manual installation documentation [\#8508](https://github.com/decidim/decidim/pull/8508)
- Update the i18n-tasks initialization syntax [\#8544](https://github.com/decidim/decidim/pull/8544)
- Documentation: improve develop section  [\#8553](https://github.com/decidim/decidim/pull/8553)
- Change default window size in Capybara configuration [\#8576](https://github.com/decidim/decidim/pull/8576)
- Fix security instructions [\#8587](https://github.com/decidim/decidim/pull/8587)
- Temporarily ignore CSS validation issue in CI [\#8597](https://github.com/decidim/decidim/pull/8597)
- Update nokogiri to 1.12.5 [\#8609](https://github.com/decidim/decidim/pull/8609)
- Update paper_trail to 12.1 [\#8608](https://github.com/decidim/decidim/pull/8608)
- Update ruby to 2.7.5 [\#8629](https://github.com/decidim/decidim/pull/8629)
- Remove truncato dependency [\#8507](https://github.com/decidim/decidim/pull/8507)
- Change figaro to rbenv-vars in "manual installation" documentation [\#8575](https://github.com/decidim/decidim/pull/8575)
- Add instructions PostgreSQL configuration in development app [\#8618](https://github.com/decidim/decidim/pull/8618)
- Fix etherpad doc reference in initializer [\#8632](https://github.com/decidim/decidim/pull/8632)
- Clarifies git branches conventions in doc [\#8644](https://github.com/decidim/decidim/pull/8644)
- Fix changelog link [\#8671](https://github.com/decidim/decidim/pull/8671)
- Enable simplecov only for rspec step [\#8674](https://github.com/decidim/decidim/pull/8674)
- **decidim-dev**: Improve machine translation documentation and comments [\#8668](https://github.com/decidim/decidim/pull/8668)
- Split the workflows files for CI [\#8675](https://github.com/decidim/decidim/pull/8675)
- DRY GitHub workflows with composite actions [\#8677](https://github.com/decidim/decidim/pull/8677)
- Change Gitter to Matrix.org in documentation [\#8466](https://github.com/decidim/decidim/pull/8466)

## Previous versions

Please check [release/0.25-stable](https://github.com/decidim/decidim/blob/release/0.25-stable/CHANGELOG.md) for previous changes.
