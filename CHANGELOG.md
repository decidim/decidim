# Change Log

## Unreleased

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

## [0.27.4](https://github.com/decidim/decidim/tree/0.27.4)

## Security fixes

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

#### Initiatives pages exception fix

We have added a new tasks to fix a bug related to the pages component inside of the Initiatives module (`decidim-initiatives`).

You can run the task with the following command:

```console
bundle exec rake decidim:initiatives:upgrade:fix_broken_pages
```

You can see more details about this change on PR [\#10928](https://github.com/decidim/decidim/pull/10928)

### Added

Nothing.

### Changed

Nothing.

### Fixed

- Backport 'Remove unused preset-env dependencies' to v0.27 [\#11005](https://github.com/decidim/decidim/pull/11005)
- **decidim-verifications**: Backport 'Fix missing translations for SMS confirmation when signing a petition' to v0.27 [\#11011](https://github.com/decidim/decidim/pull/11011)
- **decidim-initiatives**: Backport 'Fix for initiative menu not active on creation' to v0.27 [\#11019](https://github.com/decidim/decidim/pull/11019)
- **decidim-initiatives**: Backport 'Change to display initiatives after creation' to v0.27 [\#11029](https://github.com/decidim/decidim/pull/11029)
- **decidim-elections**: Backport 'Allow to publish an Election even if it hasn't valid Questions' to v0.27 [\#11031](https://github.com/decidim/decidim/pull/11031)
- **decidim-core**: Backport 'Fix to Proposal cards CSS in Processes' to v0.27 [\#11021](https://github.com/decidim/decidim/pull/11021)
- **decidim-core**: Backport 'Add translation string for URL error message' to v0.27 [\#11013](https://github.com/decidim/decidim/pull/11013)
- **decidim-blogs**: Backport 'Add possibility of reporting blog posts ' to v0.27 [\#11025](https://github.com/decidim/decidim/pull/11025)
- **decidim-core**, **decidim-debates**, **decidim-initiatives**, **decidim-proposals**, **decidim-sortitions**: Backport 'Fix user and group related migrations calling the actual record classes' to v0.27 [\#11009](https://github.com/decidim/decidim/pull/11009)
- **decidim-budgets**: Backport 'Fix budgets zero single view' to v0.27 [\#11015](https://github.com/decidim/decidim/pull/11015)
- **decidim-conferences**: Backport 'Fix partner type in Conferences' partners edit form' to v0.27 [\#11017](https://github.com/decidim/decidim/pull/11017)
- **decidim-core**: Backport 'Fix do not count blocked users to stats' to v0.27 [\#11027](https://github.com/decidim/decidim/pull/11027)
- **decidim-core**: Backport 'Fix error when SVG icon is not available in the file system' to v0.27 [\#11007](https://github.com/decidim/decidim/pull/11007)
- **decidim-elections**: Backport 'Fix error message mismatch in election' to v0.27 [\#11033](https://github.com/decidim/decidim/pull/11033)
- **decidim-core**: Backport 'Fix notifications page when vapid is not available' to v0.27 [\#10940](https://github.com/decidim/decidim/pull/10940)
- **decidim-initiatives**: Backport 'Fix exception in Initiatives' Page' to v0.27 [\#11023](https://github.com/decidim/decidim/pull/11023)
- **decidim-admin**: Backport 'Don't allow access to admin panel without ToS acceptance' to v0.27 [\#11042](https://github.com/decidim/decidim/pull/11042)
- **decidim-core**: Backport 'Fix "No activity" message in Last Activities isn't shown sometimes' to v0.27 [\#11056](https://github.com/decidim/decidim/pull/11056)
- **decidim-budgets**: Backport 'Show all projects if none is selected when the voting has finished' to v0.27 [\#11118](https://github.com/decidim/decidim/pull/11118)
- **decidim-core**: Backport 'Fix for sending welcome emails for new participants' to v0.27 [\#11121](https://github.com/decidim/decidim/pull/11121)
- **decidim-elections**: Backport 'Fix Admin dashboard disappear if you are in Trustee Zone' to v0.27 [\#11114](https://github.com/decidim/decidim/pull/11114)
- **decidim-core**: Backport 'Avoid password change to be requested when user registration mode is disabled' to v0.27 [\#11120](https://github.com/decidim/decidim/pull/11120)
- **decidim-proposals**: Backport 'Fix flaky collaborative drafts spec' to v0.27 [\#11127](https://github.com/decidim/decidim/pull/11127)
- Backport 'Fix webpack version to <5.83.0' to v0.27 [\#11133](https://github.com/decidim/decidim/pull/11133)
- **decidim-participatory processes**: Backport 'Fix the active filter for process groups' to v0.27 [\#11130](https://github.com/decidim/decidim/pull/11130)
- **decidim-core**: Backport 'Verify modules are installed in StatsParticipantsCount query' to v0.27 [\#11157](https://github.com/decidim/decidim/pull/11157)
- **decidim-core**: Backport 'Fix issues with overriding maps and loading Leaflet' to v0.27 [\#11131](https://github.com/decidim/decidim/pull/11131)
- **decidim-elections**, **decidim-initiatives**: Backport 'CSV & JSON export function fix' to v0.27 [\#11185](https://github.com/decidim/decidim/pull/11185)
- **decidim-budgets**: Backport 'Fix the unused keyword arguments for the budgets workflows' to v0.27 [\#11228](https://github.com/decidim/decidim/pull/11228)
- **decidim-budgets**, **decidim-elections**: Backport 'Budgets component fix for Votings module' to v0.27 [\#11229](https://github.com/decidim/decidim/pull/11229)
- **decidim-elections**: Backport 'Fix for saving an Election that wasn't blocked' to v0.27 [\#11187](https://github.com/decidim/decidim/pull/11187)
- **decidim-admin**: Backport 'Fix blocked users not present in global moderation panel' to v0.27 [\#11234](https://github.com/decidim/decidim/pull/11234)
- **decidim-core**, **decidim-meetings**, **decidim-proposals**: Backport 'Always allow image upload in WYSWYG editor' to v0.27 [\#11237](https://github.com/decidim/decidim/pull/11237)
- **decidim-core**: Backport 'Fix linking to invariable image URLs' to v0.27 [\#11242](https://github.com/decidim/decidim/pull/11242)
- **decidim-core**, **decidim-surveys**: Backport 'Fix running DB commands consecutively' to v0.27 [\#11236](https://github.com/decidim/decidim/pull/11236)
- **decidim-forms**: Backport 'Fix memory leak with user answers serializer (at survey export)' to v0.27 [\#11241](https://github.com/decidim/decidim/pull/11241)
- **decidim-core**: Backport 'Fix admin password change required for omniauth-only accounts' to v0.27 [\#11240](https://github.com/decidim/decidim/pull/11240)
- **decidim-core**: Backport 'Prevent `aria-describedby` attribute being added to hidden inputs' to v0.27 [\#11243](https://github.com/decidim/decidim/pull/11243)
- **decidim-budgets**, **decidim-core**, **decidim-initiatives**, **decidim-proposals**, **decidim-sortitions**: Backport 'Fix scope and category filtering links with ransack' to v0.27 [\#11248](https://github.com/decidim/decidim/pull/11248)
- **decidim-admin**, **decidim-assemblies**, **decidim-blogs**, **decidim-conferences**, **decidim-core**, **decidim-elections**, **decidim-initiatives**, **decidim-participatory processes**, **decidim-templates**: Backport 'Enforce resources being found in the organization scope' to v0.27 [\#11232](https://github.com/decidim/decidim/pull/11232)
- **decidim-assemblies**, **decidim-conferences**, **decidim-participatory processes**, **decidim-proposals**: Backport 'Fix proposals' valuators assignments not deleted when space admin is removed' to v0.27 [\#11332](https://github.com/decidim/decidim/pull/11332)
- **decidim-admin**: Backport 'Fix HTML titles in admin panel' to v0.27 [\#11333](https://github.com/decidim/decidim/pull/11333)
- **decidim-admin**: Backport 'Fix HTML titles in admin panel (part 2)' to v0.27 [\#11336](https://github.com/decidim/decidim/pull/11336)

### Removed

Nothing.

### Developer improvements

- Backport "Update several gems" to v0.27 [\#11139](https://github.com/decidim/decidim/pull/11139)

### Internal

- **decidim-admin**, **decidim-core**: Backport 'Fix default seeds on first login (password_updated_at and accepted_tos_version)' to v0.27 [\#10854](https://github.com/decidim/decidim/pull/10854)
- **decidim-core**: Backport 'Remove duplication of LastActivity queries' to v0.27 [\#11055](https://github.com/decidim/decidim/pull/11055)
- **decidim-proposals**: Backport 'Fix flaky collaborative drafts spec' to v0.27 [\#11127](https://github.com/decidim/decidim/pull/11127)

## [0.27.3](https://github.com/decidim/decidim/tree/0.27.3)

## Security fixes

This release addresses several security issues, including the following:

* [CVE-2023-32693](https://github.com/decidim/decidim/security/advisories/GHSA-469h-mqg8-535r)
* [CVE-2023-34089](https://github.com/decidim/decidim/security/advisories/GHSA-5652-92r9-3fx9)
* [CVE-2023-34090](https://github.com/decidim/decidim/security/advisories/GHSA-jm79-9pm4-vrw9)

The details regarding the security vulnerability will be published on July 11th 2023, which is two months after the release date of this version. For more information, please refer to our [Security Policy](https://github.com/decidim/decidim/blob/develop/SECURITY.md).

We highly recommend updating to this version as soon as possible to ensure the security of your system.

### Added

Nothing.

### Changed

- **decidim-core**: Backport 'Improve the link handling' to v0.27 [\#10735](https://github.com/decidim/decidim/pull/10735)

### Fixed

- **decidim-core**: Backport 'Fix sass syntax errors' to v0.27 [\#10445](https://github.com/decidim/decidim/pull/10445)
- **decidim-participatory processes**: Backport 'Fix: Ransack returns results for multiple organizations' to v0.27 [\#10447](https://github.com/decidim/decidim/pull/10447)
- **decidim-forms**: Backport 'Fix survey conditional display' to v0.27 [\#10448](https://github.com/decidim/decidim/pull/10448)
- **decidim-core**: Backport 'Fix pipeline asset router bug regarding for manifests containing the host' to v0.27 [\#10449](https://github.com/decidim/decidim/pull/10449)
- **decidim-budgets**, **decidim-core**, **decidim-elections**, **decidim-proposals**: Backport 'Fix updating budget projects or other records containing attachments' to v0.27 [\#10451](https://github.com/decidim/decidim/pull/10451)
- **decidim-budgets**, **decidim-core**, **decidim-elections**, **decidim-proposals**: Backport 'Fix styling bug with the remove/close buttons for attachments' to v0.27 [\#10452](https://github.com/decidim/decidim/pull/10452)
- **decidim-admin**: Backport 'Fix deleting all content from help section triggers error' to v0.27 [\#10453](https://github.com/decidim/decidim/pull/10453)
- **decidim-admin**: Backport 'Fix deprecation warning in the `html5sortable` NPM package' to v0.27 [\#10455](https://github.com/decidim/decidim/pull/10455)
- **decidim-proposals**: Backport 'Fix participatory texts sections required field indicators' to v0.27 [\#10527](https://github.com/decidim/decidim/pull/10527)
- **decidim-initiatives**: Backport 'Remove email from initiative's print page' to v0.27 [\#10535](https://github.com/decidim/decidim/pull/10535)
- **decidim-core**, **decidim-participatory processes**: Backport 'Fix destroying scope types that have been associated with processes' to v0.27 [\#10530](https://github.com/decidim/decidim/pull/10530)
- **decidim-meetings**: Backport 'Fix meeting form for admin to update registrations_enabled field' to v0.27 [\#10531](https://github.com/decidim/decidim/pull/10531)
- **decidim-admin**, **decidim-core**, **decidim-system**: Backport 'Remove actions from admin and blocked users' to v0.27 [\#10536](https://github.com/decidim/decidim/pull/10536)
- **decidim-core**: Backport 'Make buttons respect the organizations' primary color' to v0.27 [\#10546](https://github.com/decidim/decidim/pull/10546)
- **decidim-proposals**: Backport 'Export proposal body without HTML tags' to v0.27 [\#10539](https://github.com/decidim/decidim/pull/10539)
- **decidim-proposals**: Backport 'Fix: Set required to proposal limit field in Proposal component' to v0.27 [\#10549](https://github.com/decidim/decidim/pull/10549)
- **decidim-core**: Backport 'Fix promoted admin password change right after registration' to v0.27 [\#10540](https://github.com/decidim/decidim/pull/10540)
- **decidim-admin**, **decidim-assemblies**, **decidim-conferences**, **decidim-core**, **decidim-elections**, **decidim-initiatives**, **decidim-participatory processes**, **decidim-proposals**, **decidim-system**: Backport 'Fix dynamic upload file field required indicator + make option naming consistent' to v0.27 [\#10541](https://github.com/decidim/decidim/pull/10541)
- **decidim-debates**, **decidim-meetings**, **decidim-proposals**: Backport 'Fix iframes stripped from admin entered proposals, meetings and debates' to v0.27 [\#10558](https://github.com/decidim/decidim/pull/10558)
- **decidim-forms**: FIx sorting question choice validations [\#10227](https://github.com/decidim/decidim/pull/10227)
- Fix missing documentation link [\#10621](https://github.com/decidim/decidim/pull/10621)
- **decidim-comments**: Backport 'Fix for exporting deleted and hidden comments' to v0.27 [\#10658](https://github.com/decidim/decidim/pull/10658)
- **decidim-proposals**: Backport 'Fix for exporting hidden moderated proposals' to v0.27 [\#10661](https://github.com/decidim/decidim/pull/10661)
- **decidim-proposals**: Backport 'Fix flaky collaborative drafts specs' to v0.27 [\#10667](https://github.com/decidim/decidim/pull/10667)
- **decidim-admin**: Backport 'Change I18n captions on moderation module' to v0.27 [\#10662](https://github.com/decidim/decidim/pull/10662)
- **decidim-proposals**: Backport 'Fix empty proposals component configuration limits' to v0.27 [\#10666](https://github.com/decidim/decidim/pull/10666)
- **decidim-admin**, **decidim-core**, **decidim-elections**, **decidim-meetings**: Backport 'Fix Redundant notifications when a component is (re)published' to v0.27 [\#10736](https://github.com/decidim/decidim/pull/10736)
- **decidim-core**, **decidim-debates**, **decidim-meetings**, **decidim-proposals**: Backport 'User role is defined for digest notifications to scope translations correctly' to v0.27 [\#10738](https://github.com/decidim/decidim/pull/10738)
- **decidim-initiatives**: Backport 'Fix initiatives display when not initialized' to v0.27 [\#10742](https://github.com/decidim/decidim/pull/10742)
- **decidim-admin**, **decidim-assemblies**, **decidim-blogs**, **decidim-budgets**, **decidim-conferences**, **decidim-consultations**, **decidim-core**, **decidim-elections**, **decidim-forms**, **decidim-initiatives**, **decidim-meetings**, **decidim-pages**, **decidim-proposals**, **decidim-sortitions**: Backport 'Fix editor toolbar' to v0.27 [\#10743](https://github.com/decidim/decidim/pull/10743)
- **decidim-participatory processes**: Backport 'Fix Empty participatory process group is created when importing a PP …' to v0.27 [\#10732](https://github.com/decidim/decidim/pull/10732)
- **decidim-assemblies**, **decidim-blogs**, **decidim-budgets**, **decidim-consultations**, **decidim-debates**, **decidim-elections**, **decidim-forms**, **decidim-pages**, **decidim-participatory processes**, **decidim-proposals**, **decidim-sortitions**: Backport 'Fix Video embeds are not shown in short_description field' to v0.27 [\#10745](https://github.com/decidim/decidim/pull/10745)
- **decidim-consultations**: Backport 'Add missing translations in consultations' to v0.27 [\#10790](https://github.com/decidim/decidim/pull/10790)
- **decidim-budgets**, **decidim-proposals**: Backport 'Supports no longer visible for linked proposals if supports are disabled' to v0.27 [\#10777](https://github.com/decidim/decidim/pull/10777)
- **decidim-participatory processes**: Backport 'Add metrics, statistics and process type to the participatory process importer' to v0.27 [\#10770](https://github.com/decidim/decidim/pull/10770)
- Backport 'Fix menu spec after #9928' to v0.27 [\#10769](https://github.com/decidim/decidim/pull/10769)
- **decidim-meetings**: Backport 'Fix meetings calendar filtering' to v0.27 [\#10772](https://github.com/decidim/decidim/pull/10772)
- **decidim-initiatives**: Backport 'Fix initiative creation missing form fields' to v0.27 [\#10785](https://github.com/decidim/decidim/pull/10785)
- **decidim-initiatives**: Backport 'Fix edge case in initiative creation' to v0.27 [\#10784](https://github.com/decidim/decidim/pull/10784)
- **decidim-proposals**: Backport 'Fix notifications for the proposal answers importer' to v0.27 [\#10787](https://github.com/decidim/decidim/pull/10787)
- **decidim-initiatives**: Backport 'Fix edit form in intitiatives' to v0.27 [\#10781](https://github.com/decidim/decidim/pull/10781)
- **decidim-comments**: Backport 'Fix missing hide and show comments by threads' to v0.27 [\#10779](https://github.com/decidim/decidim/pull/10779)
- **decidim-core**: Backport 'Fix ImageMagick errors when trying to identify image dimensions' to v0.27 [\#10556](https://github.com/decidim/decidim/pull/10556)
- **decidim-participatory processes**: Backport 'Fix issues with unexpected date filter params for the process listing' to v0.27 [\#10807](https://github.com/decidim/decidim/pull/10807)
- **decidim-initiatives**: Backport 'Fix initiative creation without fallback hash attribute' to v0.27 [\#10817](https://github.com/decidim/decidim/pull/10817)
- **decidim-core**: Backport 'Fix: Inconsistent datetime distance_in_words translations' to 0.27 [\#10793](https://github.com/decidim/decidim/pull/10793)
- **decidim-core**: Backport 'Refactor attachment title' to v0.27 [\#10664](https://github.com/decidim/decidim/pull/10664)
- **decidim-budgets**: Backport 'Fix budget summary mail when a scope is defined and enabled' to v0.27 [\#10838](https://github.com/decidim/decidim/pull/10838)
- **decidim-core**, **decidim-proposals**: Backport 'Fix File attachments in proposals' to v0.27 [\#10827](https://github.com/decidim/decidim/pull/10827)
- **decidim-initiatives**: Backport 'Change the participant initiatives editor toolbars type' to v0.27 [\#10844](https://github.com/decidim/decidim/pull/10844)

### Removed

Nothing.

### Developer improvements

Nothing.

### Internal

- Backport 'Switch to the official Codecov action for CI' to v0.27 [\#10462](https://github.com/decidim/decidim/pull/10462)
- **decidim-proposals**: Backport 'Fix flaky collaborative drafts specs' to v0.27 [\#10667](https://github.com/decidim/decidim/pull/10667)
- Backport 'Fix menu spec after #9928' to v0.27 [\#10769](https://github.com/decidim/decidim/pull/10769)
- Backport 'Remove parallel spec from the core system specs' to v0.27 [\#10843](https://github.com/decidim/decidim/pull/10843)

## [0.27.2](https://github.com/decidim/decidim/tree/0.27.2)

### Added

Nothing.

### Changed

Nothing.

### Fixed

- **decidim-core**: Backport 'Fix: The i18n locales selector is showing a dropdown with 3 languages' to v0.27 [\#10087](https://github.com/decidim/decidim/pull/10087)
- **decidim-core**: Backport 'Remove unecessary line in push notifications spec' to v0.27 [\#10088](https://github.com/decidim/decidim/pull/10088)
- Backport 'Lock GitHub actions to Ubuntu 20.04 due to OpenSSL 3.0 issues' to v0.27 [\#10225](https://github.com/decidim/decidim/pull/10225)
- **decidim-core**: Add date format to Conversation [\#10224](https://github.com/decidim/decidim/pull/10224)
- **decidim-core**: Backport 'Allow blocking a UserGroup' to v0.27 [\#10255](https://github.com/decidim/decidim/pull/10255)
- **decidim-admin**, **decidim-assemblies**, **decidim-elections**, **decidim-initiatives**, **decidim-pages**, **decidim-participatory processes**: Backport 'Fix wrong capitalization in i18n values and add missing keys' to v0.27 [\#10256](https://github.com/decidim/decidim/pull/10256)
- **decidim-api**, **decidim-core**: Backport 'Fix machine translations at the API' to v0.27 [\#10257](https://github.com/decidim/decidim/pull/10257)
- **decidim-budgets**: Backport 'Correct the "voted for this" string in the budgets component' to v0.27 [\#10258](https://github.com/decidim/decidim/pull/10258)
- **decidim-conferences**, **decidim-core**: Backport 'Fix translations missing on admin log' to v0.27 [\#10259](https://github.com/decidim/decidim/pull/10259)
- **decidim-core**: Backport 'Fix push notifications URL method' to v0.27 [\#10262](https://github.com/decidim/decidim/pull/10262)
- **decidim-conferences**: Backport 'Add correct call for conference speaker' to v0.27 [\#10260](https://github.com/decidim/decidim/pull/10260)
- **decidim-meetings**: Backport 'Fix missing fields on duplicate meetings functionality' to v0.27 [\#10261](https://github.com/decidim/decidim/pull/10261)
- **decidim-core**: Backport 'Fix resource_icon with component or manifest nil' to v0.27 [\#10263](https://github.com/decidim/decidim/pull/10263)
- **decidim-budgets**, **decidim-core**, **decidim-debates**, **decidim-meetings**, **decidim-proposals**, **decidim-sortitions**: Backport 'Fix filter URL not updated with the text search input' to v0.27 [\#10264](https://github.com/decidim/decidim/pull/10264)
- **decidim-core**: Backport 'Add missing logs for UserGroup block and unblock actions' to v0.27 [\#10266](https://github.com/decidim/decidim/pull/10266)
- **decidim-admin**, **decidim-core**: Backport 'Don't show the 'unreport' action when user is blocked' to v0.27 [\#10267](https://github.com/decidim/decidim/pull/10267)
- **decidim-admin**, **decidim-core**: Backport 'Fix bug when blocking two UserGroups' to v0.27 [\#10269](https://github.com/decidim/decidim/pull/10269)
- **decidim-core**: Backport 'Add order by in linked_participatory_space_resources' to v0.27 [\#10270](https://github.com/decidim/decidim/pull/10270)
- **decidim-blogs**: Backport 'Move i18n attribute key of Post's body' to v0.27 [\#10265](https://github.com/decidim/decidim/pull/10265)
- **decidim-core**: Backport 'Fix dependency resolver trying to fetch gem paths from lazy specifications' to v0.27 [\#10272](https://github.com/decidim/decidim/pull/10272)
- **decidim-core**: Backport 'Fix double parentheses in the titled upload modal with existing attachment' to v0.27 [\#10273](https://github.com/decidim/decidim/pull/10273)
- **decidim-proposals**: Backport 'Removed "disabled" status from proposals' main categories' to v0.27 [\#10274](https://github.com/decidim/decidim/pull/10274)
- **decidim-core**: Backport 'Improve link handling of the redirect engine' to v0.27 [\#10276](https://github.com/decidim/decidim/pull/10276)
- **decidim-core**: Backport 'Fix pipeline asset absolute URLs' to v0.27 [\#10275](https://github.com/decidim/decidim/pull/10275)
- **decidim-accountability**, **decidim-initiatives**, **decidim-participatory processes**: Backport 'Added missing localizations' to v0.27 [\#10278](https://github.com/decidim/decidim/pull/10278)
- **decidim-blogs**: Backport 'Remove unused permissions on Blogs' to v0.27 [\#10268](https://github.com/decidim/decidim/pull/10268)
- **decidim-initiatives**: Backport 'Respect "rich text editor" setting in Initiatives' to v0.27 [\#10271](https://github.com/decidim/decidim/pull/10271)
- **decidim-proposals**: Backport 'Prevent sending proposal create event until is commited' to v0.27 [\#10279](https://github.com/decidim/decidim/pull/10279)
- **decidim-initiatives**: Backport 'Fix initiatives count in initiatives index page' to v0.27 [\#10280](https://github.com/decidim/decidim/pull/10280)
- **decidim-core**: Backport 'User's group endorsement no longer disappears after personal endorsement removed' to v0.27 [\#10281](https://github.com/decidim/decidim/pull/10281)
- **decidim-core**: Backport 'Fix bug regarding user group moderation action logs' to v0.27 [\#10254](https://github.com/decidim/decidim/pull/10254)
- **decidim-assemblies**, **decidim-conferences**, **decidim-participatory processes**: Backport 'Do not display unpublished spaces in linked spaces' to v0.27 [\#10346](https://github.com/decidim/decidim/pull/10346)
- **decidim-assemblies**, **decidim-meetings**: Backport 'Display Published meetings in Assembly cell' to v0.27 [\#10340](https://github.com/decidim/decidim/pull/10340)
- **decidim-core**: Backport 'Uploading files - Explanation %{attribute} not translate' to v0.27 [\#10348](https://github.com/decidim/decidim/pull/10348)
- **decidim-admin**, **decidim-core**: Backport 'Fix newsletters unwanted CSS and 404 page on preview' to v0.27 [\#10354](https://github.com/decidim/decidim/pull/10354)
- **decidim-admin**: Backport 'A Valuator should not be able to access Global Moderation' to v0.27 [\#10350](https://github.com/decidim/decidim/pull/10350)
- **decidim-core**: Backport 'Fix an edge case with the attribute object forms with arrays/enums' (#10218) to v0.27 [\#10358](https://github.com/decidim/decidim/pull/10358)
- **decidim-initiatives**: Backport 'Fixing some typos in the english translations' to v0.27 [\#10361](https://github.com/decidim/decidim/pull/10361)

### Removed

Nothing.

### Developer improvements

- Backport 'Remove unecessary line in push notifications spec' to v0.27 [\#10088](https://github.com/decidim/decidim/pull/10088)

### Internal

- Backport 'Lock GitHub actions to Ubuntu 20.04 due to OpenSSL 3.0 issues' to v0.27 [\#10225](https://github.com/decidim/decidim/pull/10225)

### Unsorted


## [0.27.1](https://github.com/decidim/decidim/tree/0.27.1)

### Added

Nothing.

### Changed

Nothing.

### Fixed

- **decidim-participatory processes**: Backport 'Fix unpublished processes shown in the group process count' to v0.27 [\#9935](https://github.com/decidim/decidim/pull/9935)
- **decidim-admin**: Backport 'Fix global moderation types not translated' to v0.27 [\#9936](https://github.com/decidim/decidim/pull/9936)
- **decidim-admin**: Backport 'Fix updating organization settings in case there were errors' to v0.27 [\#9939](https://github.com/decidim/decidim/pull/9939)
- **decidim-budgets**, **decidim-core**, **decidim-elections**, **decidim-proposals**: Backport 'Do not import resources multiple times' to v0.27 [\#9943](https://github.com/decidim/decidim/pull/9943)
- **decidim-forms**, **decidim-surveys**: Backport 'Fix form answer attachments breaking the answer view' to v0.27 [\#9944](https://github.com/decidim/decidim/pull/9944)
- **decidim-comments**, **decidim-core**, **decidim-verifications**: Backport 'Fix user related absolute URLs' to v0.27 [\#9946](https://github.com/decidim/decidim/pull/9946)
- **decidim-comments**: Backport 'Fix "disappearing" underscores with comments' to v0.27 [\#9948](https://github.com/decidim/decidim/pull/9948)
- **decidim-admin**, **decidim-core**: Backport 'Fix editor content saving when the content has only one video' to v0.27 [\#9950](https://github.com/decidim/decidim/pull/9950)
- **decidim-core**: Backport 'Fix date/time formats at component forms' to v0.27 [\#9952](https://github.com/decidim/decidim/pull/9952)
- **decidim-proposals**: Backport 'Fix collaborative drafts page when there are errors on the form' to v0.27 [\#9954](https://github.com/decidim/decidim/pull/9954)
- **decidim-debates**: Backport 'Fix the finite value on the debate form when editing an existing debate' to v0.27 [\#9956](https://github.com/decidim/decidim/pull/9956)
- **decidim-pages**: Backport 'Fix exporting and importing a page component' to v0.27 [\#9958](https://github.com/decidim/decidim/pull/9958)
- **decidim-core**: Backport 'Fix webpacker crashes on missing icons' to v0.27 [\#9960](https://github.com/decidim/decidim/pull/9960)
- **decidim-participatory processes**: Backport 'Fix importing participatory process from legacy format' to v0.27 [\#9963](https://github.com/decidim/decidim/pull/9963)
- **decidim-assemblies**, **decidim-core**, **decidim-participatory processes**: Backport 'Fix duplicate stats on home page and participatory space main page' to v0.27 [\#9965](https://github.com/decidim/decidim/pull/9965)
- **decidim-budgets**, **decidim-core**, **decidim-proposals**, **decidim-templates**: Backport 'Address Crowdin feedback' to v0.27 [\#9969](https://github.com/decidim/decidim/pull/9969)
- **decidim-core**, **decidim-proposals**: Backport 'Fix cryptic file validation errors' to v0.27 [\#9971](https://github.com/decidim/decidim/pull/9971)
- **decidim-core**: Backport 'Limit invitation redirects only to paths within the application' to v0.27 [\#9972](https://github.com/decidim/decidim/pull/9972)
- **decidim-admin**, **decidim-assemblies**, **decidim-participatory processes**: Backport 'Add malformed file errors when CSV reading fails' to v0.27 [\#9974](https://github.com/decidim/decidim/pull/9974)
- **decidim-elections**: Backport 'Define the component import routes, permissions and controller at votings' to v0.27 [\#9976](https://github.com/decidim/decidim/pull/9976)
- **decidim-core**: Backport 'Fix duplicate user activity records when public spaces have private users' to v0.27 [\#9978](https://github.com/decidim/decidim/pull/9978)
- **decidim-initiatives**: Backport 'Fix initiative sign if the authorization metadata is set to `nil`' to v0.27 [\#9980](https://github.com/decidim/decidim/pull/9980)
- **decidim-initiatives**: Backport 'Add missing i18n key in Initiatives' to v0.27 [\#9982](https://github.com/decidim/decidim/pull/9982)
- **decidim-comments**: Backport 'Fix commenting field disabled when polling new comments' to v0.27 [\#9986](https://github.com/decidim/decidim/pull/9986)
- **decidim-core**: Backport 'Fix correct resource linking for amendments' to v0.27 [\#9987](https://github.com/decidim/decidim/pull/9987)
- **decidim-core**: Backport 'Fix last activity page showing recently updated records' to v0.27 [\#9989](https://github.com/decidim/decidim/pull/9989)
- **decidim-core**: Backport 'Fix user sign up with invalid name' to v0.27 [\#9990](https://github.com/decidim/decidim/pull/9990)
- **decidim-core**: Backport 'Fix user sign up with invalid name' to v0.27 [\#9990](https://github.com/decidim/decidim/pull/9990)
- **decidim-admin**, **decidim-assemblies**, **decidim-initiatives**, **decidim-participatory processes**, **decidim-verifications**: Backport 'Add missing active actions on admin navigation menu' to v0.27 [\#9992](https://github.com/decidim/decidim/pull/9992)
- **decidim-admin**, **decidim-assemblies**, **decidim-initiatives**, **decidim-participatory processes**, **decidim-verifications**: Backport 'Add missing active actions on admin navigation menu' to v0.27 [\#9992](https://github.com/decidim/decidim/pull/9992)
- **decidim-admin**, **decidim-assemblies**, **decidim-initiatives**, **decidim-participatory processes**, **decidim-verifications**: Backport 'Add missing active actions on admin navigation menu' to v0.27 [\#9992](https://github.com/decidim/decidim/pull/9992)
- **decidim-initiatives**: Backport 'Make initiatives order translatable' to v0.27 [\#9994](https://github.com/decidim/decidim/pull/9994)
- **decidim-core**: Backport 'Make ToS agreement translatable' to v0.27 [\#9996](https://github.com/decidim/decidim/pull/9996)
- **decidim-debates**: Backport 'Make Scopes field in debates translatable' to v0.27 [\#9998](https://github.com/decidim/decidim/pull/9998)
- **decidim-core**: Backport 'Remove invitations badge' to v0.27 [\#10000](https://github.com/decidim/decidim/pull/10000)
- **decidim-conferences**: Backport 'Fix conference invitations' to v0.27 [\#10003](https://github.com/decidim/decidim/pull/10003)
- **decidim-admin**, **decidim-core**: Backport 'Fix preserving bold text in the rich text editor when pasting content' to v0.27 [\#9961](https://github.com/decidim/decidim/pull/9961)
- **decidim-core**, **decidim-proposals**: Backport 'Fix proposal etiquette and length validator with base64 images' to v0.27 [\#10009](https://github.com/decidim/decidim/pull/10009)
- **decidim-core**: Backport 'Fix disappearing sub-lists in rich text editors' to v0.27 [\#9967](https://github.com/decidim/decidim/pull/9967)
- **decidim-meetings**, **decidim-proposals**: Backport 'Fix invalid rendering of meeting and proposal body texts' to v0.27 [\#10002](https://github.com/decidim/decidim/pull/10002)
- **decidim-core**, **decidim-debates**, **decidim-meetings**, **decidim-proposals**: Backport 'Refactor cell titles' to v0.27 [\#10040](https://github.com/decidim/decidim/pull/10040)
- **decidim-admin**, **decidim-comments**: Backport 'Fix moderations for comments that are mapped to deleted resources' to v0.27 [\#9940](https://github.com/decidim/decidim/pull/9940)
- **decidim-meetings**: Backport 'Refactor the meeting list item title display' to v0.27 [\#10046](https://github.com/decidim/decidim/pull/10046)
- **decidim-system**: Backport 'Fix organization SMTP password not saved (became blank) in system panel' to v0.27 [\#10052](https://github.com/decidim/decidim/pull/10052)
- **decidim-accountability**, **decidim-admin**, **decidim-proposals**: Backport 'Reformat CSV help for import files on Accountability and Proposals' to v0.27 [\#10054](https://github.com/decidim/decidim/pull/10054)
- **decidim-budgets**, **decidim-elections**, **decidim-proposals**, **decidim-sortitions**: Backport 'Fix usages of `reorder` and `paginate`' to v0.27 [\#10050](https://github.com/decidim/decidim/pull/10050)
- **decidim-admin**: Backport 'Show only ToS acceptance when admin hasn't accepted it' to v0.27 [\#10056](https://github.com/decidim/decidim/pull/10056)
- **decidim-participatory processes**: Backport 'Fix usages of sanitize helper methods for editable content provided by admins' to v0.27 [\#10058](https://github.com/decidim/decidim/pull/10058)
- **decidim-debates**, **decidim-meetings**, **decidim-proposals**: Backport 'Refactor admin listing titles' to v0.27 [\#10048](https://github.com/decidim/decidim/pull/10048)

### Removed

Nothing.

### Developer improvements

Nothing.

### Internal

- **decidim-dev**: Backport 'Ignore the problematics HTML validation checks with hidden inputs' to v0.27 [\#10025](https://github.com/decidim/decidim/pull/10025)
- Backport 'Bump versions on install docs' to v0.27 [\#10008](https://github.com/decidim/decidim/pull/10008)
- **decidim-assemblies**: Backport 'Fix importing a page component without a body' to v0.27 [\#10029](https://github.com/decidim/decidim/pull/10029)

## [0.27.0](https://github.com/decidim/decidim/tree/0.27.0)

### Detailed changes

#### Added

Nothing.

#### Changed

Nothing.

#### Fixed

Nothing.

#### Removed

Nothing.

#### Developer improvements

Nothing.

## [0.27.0.rc2](https://github.com/decidim/decidim/tree/0.27.0.rc2)

### Detailed changes

#### Added

Nothing.

#### Changed

Nothing.

#### Fixed

- **decidim-assemblies**, **decidim-conferences**, **decidim-consultations**, **decidim-core**, **decidim-elections**, **decidim-initiatives**, **decidim-participatory processes**: Backport 'Fix background-image URLs with weird characters' to v0.27 [\#9495](https://github.com/decidim/decidim/pull/9495)
- **decidim-comments**, **decidim-core**: Backport 'Fix long word breaking on comments and cards' to v0.27 [\#9530](https://github.com/decidim/decidim/pull/9530)
- **decidim-core**: Backport 'Fix nested attributes model mapping' to v0.27 [\#9532](https://github.com/decidim/decidim/pull/9532)
- **decidim-initiatives**: Backport 'Add the rexml gem as a requirement for Ruby 3.0.0+ compatibility' to v0.27 [\#9533](https://github.com/decidim/decidim/pull/9533)
- **decidim-elections**: Backport 'Advertise users if BB connection is lost in trustees/admin zones' to v0.27 [\#9534](https://github.com/decidim/decidim/pull/9534)
- **decidim-assemblies**, **decidim-conferences**, **decidim-elections**: Backport 'Fix cache hash on Hightlighted spaces' to v0.27 [\#9537](https://github.com/decidim/decidim/pull/9537)
- **decidim-core**: Backport 'Fix email subject when participatory space title is present' to v0.27 [\#9538](https://github.com/decidim/decidim/pull/9538)
- **decidim-accountability**: Backport 'Add short format to result date' to v0.27 [\#9541](https://github.com/decidim/decidim/pull/9541)
- **decidim-conferences**: Backport 'Fix published conferences order' to v0.27 [\#9687](https://github.com/decidim/decidim/pull/9687)
- **decidim-comments**: Backport 'Fix creation notification when editing a comment ' to v0.27 [\#9689](https://github.com/decidim/decidim/pull/9689)
- **decidim-elections**: Backport 'Remove margin-bottom on votings navigation' to v0.27 [\#9691](https://github.com/decidim/decidim/pull/9691)
- **decidim-initiatives**: Backport 'Use public link on initiatives mailer' to v0.27 [\#9693](https://github.com/decidim/decidim/pull/9693)
- **decidim-accountability**: Backport 'Disallow creating grandchildren results' to v0.27 [\#9697](https://github.com/decidim/decidim/pull/9697)
- **decidim-forms**, **decidim-meetings**: Backport 'Prevent showing announcement on meetings registrations' to v0.27 [\#9699](https://github.com/decidim/decidim/pull/9699)
- **decidim-initiatives**: Backport 'Fix for initiative mailer when promoting committee is disabled' to v0.27 [\#9695](https://github.com/decidim/decidim/pull/9695)
- **decidim-elections**: Backport 'Improve steps election check page with census' to v0.27 [\#9701](https://github.com/decidim/decidim/pull/9701)
- **decidim-core**: Backport 'Fix translated attributes field type change' to v0.27 [\#9703](https://github.com/decidim/decidim/pull/9703)
- **decidim-core**: Backport 'Prevent missing ActionLog entries to break the application' to v0.27 [\#9705](https://github.com/decidim/decidim/pull/9705)
- **decidim-proposals**: Backport 'Fix publish event on official proposals' to v0.27 [\#9707](https://github.com/decidim/decidim/pull/9707)
- **decidim-admin**, **decidim-proposals**: Backport 'Add help text for proposals' 'publish answers immediately' setting ' to v0.27 [\#9711](https://github.com/decidim/decidim/pull/9711)
- **decidim-conferences**: Backport 'Return 404 when there isn't a valid component in program' to v0.27 [\#9716](https://github.com/decidim/decidim/pull/9716)
- **decidim-budgets**: Backport 'Fix budgets seeds on non development apps' to v0.27 [\#9718](https://github.com/decidim/decidim/pull/9718)
- **decidim-core**: Backport 'Fix creating automatic nicknames when taken by user_groups' to v0.27 [\#9720](https://github.com/decidim/decidim/pull/9720)
- **decidim-debates**: Backport 'Fix resource endorsed notification with Debates' to v0.27 [\#9722](https://github.com/decidim/decidim/pull/9722)
- **decidim-core**: Backport 'Set push notifications in user locale' to v0.27 [\#9724](https://github.com/decidim/decidim/pull/9724)
- **decidim-elections**: Backport 'Improve census importing process in elections/votings space' to v0.27 [\#9725](https://github.com/decidim/decidim/pull/9725)
- **decidim-core**: Backport 'Strip tags keeping entity characters' to v0.27 [\#9726](https://github.com/decidim/decidim/pull/9726)
- **decidim-meetings**: Backport 'Fix agenda_item association with agenda' to v0.27 [\#9727](https://github.com/decidim/decidim/pull/9727)
- **decidim-verifications**: Backport 'Fix absolute urls on 'managed user error' event' to v0.27 [\#9729](https://github.com/decidim/decidim/pull/9729)
- **decidim-core**: Backport 'Fix mobile notifications switch component overlaps' to v0.27 [\#9731](https://github.com/decidim/decidim/pull/9731)
- **decidim-core**: Backport 'Fix account update without password change' to v0.27 [\#9735](https://github.com/decidim/decidim/pull/9735)
- **decidim-meetings**: Backport 'Fix order when filtering Meetings' to v0.27 [\#9737](https://github.com/decidim/decidim/pull/9737)
- **decidim-admin**: Backport 'Fix admin autocomplete when a locale is defined in the URL' to v0.27 [\#9738](https://github.com/decidim/decidim/pull/9738)
- **decidim-core**: Backport 'Fix blocked user nickname and avatar in user presenter' to v0.27 [\#9740](https://github.com/decidim/decidim/pull/9740)
- **decidim-core**: Backport 'Change the custom public port ENV variable name to HTTP_PORT' to v0.27 [\#9747](https://github.com/decidim/decidim/pull/9747)
- **decidim-admin**: Backport 'Fix form error overlap with character counter in the admin panel' to v0.27 [\#9748](https://github.com/decidim/decidim/pull/9748)
- **decidim-core**: Backport 'Fix the endorsement permissions' to v0.27 [\#9733](https://github.com/decidim/decidim/pull/9733)
- **decidim-core**: Backport 'Fix PWA install prompt keeps appearing more than once' to v0.27 [\#9744](https://github.com/decidim/decidim/pull/9744)
- **decidim-core**: Backport 'Fix issues with daily and weekly notifications' to v0.27 [\#9739](https://github.com/decidim/decidim/pull/9739)
- **decidim-proposals**: Backport 'Fix redundant notification on comments with linked proposals' to v0.27 [\#9745](https://github.com/decidim/decidim/pull/9745)
- **decidim-generators**: Backport 'Add missing queue close_meeting_reminder to sidekiq configuration' to v0.27 [\#9715](https://github.com/decidim/decidim/pull/9715)
- **decidim-core**: Backport 'Make the HERE Map display in the currently selected language' to v0.27 [\#9713](https://github.com/decidim/decidim/pull/9713)
- **decidim-admin**, **decidim-forms**: Backport 'Fix admin language selector with more than 4 locales' to v0.27 [\#9709](https://github.com/decidim/decidim/pull/9709)
- **decidim-core**, **decidim-dev**, **decidim-generators**: Backport 'Fix data consent expiry' to v0.27 [\#9742](https://github.com/decidim/decidim/pull/9742)
- **decidim-core**: Backport 'Fix uninitialized constant errors with custom set of modules' to v0.27 [\#9743](https://github.com/decidim/decidim/pull/9743)
- **decidim-meetings**: Backport 'Ignore participatory spaces without models in meetings visible_for scope' to v0.27 [\#9795](https://github.com/decidim/decidim/pull/9795)
- **decidim-admin**: Backport 'Fix leaking emails on admin user search controller' to 0.27 [\#9796](https://github.com/decidim/decidim/pull/9796)
- **decidim-core**: Backport 'Fix order of last activities' to v0.27 [\#9802](https://github.com/decidim/decidim/pull/9802)
- **decidim-conferences**: Backport 'Fix conference speaker avatars' to v0.27 [\#9823](https://github.com/decidim/decidim/pull/9823)
- **decidim-core**: Backport 'Prevent the account edit route through Devise' to v0.27 [\#9806](https://github.com/decidim/decidim/pull/9806)
- **decidim-accountability**, **decidim-core**, **decidim-debates**, **decidim-initiatives**, **decidim-meetings**, **decidim-proposals**: Backport 'Fix version pages showing a HTTP 500 error when the version does not exist' to v0.27 [\#9810](https://github.com/decidim/decidim/pull/9810)
- **decidim-core**: Backport 'Fix hashtags not recognized at the beginning of the string' to v0.27 [\#9812](https://github.com/decidim/decidim/pull/9812)
- **decidim-comments**: Backport 'Fix posting comments before the initial load has run' to v0.27 [\#9815](https://github.com/decidim/decidim/pull/9815)
- **decidim-core**: Backport 'Fix hidden error messages on the registration form' to v0.27 [\#9814](https://github.com/decidim/decidim/pull/9814)
- **decidim-core**: Backport 'Fix multitenant organizations stats cache' to v0.27 [\#9808](https://github.com/decidim/decidim/pull/9808)
- **decidim-core**: Backport 'Fix character counter for the WYSIWYG editor' to v0.27 [\#9816](https://github.com/decidim/decidim/pull/9816)
- **decidim-admin**, **decidim-initiatives**: Backport 'Fix initiatives components' to v0.27 [\#9824](https://github.com/decidim/decidim/pull/9824)
- **decidim-core**, **decidim-meetings**: Backport 'Fix iframe disabling producing invalid HTML' to v0.27 [\#9805](https://github.com/decidim/decidim/pull/9805)
- **decidim-assemblies**, **decidim-participatory processes**: Backport 'Fix import of images on spaces' to v0.27 [\#9804](https://github.com/decidim/decidim/pull/9804)
- **decidim-core**: Backport 'Fix doorkeeper initialization after 5.6.0 release' to v0.27 [\#9787](https://github.com/decidim/decidim/pull/9787)

#### Removed

Nothing.

#### Developer improvements

Nothing.

## [0.27.0.rc1](https://github.com/decidim/decidim/tree/0.27.0.rc1)

### 1. Upgrade notes

As usual, we recommend that you have a full backup, of the database, application code and static files.

To update, follow these steps:

#### 1.1. Update your Gemfile

```ruby
gem "decidim", "0.27.0.rc1"
gem "decidim-dev", "0.27.0.rc1"
```

#### 1.2. Run these commands

```console
bundle update decidim
bin/rails decidim:upgrade
bin/rails db:migrate
```

#### 1.3. Follow the steps and commands detailed in these notes

### 2. General notes

#### 2.1. Ruby update to 3.0

We have updated the Ruby version to 3.0.2. Upgrading to this version will require either to install the Ruby Version on your host, or change the decidim docker image to use ruby:3.0.2.

You can read more about this change on PR [\#8452](https://github.com/decidim/decidim/pull/8452).

#### 2.2. Rails update to 6.1

We have updated the Ruby on Rails version to 6.1. This will be done automatically when doing the `bundle update`. If you had any code customization you'll probably need to take this into account and update your code. Some important aspects to mention:

- ActionMailer - Change default queue name of the deliver (:mailers) job to be the job adapter's default (:default)
- ActiveSupport - Remove deprecated fallback to I18n.default_locale when config.i18n.fallbacks is empty. This change should be transparent for all the Decidim users that have configured the `Decidim.default_locale`
- If you are using Spring, it is highly suggested to add the following line at the top of your application's `config/spring.rb` (especially if you are seeing the following messages in the console `ERROR: directory is already being watched!`):

```ruby
require "decidim/spring"
```

You can read more about this change on PR [\#8411](https://github.com/decidim/decidim/pull/8411).

#### 2.3. Data consent change (aka "cookie consent")

Local data consent management has been updated, generally also referred to as "cookie consent". Supported data consent categories are essential, preferences, analytics and marketing.

This feature is many times referred to as "cookie consent" due to historic reasons but in Decidim we prefer to call it "data consent" because this can also include other data stored in the user's browser using its APIs, such as data added to LocalStorage.

As many non-technical people are still more familiar with the "cookie" terminology, the user interface talks only about "Cookie consent" to make it easier to understand for non-technical participants.

Iframe HTML elements that are added with the editor or meeting forms are disabled until data consent is given for all data categories. Scripts that require local data to be stored in the user's browser could be added as follows:

```html
<script type="text/plain" data-consent="marketing">
  console.log("marketing data consent given");
</script>
```

Note that you need to define the `type="text/plain"` for the script that adds local data to the user's browser in order to prevent the script from being executed before data consent is given. You should also define the metadata for all the local data that you or your 3rd party scripts are adding to the user's browser.

Mind that we also changed the data consent cookie from "decidim-cc" to "decidim-consent" by default. You can change it on your initializer, or update your legal notice accordingly.

Learn more about [Data consent at Decidim Documentation](https://docs.decidim.org/en/customize/data_consent). You can read more about this change on PR [\#9271](https://github.com/decidim/decidim/pull/9271).

#### 2.4. Configuration via Environment Variables

We've modified the default installation to configure most of the application through Environment Variables. For existing installations we recommend that you migrate to this new model so its easier to configure your applications.

As an example, after migrating to this, if you want to enable a setting, you'll need to:

a. Set the correct Environment Variable
b. Restart the server

Until now the flow could be something like:

a. Change your initializer
b. Commit to git
c. Push to git server
d. Deploy to the server
e. Restart the server

For migrating:

1. Backup your `config/secrets.yml` and `config/initializers/decidim.rb`
1. Generate a new decidim app and copy your generated files
1. Migrate your old settings to the new Environment Variables.

Learn more about [Environment Variables at Decidim Documentation](https://docs.decidim.org/en/configure/environment_variables/). You can read more about this change on PR [\#8725](https://github.com/decidim/decidim/pull/8725).

#### 2.5. GraphQL API documentation change

We've replaced the `graphql-docs` npm package with gem. You shouldn't need to do anything as this will be handled automatically.

The static documentation will be rendered into the `app/views/static/api/docs` directory, which is being refreshed automatically when you run `bin/rails decidim:upgrade`.

You can read more about this change on PR [\#8631](https://github.com/decidim/decidim/pull/8631).

#### 2.6. Custom icons new uploader

We now only allow PNG images at Favicon so we can provide higher quality versions to mobile devices.

You can read more about this change on PR [\#8645](https://github.com/decidim/decidim/pull/8645).

#### 2.7. Strong password rules for admin users

For extra security, there are new password rules for administrator users which are enabled by default. This means that:

- This will force the current administrators to change their passwords after 90 days has passed from the previous login.
- For development/testing/staging environments this also means that the default user passwords have changed to `decidim123456789` to match the minimum length rules for admins.
- For consistency reasons, regular users password has also been changed with the seed data.

The relevant [Environment Variables](https://docs.decidim.org/en/configure/environment_variables/) are:

| Name | Value | Default value |
| -------- | -------- | -------- |
| DECIDIM_ADMIN_PASSWORD_STRONG     | Enable strong password rules for admin users.     | true     |
| DECIDIM_ADMIN_PASSWORD_EXPIRATION_DAYS | Defines how many days admin passwords are valid before they need to be reset. | 90 |
| DECIDIM_ADMIN_PASSWORD_REPETITION_TIMES | Defines how many previous passwords are compared against new admin user passwords. | 5 |
| DECIDIM_ADMIN_PASSWORD_MIN_LENGTH | The minimum character length for admin user passwords. | 15 |

You can read more about this change on PR [\#9347](https://github.com/decidim/decidim/pull/9347).

#### 2.8 Service workers

For the Progressive Web Application related features, like Push Notifications and Add To Home Screen, you'll need to update your webpack configuration:

```console
bin/rails decidim:webpacker:install
```

You'll need to also add these to your .gitignore:

```gitignore
public/sw.js
public/sw.js.map
```

These files will be generated by the asset compilation task in your production server. Most of the time this should be handled automatically by your deployment process (like Capistrano or Heroku). In case that you need to run that manually, this is the command:

```console
bin/rails assets:precompile
```

In your development environment this should be happening automatically behind the scenes or if you are running the `./bin/webpack-dev-server` manually, during the recompilation process.

### 3. One time actions

These are one time actions that need to be done after the code is updated in the production database.

#### 3.1. Moderated content can now be removed from search index

We have fixed a bug where moderated resources weren't removed from the general search index. This will automatically work for new moderated resources. For already existing ones, we have introduced a new task that will remove the moderated content from being displayed in search:

```console
bin/rails decidim:upgrade:moderation:remove_from_search
```

You can read more about this change on PR [\#8811](https://github.com/decidim/decidim/pull/8811).

#### 3.2. New Comments statistics structure

We've fixed the stastics of comments in participatory spaces. You'll need to run the task:

```console
bin/rails decidim_comments:update_participatory_process_in_comments
```

You can read more about this change on PR [\#8012](https://github.com/decidim/decidim/pull/8012).

#### 3.3. Push Notifications

We've implemented Push Notifications for improving the engagement with the platform. To configure it:

##### 3.3.1. Generate the VAPID keys by running the command

```console
bin/rails decidim:pwa:generate_vapid_keys
```

##### 3.3.2. Copy them to your [Environment Variables](https://docs.decidim.org/en/configure/environment_variables/) file

The relevant [Environment Variables](https://docs.decidim.org/en/configure/environment_variables/) are:

| Name | Value | Default value |
| -------- | -------- | -------- |
| VAPID_PUBLIC_KEY | VAPID public key that will be used to sign the Push API requests. |  |
| VAPID_PRIVATE_KEY | VAPID private key that will be used to sign the Push API requests. |  |

These will be printed to the console when you run the command instructed in the previous step.

You can read more about this change on PR [\#8774](https://github.com/decidim/decidim/pull/8774).

#### 3.4. Categories' description is deprecated

The `description` field in the categories admin forms has been removed (this applies to any participatory space using categories). For now it's still available in the database, so you can extract it with the following command:

```console
bin/rails runner -e production 'Decidim::Category.pluck(:id, :name, :description).map { |row| puts row.join(";") }'
```

In the next version (v0.28.0) it will be fully removed from the database.

You can read more about this change on PR [\#8617](https://github.com/decidim/decidim/pull/8617).

#### 3.5. Global search user by nickname

We've added the ability to search for a user by nickname. You'll need to update the existing search index by running this in (be aware that it could take a while if your database has a lot of Users!):

```console
bin/rails runner -e production 'Decidim::User.find_each { |u| puts "Processing user #{u.id}" ; u.try_update_index_for_search_resource }'
```

You can read more about this change on PR [\#8658](https://github.com/decidim/decidim/pull/8658).

#### 3.6. Add CORS policy for dynamic file uploads

This release allows Decidim users to upload files to Decidim dynamically from their browsers. If you are using any external file storage providers, such as Amazon S3, Google Cloud Storage or Azure Storage, you need to configure a CORS policy for these service providers to make the uploads work for the end users. If you are using the default configurations with a local file storage, you don't have to do any extra configuration to make this work.

To configure the CORS policy for each 3rd party service, please refer to the [Active Storage section](https://docs.decidim.org/en/services/activestorage.html) of the documentation.

You can read more about this change on PR [\#8681](https://github.com/decidim/decidim/pull/8681).

### 4. Scheduled tasks

Implementers need to configure these changes it in your scheduler task system in the production server. We give the examples with `crontab`, although alternatively you could use `whenever` gem or the scheduled jobs of your hosting provider.

#### 4.1. Reminders for participants

We have added the possibility to send reminders for some actions, like pending budgets orders or user generated meetings that weren't closed.

```console
# Generate reminders
4 0 * * * cd /home/user/decidim_application && RAILS_ENV=production bundle exec rake decidim:reminders:all
```

You can read more about this change on PR [\#8621](https://github.com/decidim/decidim/pull/8621).

#### 4.2. Mail Notifications digest

Participants can configure if they want to receive notifications in real-time (one email by any action that they're notified to), or a daily or weekly notifications digest (a highlight with some of the notifications).

```console
# Send notification mail digest daily
5 0 * * * cd /home/user/decidim_application && RAILS_ENV=production bundle exec rake decidim:mailers:notifications_digest_daily

# Send notification mail digest weekly on saturdays
5 0 * * 6 cd /home/user/decidim_application && RAILS_ENV=production bundle exec rake decidim:mailers:notifications_digest_weekly
```

You can read more about this change on PR [\#8833](https://github.com/decidim/decidim/pull/8833).

#### 4.3. Rename data portability to download your data

"Data portability" has been renamed to "Download you data". As this was a scheduled task that was already configured you'll need to change it. Where you had:

```console
# Remove expired data portability files
0 0 * * * cd /home/user/decidim_application && RAILS_ENV=production bundle exec rake decidim:delete_data_portability_files
```

Changes to:

```console
# Remove expired download your data files
0 0 * * * cd /home/user/decidim_application && RAILS_ENV=production bundle exec rake decidim:delete_download_your_data_files
```

You can read more about this change on PR [\#9196](https://github.com/decidim/decidim/pull/9196).

### 5. Changes in APIs

#### 5.1. Javascript load at the bottom of the pages

For improving performance and load times, we've moved javascript snippets to the bottom of `body` sections.

If you are redefining Decidim layout, using partials including javascript packs, or have the "HTML snippet" option enabled, you might need to review them.

Also, you can no longer call jQuery or any other library in your views directly. For example the following snippet won't work:

```javascript
<script>
$(() => {
  $(".some-element").addClass("page-loadded"); // THIS WON'T WORK!
});
</script>
```

Instead of that, you should encapsulate it in a `content_for(:js_content)` block, that will render the snippet
right after javascript bundles have been loaded.

```javascript
<% content_for(:js_content) do %>
  <script>
    $(() => {
      $(".some-element").addClass("page-loadded");
    });
  </script>
<% end %>
```

You can read more about this change on PR [\#9156](https://github.com/decidim/decidim/pull/9156).

#### 5.2. Dynamic attachment uploads

We've changed the way file uploads work in Decidim. Files are now dynamically uploaded inside the modal so we can give the user immediate feedback on validation. If you didn't have any customization involving file uploads you can ignore this.

There are now two different types of file fields: titled and untitled. Titled file fields related to ```Decidim::Attachment``` internally.

**To update your module** you probably have to update forms and commands related to upload field (also views should be updated in case of titled attachments). After successful a upload and submitting a form, request params should contain signed_id of [ActiveStorage::Blob](https://api.rubyonrails.org/classes/ActiveStorage/Blob.html) which you need to find the blob at the backend. Some examples:

- To update view with titled file field see example: [edit_form_fields.html.erb](https://github.com/decidim/decidim/pull/8681/files#diff-17a22480fdfa3d439edcb26eb0a1a52bed5521d61ba36e0cc6ca83e838f03e9b)
- To update untitled form example: [import_form.rb](https://github.com/decidim/decidim/pull/8681/files#diff-5ce71b5873906c6f8919f4bc1f8c330bd97e8757760705a66c789f375eb743c1)
- To update untitled command example: [update_account.rb](https://github.com/decidim/decidim/pull/8681/files#diff-ed1274f76cd0ac1d5b223648dcdae670c2127c7dffa0d38540c1536a86f36abb)

Learn more about [Direct Uploads at Rails Documentation](https://edgeguides.rubyonrails.org/active_storage_overview.html#direct-uploads). You can read more about this change on PR [\#8681](https://github.com/decidim/decidim/pull/8681).

Module developers should also notice that when using `<%= form.upload :file %>` in your views, these fields are now automatically converted to dynamic upload fields. Regarding this, you will need to do a couple of changes in your code:

1. In your form classes, specify the attribute type as `Decidim::Attributes::Blob`, e.g. `attribute :file, Decidim::Attributes::Blob`
1. In your system tests, you might have previously used something like `attach_file(:your_form_file, file_fixture("your-test-file.xyz"))` to attach your file. Change these to `dynamically_attach_file(:your_form_file, file_fixture("your-test-file.xyz"))` in order to let the test helper handle the attachment for you as it has a few steps.
1. In other tests (such as commands, controllers, etc.), you might have previously used something like `fixture_file_upload(file_fixture("your-test-file.xyz"), "text/plain")`. This will not work anymore after you do the changes in the forms as they now expect either blobs or blob signed ID references. To fix this, replace these with `upload_test_file(Rack::Test::UploadedFile.new(file_fixture("your-test-file.xyz"), "text/plain"))`.
1. If you need to process files locally within your form classes or commands, you need to include the `Decidim::ProcessesFileLocally` concern and use the method it provides `process_file_locally(blob)` to get local access to the files that may be stored at 3rd party file storages. The method takes the ActiveStorage Blob as an argument and yields the path to the local file for the provided block argument.

#### 5.3. `Decidim::Form`s no longer use `Rectify::Form` and `Virtus` should be no longer used

If you don't have any customization involving Forms or `Virtus` you can ignore this.

As per [\#8669](https://github.com/decidim/decidim/pull/8669), your `Decidim::Form`s will no longer use `Rectify::Form` or `Virtus.model` attributes because `Virtus` is discontinued and Decidim is loosening the dependency on the `virtus` gem. Instead, the attributes implementation is now based on [`ActiveModel::Attributes`](https://api.rubyonrails.org/classes/ActiveModel/Attributes/ClassMethods.html) with an integration layer within Decidim that aims to provide as much backwards compatibility as possible with the `Virtus.model` attributes that were previously used.

For most cases, no changes in the code should be needed but there are specific differences with the implementation which may require changes in the 3rd party code as well. Both `Rectify::Form` and `Virtus` will be still available in the core (through the `rectify` gem) but you should migrate away from them as soon as possible as they may be removed in future versions of Decidim.

There are specific things that you need to change regarding your Form or `Virtus.model` classes when migrating to `Decidim::AttributeObject`:

- Change all instances of `YourForm < Rectify::Form` to `YourForm < Decidim::Form`. It should be very rare to find any classes in your code that inherit directly from `Rectify::Form` but in case you have used that, replace those references with `Decidim::Form`.
- Change all instances of `include Virtus.model` to `include Decidim::AttributeObject::Model`.
- For all file objects that may be of type `String` or `ActionDispatch::Http::UploadedFile`, remove the `String` type casting from these attributes as otherwise the uploaded file objects would be converted to strings. In other words, change all `attribute :uploaded_image, String` definitions within the forms to `attribute :uploaded_image` which allows them to be of any type.
- Change all `attribute :attr_name, Hash` to `attribute :attr_name, Hash[Symbol => ExpectedType]` where `ExpectedType` is the type you are expecting the hash values to be. The new layer will default the hash key types to `Symbol` and hash value types to `Object` (= any type). The Virtus Hash attribute did not force any default types for these. It should be preferred to use the actual expected type for the values instead of `Object` (= any type) to make your code more robust and less buggy.
- Change all `attribute :attr_name, Array` to `attribute :attr_name, Array[ExpectedType]` where `ExpectedType` is the type you are expecting the array values to be. It should be preferred to use the actual expected type for the values instead of `Object` (= any type) to make your code more robust and less buggy.
- The original form attribute values are no longer available through the `@attr_name` instance variables within the Form or `Virtus.model` classes. Instead, change all these references to `@attributes["attr_name"].value` in case you want to fetch the original value of the attribute without using its accessor method. Another way is to provide an alias for the original attribute method before overriding it. If you have not overridden the original attribute accessor, simply remove the `@` character in front of the attribute name to fetch the attribute value using the original accessor method.
- When calling the `attributes` method of the model/form classes, use strings to refer to the attribute names, not symbols as you might have done with `Virtus` or `Rectify::Form`. Change all `model.attributes[:attr_name]` method calls to `model.attributes["attr_name"]`.
- When calling `model.attributes.slice(...)`, you also need to use strings to refer to the attribute keys. Change all instances of `model.attributes.slice(:attr1, :attr2)` to `model.attributes.slice("attr1", "attr2")`
- If you had overridden any of the [`Rectify::Form` methods](https://github.com/andypike/rectify/blob/v0.13.0/lib/rectify/form.rb) within your form classes, remove those overrides. For example, you might have overridden the `form_attributes_valid?` method which no longer does anything. Instead, define a custom validation in order to add extra validations to your forms.
- Very rarely, when defining a an attribute of type `Rails::Engine`, you need to change `attribute :attr_name, Rails::Engine` to `attribute :attr_name, Rails::Engine, **{}`. This is because we want to preserve the method signature against `ActiveModel::Attributes` for the `attribute` class method intead of the legacy `Virtus.model`. There is a limitation in the Ruby language that if the method has default values for the previous arguments and defines keyword arguments, the last argument will always receive a `respond_to?(:to_hash)` call to it which doesn't work for `Rails::Engine` (you can try it out in the Rails console by calling `Rails::Engine.respond_to?(:to_hash)`).
- Test all your form and command classes thoroughly to notice any differences between the two implementations. The new layer is a bit more "robust" with some of the type castings, so some things may break during the migration in case you have relied on some of the oversights within `Virtus`.

#### 5.4. `Rectify::Presenter` deprecated

PR [\#8758](https://github.com/decidim/decidim/pull/8758) is deprecating the implementation of `Rectify::Presenter` in favour of `SimpleDelegator`

#### 5.5. Searchlight removal

The `searchlight` gem has been removed in favor of Ransack as of [\#8748](https://github.com/decidim/decidim/pull/8748) in order to standardize all searches within Decidim around a single way of performing searches. Ransack was selected as the preferred search backend because it is better maintained and has a larger community of developers around it compared to Searchlight.

Ransack provides a search API that produces the search queries semi-automatically against the available database columns and ActiveRecord scopes made available for the Ransack searches while Searchlight used to require to write all the search logic manually in the search classes. Due to the inner workings of the Ransack gem and for consistency reasons, the following changes have been made for the search filtering:

- For search scopes that are doing more than matching against a specific column in the database or require special programming logic during the searches, there is a new scope convention introduced with the `with_*` and `with_any_*` scope names. The `with_*` convention should be used when providing a search scope that searches against one key, such as `with_category(1)` and the `with_any_*` convention should be used when providing a search scope that searches against one or multiple keys, such as `with_any_category(1, 2, 3)`.
  - An example of such scope is `with_any_category` provided by the `HasCategory` concern which searches against the provided category IDs or any sub-category of those category IDs. You can find all the introduced (or changed) scopes by searching for `scope :with_` within the Decidim codebase.
  - With Searchlight, these search parameters were provided e.g. as `category_id` which was then used to perform the explained search query manually in the ResourceSearch class which is now used for a different purpose. As the search now happens through Ransack and the ActiveRecord scopes, these parameters have been renamed to better explain what they do. With Ransack, matching e.g. against the `category_id_eq` key would mean that the search is done against this specific column in the record's database table and only searching for the provided search input (and not e.g. the parent categories in the category case).
- The origin scopes provided by `Decidim::Authorable` and `Decidim::Coauthorable` have been renamed with the `with_` prefix as explained above.
- All the filtering key changes have been reflected to the participant filtering views (`_filters.html.erb` in most modules) as well as the controller methods `default_filter_params` where applicable.
- The `default_filter_params` method within the participant-facing controllers now defines all the parameters that are allowed in the search queries and only these parameters are passed to the Ransack search. This limitation is made in order to protect the participant views from providing more searching options through the URL parameters than they are supposed to provide. In the past, the `Searchlight::Search` classes took care of utilizing only the allowed parameters but Ransacker does not have any middle-layer that would do the same, which is why the limitation is done at the controller side.
- The `search_collection` method now defines the base collection used for the searches within the filtering controllers. In previous versions, there used to be a method that defined a `search_klass` method that defined the `Searchlight::Search` class to be used as the basis for the search. Now, the `search_collection` defines the base collection instead against which the Ransack search is run.

3rd party developers that have developed their own modules or customizations for the core controllers or filtering views, should revisit their customizations and make sure they reflect these changes made for the controllers or filtering views. It is suggested to remove the customizations related to the filtering views/controllers and re-do from scratch what needs to be customized in order to ensure full compatibility with the changed filtering APIs. In case you had created your own `Searchlight::Search` (or `ResourceSearch`) classes, you should scrap those and start over using Ransack.

More information on using Ransack can be found from the [Ransack documentation](https://github.com/activerecord-hackery/ransack). You can find examples for filtering in the core filtering views and controllers.

Related changes include:

- **decidim-core**: The `Decidim::ActivitySearch` class has been rewritten as `Decidim::PublicActivities` which is now a `Rectify::Query` class instead of `Searchlight::Search` class due to the removal of Searchlight at [\#8748](https://github.com/decidim/decidim/pull/8748).
- **decidim-core**: The `Decidim::ResourceSearch` class now inherits from `Ransack::Search` instead of `Searchlight::Search` as of [\#8748](https://github.com/decidim/decidim/pull/8748). The new `ResourceSearch` class provides extra search functionality for contextual searches that require context information in addition to the search parameters, such as current user or current component. It has barely anything to do with the `ResourceSearch` class in the previous versions which contained much more logic. Please review all your search classes that were inheriting from this class. You should migrate your search filtering to Ransack.
- **decidim-debates**, **decidim-initiatives**, **decidim-meetings**: The resource search classes `Decidim::Debates::DebateSearch`, `Decidim::Intitatives::InitiativeSearch` and `Decidim::Meetings::MeetingSearch` are rewritten for the Ransack searches due to Searchlight removal at [\#8748](https://github.com/decidim/decidim/pull/8748). The role of these classes is now to pass contextual information to the searches, such as the current user. All other search filtering should happen directly through Ransack.
- **decidim-meetings**: The `visible_meetings_for` scope for the `Meeting` model has been renamed to `visible_for` in [\#8748](https://github.com/decidim/decidim/pull/8748) for consistency.
- **decidim-core**: The `official_origin`, `participants_origin`, `user_group_origin` and `meeting_origin` scopes for the `Decidim::Authorable` and `Decidim::Coauthorable` concerns have been changed to `with_official_origin`, `with_participants_origin`, `with_user_group_origin` and `with_meeting_origin` respectively in [\#8748](https://github.com/decidim/decidim/pull/8748) for consistency. See the Searchlight removal change notes for reasoning.
- **decidim-core**: Nicknames are now differents case insensitively, a rake task has been created to check every nickname and modify them if some are similar (Launch it with "bundle exec rake decidim:upgrade:fix_nickname_uniqueness"). Routing and mentions has been made case insensitive for every tab in profiles.

### Detailed changes

#### Added

- **decidim-core**: Implement service workers and custom offline fallback page  [\#8594](https://github.com/decidim/decidim/pull/8594)
- **decidim-core**: Add emojis to Conversations [\#8735](https://github.com/decidim/decidim/pull/8735)
- **decidim-budgets**, **decidim-core**: Add reminders for pending orders in budgets [\#8621](https://github.com/decidim/decidim/pull/8621)
- **decidim-core**: Add favicon pwa uploader and icons in manifest [\#8645](https://github.com/decidim/decidim/pull/8645)
- **decidim-core**: Allow users to be searched by nickname [\#8663](https://github.com/decidim/decidim/pull/8663)
- **decidim-core**: Add items to set a splash screen [\#8649](https://github.com/decidim/decidim/pull/8649)
- **decidim-core**: Add VAPID keys' generator for webpush notifications  [\#8738](https://github.com/decidim/decidim/pull/8738)
- **decidim-core**: Add anchors on the homepage [\#8756](https://github.com/decidim/decidim/pull/8756)
- **decidim-admin**, **decidim-assemblies**, **decidim-participatory processes**:  Add a privacy warning on non-transparent private spaces  [\#8753](https://github.com/decidim/decidim/pull/8753)
- **decidim-core**: Show the Add2HomeScreen option in compatible browsers  [\#8736](https://github.com/decidim/decidim/pull/8736)
- **decidim-assemblies**: Allow assembly admins administer children assemblies [\#8773](https://github.com/decidim/decidim/pull/8773)
- **decidim-core**: Dynamic attachment uploads [\#8681](https://github.com/decidim/decidim/pull/8681)
- **decidim-participatory processes**: Create process types to allow filtering Processes by them [\#8583](https://github.com/decidim/decidim/pull/8583)
- **decidim-core**: Accessible character counter for screen readers [\#9009](https://github.com/decidim/decidim/pull/9009)
- **decidim-budgets**, **decidim-core**: Show users own voting activity [\#8914](https://github.com/decidim/decidim/pull/8914)
- **decidim-core**: Add autocomplete attribute to Devise fields [\#9038](https://github.com/decidim/decidim/pull/9038)
- **decidim-core**: Allow admins to disable email notifications for reported users [\#9072](https://github.com/decidim/decidim/pull/9072)
- **decidim-meetings**: Add reminders for publishing reports to meeting authors [\#8757](https://github.com/decidim/decidim/pull/8757)
- **decidim-meetings**: Export calendar improvements [\#9035](https://github.com/decidim/decidim/pull/9035)
- **decidim-core**: Remove all the private participants from a participatory space [\#8866](https://github.com/decidim/decidim/pull/8866)
- **decidim-core**: Performance: replace moment by dayjs [\#9161](https://github.com/decidim/decidim/pull/9161)
- **decidim-assemblies**, **decidim-conferences**, **decidim-core**, **decidim-meetings**, **decidim-participatory processes**: Homepage optimization: tune images' caches and query includes [\#9145](https://github.com/decidim/decidim/pull/9145)
- **decidim-accountability**, **decidim-assemblies**, **decidim-conferences**, **decidim-core**, **decidim-elections**, **decidim-meetings**, **decidim-proposals**: Cache highlighted resources for components cells [\#9143](https://github.com/decidim/decidim/pull/9143)
- **decidim-core**: Can resend and cancel email confirmation [\#8996](https://github.com/decidim/decidim/pull/8996)
- **decidim-core**: Performance optimization: load JavaScript at page's bottom [\#9156](https://github.com/decidim/decidim/pull/9156)
- **decidim-meetings**: Configure online meetings embedded services with ENV vars [\#9219](https://github.com/decidim/decidim/pull/9219)
- **decidim-elections**: Add an option to hide the "Can I vote?" page [\#9191](https://github.com/decidim/decidim/pull/9191)
- **decidim-core**: Add autocomplete in user account [\#9217](https://github.com/decidim/decidim/pull/9217)
- **decidim-budgets**: Bulk actions for budgeting projects in admin panel [\#8986](https://github.com/decidim/decidim/pull/8986)
- **decidim-comments**: Load comments with ajax [\#9144](https://github.com/decidim/decidim/pull/9144)
- **decidim-admin**, **decidim-participatory processes**: Add admin log when importing, exporting and duplicating a process [\#9244](https://github.com/decidim/decidim/pull/9244)
- **decidim-core**: Mail notifications digest [\#8833](https://github.com/decidim/decidim/pull/8833)
- **decidim-core**: Send push notifications to client [\#8774](https://github.com/decidim/decidim/pull/8774)
- **decidim-admin**, **decidim-core**: Add admin log when updating component or its permissions [\#9270](https://github.com/decidim/decidim/pull/9270)
- **decidim-admin**, **decidim-core**: Add admin log when creating, updating or deleting attachment collections [\#9276](https://github.com/decidim/decidim/pull/9276)
- **decidim-initiatives**: Add admin log when creating, updating or deleting initiative types [\#9310](https://github.com/decidim/decidim/pull/9310)
- **decidim-admin**: Add admin log when creating, updating or deleting scope types [\#9312](https://github.com/decidim/decidim/pull/9312)
- **decidim-accountability**: Add admin log when creating, updating or deleting accountability's status [\#9320](https://github.com/decidim/decidim/pull/9320)
- **decidim-admin**, **decidim-assemblies**: Add admin log when duplicating, exporting or importing assemblies [\#9338](https://github.com/decidim/decidim/pull/9338)
- **decidim-admin**: Add admin log when creating, updating or deleting area types [\#9316](https://github.com/decidim/decidim/pull/9316)
- **decidim-accountability**, **decidim-admin**: Add admin log when creating, updating or deleting accountability's timeline entries [\#9321](https://github.com/decidim/decidim/pull/9321)
- **decidim-admin**, **decidim-core**: Add admin log when creating, updating or deleting attachments [\#9282](https://github.com/decidim/decidim/pull/9282)
- **decidim-core**: Group creator can leave group [\#9315](https://github.com/decidim/decidim/pull/9315)
- **decidim-meetings**: Short URLs to fix long export calendar URLs [\#9383](https://github.com/decidim/decidim/pull/9383)
- **decidim-core**: Accept and reject cookies [\#9271](https://github.com/decidim/decidim/pull/9271)
- **decidim-admin**: Add admin log when creating, updating or deleting categories [\#9317](https://github.com/decidim/decidim/pull/9317)
- **decidim-admin**: Add admin log when updating external domains or help sections [\#9339](https://github.com/decidim/decidim/pull/9339)
- **decidim-templates**: Add admin log when creating, deleting, duplicating and updating templates [\#9363](https://github.com/decidim/decidim/pull/9363)
- **decidim-forms**: Add admin log when updating survey questionnaire [\#9385](https://github.com/decidim/decidim/pull/9385)
- **decidim-meetings**: Add admin log when updating the meeting questionnaire [\#9273](https://github.com/decidim/decidim/pull/9273)
- **decidim-admin**, **decidim-core**: Add admin log when exporting a component  [\#9390](https://github.com/decidim/decidim/pull/9390)
- **decidim-blogs**: Add admin log when creating, updating and deleting blog posts [\#9386](https://github.com/decidim/decidim/pull/9386)
- **decidim-comments**, **decidim-initiatives**: Add configuration option for initiative type to deactivate comments [\#9318](https://github.com/decidim/decidim/pull/9318)
- **decidim-initiatives**: Add order setting to initiatives [\#9377](https://github.com/decidim/decidim/pull/9377)
- **decidim-api**, **decidim-blogs**: Add official blog posts [\#9429](https://github.com/decidim/decidim/pull/9429)
- **decidim-core**: External link improvements [\#9402](https://github.com/decidim/decidim/pull/9402)
- **decidim-admin**, **decidim-core**: Strong passwords for admins [\#9347](https://github.com/decidim/decidim/pull/9347)
- **decidim-budgets**: Add geocoding to budgets projects [\#9280](https://github.com/decidim/decidim/pull/9280)

#### Changed

- **decidim-admin**: Change default sort order on admin moderations [\#8667](https://github.com/decidim/decidim/pull/8667)
- **decidim-debates**, **decidim-meetings**, **decidim-proposals**: Replace 'citizens' terminology with 'participants' [\#8697](https://github.com/decidim/decidim/pull/8697)
- **decidim-core**, **decidim-elections**, **decidim-initiatives**, **decidim-proposals**, **decidim-system**, **decidim-verifications**: Change to a inclusive language: replace he/she/his/her with they/their [\#8684](https://github.com/decidim/decidim/pull/8684)
- **decidim-generators**: Make Decidim fully configurable via ENV vars [\#8725](https://github.com/decidim/decidim/pull/8725)
- **decidim-core**: Replace Decidim mentions in UI with 'the platform' [\#8827](https://github.com/decidim/decidim/pull/8827)
- **decidim-admin**: Clarify the locales on the list of admins [\#8838](https://github.com/decidim/decidim/pull/8838)
- **decidim-core**: Display friendly report reason and details in moderation emails [\#8840](https://github.com/decidim/decidim/pull/8840)
- **decidim-comments**: Show hidden comments replies [\#8828](https://github.com/decidim/decidim/pull/8828)
- **decidim-generators**: Make Decidim fully configurable via ENV vars part II [\#8990](https://github.com/decidim/decidim/pull/8990)
- Reduce d3 bundle size [\#9034](https://github.com/decidim/decidim/pull/9034)
- **decidim-elections**: Add help text when verifying your vote [\#9190](https://github.com/decidim/decidim/pull/9190)
- **decidim-accountability**: Add timeline entry title in Accountability projects [\#9127](https://github.com/decidim/decidim/pull/9127)
- **decidim-core**: Rename data portability to download your data [\#9196](https://github.com/decidim/decidim/pull/9196)
- **decidim-elections**: Better wording when verifying an offline voter [\#9357](https://github.com/decidim/decidim/pull/9357)
- **decidim-initiatives**: Add signature collection period title in header [\#9314](https://github.com/decidim/decidim/pull/9314)

#### Fixed

- **decidim-admin**, **decidim-assemblies**, **decidim-budgets**, **decidim-conferences**, **decidim-consultations**, **decidim-core**, **decidim-elections**, **decidim-forms**, **decidim-initiatives**, **decidim-meetings**, **decidim-participatory processes**, **decidim-proposals**: Fix deprecation warnings from rails 6.1 update (#8610) [\#8610](https://github.com/decidim/decidim/pull/8610)
- **decidim-core**: Remove 'required field' explanation from conversation textearea [\#8701](https://github.com/decidim/decidim/pull/8701)
- **decidim-core**: Fix some non-localized user emails [\#8719](https://github.com/decidim/decidim/pull/8719)
- **decidim-meetings**: Fix for preview unpublished meetings by admin user [\#8713](https://github.com/decidim/decidim/pull/8713)
- **decidim-participatory processes**: Fix order by weight in processes groups' processes content block [\#8734](https://github.com/decidim/decidim/pull/8734)
- **decidim-admin**, **decidim-core**: Change scope picker button to disabled when necessary [\#8733](https://github.com/decidim/decidim/pull/8733)
- **decidim-comments**: Add emojis when user edits a comment [\#8731](https://github.com/decidim/decidim/pull/8731)
- **decidim-admin**, **decidim-meetings**, **decidim-proposals**: Fix reporting a proposal when author is a meeting [\#8737](https://github.com/decidim/decidim/pull/8737)
- **decidim-core**: Don't display blocked users in mentions [\#8687](https://github.com/decidim/decidim/pull/8687)
- **decidim-core**: Properly mark sender and recipient in Conversation [\#8742](https://github.com/decidim/decidim/pull/8742)
- **decidim-proposals**: Fix geocoding NaN values [\#8762](https://github.com/decidim/decidim/pull/8762)
- **decidim-core**: Add "nofollow noopener" rel to the profile personal URL [\#8779](https://github.com/decidim/decidim/pull/8779)
- **decidim-generators**: Add .keep file to empty directory to include on git committing [\#8786](https://github.com/decidim/decidim/pull/8786)
- **decidim-core**: Fix reminder manifest, replace virtus with attribute object [\#8785](https://github.com/decidim/decidim/pull/8785)
- **decidim-core**: Fix avatar upload validation errors are displayed twice [\#8794](https://github.com/decidim/decidim/pull/8794)
- **decidim-meetings**: Fix displaying hidden meetings in homepage's "upcoming meetings" content block [\#8809](https://github.com/decidim/decidim/pull/8809)
- **decidim-meetings**, **decidim-participatory processes**: Fix displaying hidden meetings in processes group's "upcoming meetings" content block [\#8818](https://github.com/decidim/decidim/pull/8818)
- **decidim-participatory processes**: Fix characters not encoded in highlighted participatory process group title [\#8820](https://github.com/decidim/decidim/pull/8820)
- **decidim-initiatives**: Fix scope validation on initiative's creation  [\#8755](https://github.com/decidim/decidim/pull/8755)
- **decidim-generators**: Add natively a .keep file to empty directory to include on git committing  [\#8830](https://github.com/decidim/decidim/pull/8830)
- **decidim-core**, **decidim-meetings**, **decidim-proposals**: Fix displaying hidden related resources [\#8812](https://github.com/decidim/decidim/pull/8812)
- **decidim-consultations**, **decidim-core**, **decidim-elections**: Fix report moderation for all the spaces [\#8813](https://github.com/decidim/decidim/pull/8813)
- **decidim-meetings**, **decidim-participatory processes**: Fix displaying hidden meetings in show process page [\#8823](https://github.com/decidim/decidim/pull/8823)
- **decidim-accountability**: Fix accountability text search [\#8831](https://github.com/decidim/decidim/pull/8831)
- **decidim-assemblies**, **decidim-conferences**, **decidim-consultations**, **decidim-proposals**: Fix notifications when there is a note proposal in other spaces than processes [\#8822](https://github.com/decidim/decidim/pull/8822)
- **decidim-core**: Fix activity cell disappearing author images [\#8826](https://github.com/decidim/decidim/pull/8826)
- **decidim-accountability**: Fix accountability categories' colors [\#8844](https://github.com/decidim/decidim/pull/8844)
- **decidim-meetings**: Fix displaying hidden resources in global search [\#8811](https://github.com/decidim/decidim/pull/8811)
- **decidim-assemblies**: Fix assemblies title when there are unpublished children [\#8855](https://github.com/decidim/decidim/pull/8855)
- **decidim-debates**: Remove actions from debates' cards [\#8854](https://github.com/decidim/decidim/pull/8854)
- **decidim-core**: Fix cache_hash generation in AuthorCell [\#8852](https://github.com/decidim/decidim/pull/8852)
- **decidim-proposals**: Fix answered proposals display [\#8851](https://github.com/decidim/decidim/pull/8851)
- **decidim-comments**: Show hidden comments replies [\#8828](https://github.com/decidim/decidim/pull/8828)
- **decidim-meetings**: Fix meetings iframe embed code  [\#8875](https://github.com/decidim/decidim/pull/8875)
- **decidim-core**: Fix the way the results are displayed in search page [\#8873](https://github.com/decidim/decidim/pull/8873)
- **decidim-meetings**: Fix display warning message in meetings [\#8872](https://github.com/decidim/decidim/pull/8872)
- **decidim-core**: Translate the remove recipient button correctly for new conversation [\#8894](https://github.com/decidim/decidim/pull/8894)
- **decidim-core**: Fix diff mode selector accessibility [\#8879](https://github.com/decidim/decidim/pull/8879)
- **decidim-core**: Add a unique title to the new group page [\#8882](https://github.com/decidim/decidim/pull/8882)
- **decidim-core**: Fix illogical heading order for the versions list [\#8880](https://github.com/decidim/decidim/pull/8880)
- **decidim-core**: Improve logo link aria label [\#8878](https://github.com/decidim/decidim/pull/8878)
- **decidim-core**: Add the "choose language" string in all locales to the language chooser [\#8883](https://github.com/decidim/decidim/pull/8883)
- **decidim-core**: Change the correct element type for the change password button [\#8890](https://github.com/decidim/decidim/pull/8890)
- **decidim-budgets**: Fix duplicate ID on the budgets index page [\#8908](https://github.com/decidim/decidim/pull/8908)
- **decidim-core**: Fix accessibility issue related to the documents collection toggle [\#8907](https://github.com/decidim/decidim/pull/8907)
- **decidim-participatory processes**: Fix heading order in the process steps page [\#8906](https://github.com/decidim/decidim/pull/8906)
- **decidim-elections**: Fix illogical heading orders in the elections component [\#8905](https://github.com/decidim/decidim/pull/8905)
- **decidim-forms**: Fix the form questionnaires heading orders [\#8903](https://github.com/decidim/decidim/pull/8903)
- **decidim-budgets**: Fix the illogical heading orders with the budget component views [\#8904](https://github.com/decidim/decidim/pull/8904)
- **decidim-core**: Fix the component index views heading order for the subtitle change [\#8902](https://github.com/decidim/decidim/pull/8902)
- **decidim-comments**: Fix comments heading order [\#8876](https://github.com/decidim/decidim/pull/8876)
- **decidim-proposals**: Fix display withdraw warning message in proposals [\#8870](https://github.com/decidim/decidim/pull/8870)
- **decidim-core**: Make the button link font weight consistent with normal links [\#8891](https://github.com/decidim/decidim/pull/8891)
- **decidim-proposals**: Fix illogical heading order for a single proposal [\#8877](https://github.com/decidim/decidim/pull/8877)
- **decidim-core**: Fix the HTML diff mode accessibility [\#8915](https://github.com/decidim/decidim/pull/8915)
- **decidim-assemblies**, **decidim-core**, **decidim-initiatives**, **decidim-participatory processes**: Change the participatory space header's subtitle element to a `<p>` to fix heading order issues [\#8901](https://github.com/decidim/decidim/pull/8901)
- **decidim-comments**: Fix Foundation Abide errors for Rails remote (AJAX) forms [\#8889](https://github.com/decidim/decidim/pull/8889)
- **decidim-core**: Fix logical heading order for the endorsers list [\#8892](https://github.com/decidim/decidim/pull/8892)
- **decidim-comments**, **decidim-core**: Fix emoji picker hiding Foundation Abide form errors [\#8886](https://github.com/decidim/decidim/pull/8886)
- **decidim-comments**: Fix budget hard dependency and caching flag issues in comments  [\#8899](https://github.com/decidim/decidim/pull/8899)
- **decidim-core**: Fix diff mode selector roles and tabindexes [\#8912](https://github.com/decidim/decidim/pull/8912)
- **decidim-consultations**: Fix heading order in the consultation question page [\#8920](https://github.com/decidim/decidim/pull/8920)
- **decidim-meetings**: Fix the meetings export to also include unpublished meetings [\#8874](https://github.com/decidim/decidim/pull/8874)
- **decidim-initiatives**: Fix initiatives signatures issues [\#8448](https://github.com/decidim/decidim/pull/8448)
- **decidim-initiatives**: Fix link to docs in initiatives admin [\#8921](https://github.com/decidim/decidim/pull/8921)
- **decidim-core**: Fix translatable presence validator for hyphenated locales [\#8795](https://github.com/decidim/decidim/pull/8795)
- **decidim-participatory processes**: Fix processes creation form with stats, metrics and announcements [\#8925](https://github.com/decidim/decidim/pull/8925)
- **decidim-system**, **decidim-verifications**: Fix verification report with multitenants: notify it only to admins of that organization [\#8929](https://github.com/decidim/decidim/pull/8929)
- **decidim-core**: Fix officialized user event missing translations [\#8927](https://github.com/decidim/decidim/pull/8927)
- **decidim-verifications**: Fix email for verification conflict with managed users [\#8926](https://github.com/decidim/decidim/pull/8926)
- **decidim-core**: Fix profile notifications [\#8943](https://github.com/decidim/decidim/pull/8943)
- **decidim-elections**: Add a subtitle to votings page [\#8919](https://github.com/decidim/decidim/pull/8919)
- **decidim-assemblies**, **decidim-participatory processes**: Add a subtitle to assemblies and processes pages [\#8918](https://github.com/decidim/decidim/pull/8918)
- **decidim-meetings**: Truncate the meetings card description [\#8954](https://github.com/decidim/decidim/pull/8954)
- **decidim-proposals**: Fix proposals' cards with big images [\#8952](https://github.com/decidim/decidim/pull/8952)
- **decidim-core**: Add missing reveal__title classes [\#8958](https://github.com/decidim/decidim/pull/8958)
- **decidim-core**: Fix multiple mentions correct focus on element (recipient) removal [\#8959](https://github.com/decidim/decidim/pull/8959)
- **decidim-core**: Add missing 'Locale' string in i18n in account page [\#8969](https://github.com/decidim/decidim/pull/8969)
- **decidim-core**: Fix main navigation aria-current attribute [\#8968](https://github.com/decidim/decidim/pull/8968)
- **decidim-core**: Fix mobile nav keyboard focus [\#8962](https://github.com/decidim/decidim/pull/8962)
- **decidim-core**: Remove the label from the dropdown menu opener [\#8972](https://github.com/decidim/decidim/pull/8972)
- **decidim-blogs**, **decidim-core**, **decidim-debates**, **decidim-proposals**: Fix for endorsed_by with other user group's member [\#8967](https://github.com/decidim/decidim/pull/8967)
- **decidim-proposals**: Fix footer actions caching on proposals' card [\#8987](https://github.com/decidim/decidim/pull/8987)
- **decidim-initiatives**: Show signatures in answered initiatives [\#8747](https://github.com/decidim/decidim/pull/8747)
- **decidim-api**, **decidim-meetings**, **decidim-proposals**: Fix API when meetings have proposal linking disabled [\#8971](https://github.com/decidim/decidim/pull/8971)
- **decidim-meetings**, **decidim-proposals**: Fix proposals seeds after reordering of modules loading [\#8993](https://github.com/decidim/decidim/pull/8993)
- **decidim-core**: Show character counter when replying to message [\#8922](https://github.com/decidim/decidim/pull/8922)
- **decidim-core**: Fix character counter with emoji picker close to maximum characters [\#8916](https://github.com/decidim/decidim/pull/8916)
- **decidim-budgets**, **decidim-core**, **decidim-debates**, **decidim-meetings**, **decidim-proposals**: Fix cache URLs on cards [\#8988](https://github.com/decidim/decidim/pull/8988)
- **decidim-core**: Fix submit form with enter when there are attachments [\#9019](https://github.com/decidim/decidim/pull/9019)
- **decidim-core**: Fix Devise flash messages translation [\#9025](https://github.com/decidim/decidim/pull/9025)
- **decidim-admin**: Add missing 'Locale' string in i18n in selective newsletter [\#9037](https://github.com/decidim/decidim/pull/9037)
- **decidim-core**: Disable new conversation next button when no users selected [\#9024](https://github.com/decidim/decidim/pull/9024)
- **decidim-core**: Fix social share button sharing (`Can't find variable: SocialShareButton` console error) [\#9041](https://github.com/decidim/decidim/pull/9041)
- **decidim-meetings**: Use published meetings scope on processes landing and proposal's form [\#9023](https://github.com/decidim/decidim/pull/9023)
- **decidim-core**: Require omniauth/rails_csrf_protection explicitly [\#9053](https://github.com/decidim/decidim/pull/9053)
- **decidim-core**: Fix session cookie SameSite policy [\#9051](https://github.com/decidim/decidim/pull/9051)
- **decidim-conferences**: Fix conference partner logo is not optional on create [\#9045](https://github.com/decidim/decidim/pull/9045)
- **decidim-comments**, **decidim-core**, **decidim-proposals**: Add noreferrer and ugc to links [\#9047](https://github.com/decidim/decidim/pull/9047)
- **decidim-proposals**: Create admin log records when proposals are imported from a file [\#9006](https://github.com/decidim/decidim/pull/9006)
- **decidim-meetings**: Remove presenters in the meetings admin backoffice [\#9052](https://github.com/decidim/decidim/pull/9052)
- **decidim-meetings**: Fix submit in meetings admin form [\#9061](https://github.com/decidim/decidim/pull/9061)
- **decidim-core**, **decidim-proposals**: Fix amendable events title [\#9050](https://github.com/decidim/decidim/pull/9050)
- **decidim-assemblies**, **decidim-conferences**, **decidim-consultations**, **decidim-core**, **decidim-initiatives**, **decidim-participatory processes**: Fix Twitter hashtag search when it starts with a number [\#9039](https://github.com/decidim/decidim/pull/9039)
- **decidim-initiatives**: Remove 'edit link' in topbar for initiative's authors [\#8997](https://github.com/decidim/decidim/pull/8997)
- **decidim-comments**, **decidim-core**, **decidim-meetings**: Fix timeout in comment view and during meetings [\#9070](https://github.com/decidim/decidim/pull/9070)
- **decidim-core**: Dont add external link container inside editor [\#9095](https://github.com/decidim/decidim/pull/9095)
- **decidim-core**, **decidim-dev**: VAPID key generator availabe in core [\#9107](https://github.com/decidim/decidim/pull/9107)
- **decidim-assemblies**: Allow assembly admins to manage components in child assemblies [\#8955](https://github.com/decidim/decidim/pull/8955)
- **decidim-core**: Add base URI to meta image URLs [\#9125](https://github.com/decidim/decidim/pull/9125)
- **decidim-elections**: Clarify message to user when checking census [\#9112](https://github.com/decidim/decidim/pull/9112)
- **decidim-elections**: Fix attachments when called from Cells [\#9136](https://github.com/decidim/decidim/pull/9136)
- **decidim-participatory processes**: Fix processes count in processes group title cell [\#9087](https://github.com/decidim/decidim/pull/9087)
- **decidim-meetings**: Do not send upcoming meeting notification for hidden or withdrawn meetings [\#9134](https://github.com/decidim/decidim/pull/9134)
- **decidim-elections**: Improve wording when casting your vote [\#9098](https://github.com/decidim/decidim/pull/9098)
- **decidim-core**: Prevent race condition between prevenTimeout and show modal [\#9092](https://github.com/decidim/decidim/pull/9092)
- **decidim-generators**: Fix app generator when creating a development_app [\#9142](https://github.com/decidim/decidim/pull/9142)
- **decidim-meetings**: Fix meetings minutes migration [\#9148](https://github.com/decidim/decidim/pull/9148)
- **decidim-core**: Enforce password validation rules on 'Forgot your password?' form [\#9090](https://github.com/decidim/decidim/pull/9090)
- **decidim-proposals**: Add 'not answered' as a possible answer in proposals [\#9021](https://github.com/decidim/decidim/pull/9021)
- **decidim-budgets**: Fix vote reminder email urls [\#9152](https://github.com/decidim/decidim/pull/9152)
- **decidim-meetings**: Move modal to body and fix condition [\#9158](https://github.com/decidim/decidim/pull/9158)
- **decidim-assemblies**, **decidim-proposals**: Fix absolute urls on 'create assembly member' and proposals' 'collaborative drafts' events [\#9146](https://github.com/decidim/decidim/pull/9146)
- **decidim-accountability**, **decidim-consultations**: Fix components navbar in consultations mobile  [\#9155](https://github.com/decidim/decidim/pull/9155)
- **decidim-core**: Show only current organization in verification conflicts with multitenants [\#9033](https://github.com/decidim/decidim/pull/9033)
- **decidim-elections**: Send email to newly added trustees [\#9100](https://github.com/decidim/decidim/pull/9100)
- **decidim-meetings**: Fix registration type field highlighted in admin meeting creation form [\#9160](https://github.com/decidim/decidim/pull/9160)
- **decidim-core**: Fix displaying blocked users in account follow pages [\#9164](https://github.com/decidim/decidim/pull/9164)
- **decidim-core**: Separate validation messages for image dimensions and size [\#9165](https://github.com/decidim/decidim/pull/9165)
- **decidim-core**: Fix notifications where resources are missing [\#9183](https://github.com/decidim/decidim/pull/9183)
- **decidim-core**: Fix encoding organization name in A2HS [\#9184](https://github.com/decidim/decidim/pull/9184)
- **decidim-surveys**: Fix contradictory form errors on survey form [\#9186](https://github.com/decidim/decidim/pull/9186)
- **decidim-admin**, **decidim-elections**: Fix newsletters and Decidim Votings [\#9188](https://github.com/decidim/decidim/pull/9188)
- **decidim-meetings**: Fix typo in meeting's copy calendar string [\#9193](https://github.com/decidim/decidim/pull/9193)
- **decidim-initiatives**: Fix typo and improves copy in initiatives admin [\#9194](https://github.com/decidim/decidim/pull/9194)
- **decidim-system**: Enforce password validation rules on system admins [\#9207](https://github.com/decidim/decidim/pull/9207)
- **decidim-initiatives**: Add edit and delete actions in InitiativeType admin table [\#9151](https://github.com/decidim/decidim/pull/9151)
- **decidim-surveys**: Clarify unregistered answers on surveys behavior [\#9205](https://github.com/decidim/decidim/pull/9205)
- **decidim-elections**: Fix voting with single election [\#9097](https://github.com/decidim/decidim/pull/9097)
- **decidim-admin**: Fix invalid translation call [\#9218](https://github.com/decidim/decidim/pull/9218)
- **decidim-initiatives**: Fix initiative print link, margin, and organization logo [\#9162](https://github.com/decidim/decidim/pull/9162)
- **decidim-elections**: Fix election label translations [\#9102](https://github.com/decidim/decidim/pull/9102)
- **decidim-elections**: Remove show more button on elections [\#9103](https://github.com/decidim/decidim/pull/9103)
- **decidim-surveys**: Fix survey activity log entries [\#9173](https://github.com/decidim/decidim/pull/9173)
- **decidim-core**: Fix dynamic validation and title change for titled attachments [\#9175](https://github.com/decidim/decidim/pull/9175)
- **decidim-budgets**: Remove beforeunload confirmation panel from the budgets voting [\#9224](https://github.com/decidim/decidim/pull/9224)
- **decidim-core**: Fix nicknames uniqueness with different cases [\#8792](https://github.com/decidim/decidim/pull/8792)
- **decidim-core**: Fix Leaflet trying to load "infinite amount of tiles" [\#9233](https://github.com/decidim/decidim/pull/9233)
- **decidim-verifications**: Allow to renew expired verifications (if renewable) [\#8192](https://github.com/decidim/decidim/pull/8192)
- **decidim-elections**: Correctly show trustees and votings menu [\#9192](https://github.com/decidim/decidim/pull/9192)
- **decidim-core**: Fix hashtag parsing on URLs with fragments [\#9221](https://github.com/decidim/decidim/pull/9221)
- **decidim-comments**, **decidim-core**: Add missing events locales [\#9199](https://github.com/decidim/decidim/pull/9199)
- **decidim-conferences**: Make conference's partners logos always mandatory [\#9214](https://github.com/decidim/decidim/pull/9214)
- **decidim-admin**: Fix margin around warning message in colour settings [\#9278](https://github.com/decidim/decidim/pull/9278)
- **decidim-comments**, **decidim-core**: Don't show deleted resources in last activities  [\#9293](https://github.com/decidim/decidim/pull/9293)
- **decidim-elections**: Hide more information link when there's no description on an election [\#9099](https://github.com/decidim/decidim/pull/9099)
- **decidim-admin**: Fix local storage protocol options for uploaders [\#9285](https://github.com/decidim/decidim/pull/9285)
- **decidim-admin**, **decidim-assemblies**, **decidim-budgets**, **decidim-core**, **decidim-elections**, **decidim-meetings**, **decidim-pages**, **decidim-proposals**: Apply crowdin feedback [\#9301](https://github.com/decidim/decidim/pull/9301)
- **decidim-participatory processes**: Update file validation for process import [\#9236](https://github.com/decidim/decidim/pull/9236)
- **decidim-core**: Fix user interests [\#9225](https://github.com/decidim/decidim/pull/9225)
- **decidim-elections**: Add error message when adding question and election has started [\#9189](https://github.com/decidim/decidim/pull/9189)
- **decidim-elections**: Fix HTML safe content in election voting [\#9210](https://github.com/decidim/decidim/pull/9210)
- **decidim-elections**: Fix ActionLog when a ballot style is deleted [\#9355](https://github.com/decidim/decidim/pull/9355)
- **decidim-elections**: Enforce YYYYmmdd format in birthdate when uploading census [\#9354](https://github.com/decidim/decidim/pull/9354)
- **decidim-elections**: Only show that the code can be requested via SMS if its true [\#9353](https://github.com/decidim/decidim/pull/9353)
- **decidim-meetings**: Short URLs to fix long export calendar URLs [\#9383](https://github.com/decidim/decidim/pull/9383)
- **decidim-core**: Fix for internal links not displaying on page title [\#9228](https://github.com/decidim/decidim/pull/9228)
- **decidim-elections**: Fix regular expression on census check [\#9352](https://github.com/decidim/decidim/pull/9352)
- **decidim-budgets**, **decidim-proposals**: Add missing translation keys proposals import and proposals picker [\#9359](https://github.com/decidim/decidim/pull/9359)
- **decidim-consultations**: Return 404 when there isn't a consultation [\#9374](https://github.com/decidim/decidim/pull/9374)
- **decidim-consultations**: Return 404 when there isn't a question [\#9375](https://github.com/decidim/decidim/pull/9375)
- **decidim-elections**: Return 404 when there isn't a voting in elections_log [\#9376](https://github.com/decidim/decidim/pull/9376)
- **decidim-proposals**: Fix proposals creation with Participatory Texts  [\#9381](https://github.com/decidim/decidim/pull/9381)
- **decidim-forms**, **decidim-meetings**, **decidim-surveys**: Fix rollback questionnaire answer when file is invalid [\#9361](https://github.com/decidim/decidim/pull/9361)
- **decidim-core**: Create tempfile when Active Storage service doesn't implement path_for method [\#9362](https://github.com/decidim/decidim/pull/9362)
- **decidim-core**: Fix / Expose createMapController properly to let overriding [\#9425](https://github.com/decidim/decidim/pull/9425)
- **decidim-elections**: Capture unhandled errors from JS promises and inform the user [\#9430](https://github.com/decidim/decidim/pull/9430)
- **decidim-elections**: Make sure component is published when starting an election [\#9358](https://github.com/decidim/decidim/pull/9358)
- **decidim-elections**: Remove description from questions in elections [\#9401](https://github.com/decidim/decidim/pull/9401)
- **decidim-initiatives**: Return 404 when there isn't an initiative [\#9427](https://github.com/decidim/decidim/pull/9427)
- **decidim-core**, **decidim-meetings**, **decidim-proposals**: Fix email subject when resource title has special characters [\#9392](https://github.com/decidim/decidim/pull/9392)
- **decidim-core**, **decidim-generators**: Fix service worker cache in development environment [\#9424](https://github.com/decidim/decidim/pull/9424)
- **decidim-core**: Prevent users to validate nicknames/emails taken by user groups (#9452) [\#9452](https://github.com/decidim/decidim/pull/9452)
- **decidim-elections**: Fix hardcoded hour in election dashboard (#9465) [\#9465](https://github.com/decidim/decidim/pull/9465)

#### Removed

- **decidim-meetings**: Clean meetings form with registrations [\#8500](https://github.com/decidim/decidim/pull/8500)
- **decidim-core**: Remove 'required field' explanation from conversation textearea [\#8701](https://github.com/decidim/decidim/pull/8701)
- **decidim-admin**, **decidim-assemblies**, **decidim-conferences**, **decidim-participatory processes**: Remove category description [\#8617](https://github.com/decidim/decidim/pull/8617)
- **decidim-core**: The `rectify` gem has been removed from the stack as of [\#9101](https://github.com/decidim/decidim/pull/9101). If you are a library developer, replace any `Rectify::Query` with `Decidim::Query`, replace any `Rectify::Command` with `Decidim::Command`. Replace any `Rectify::Presenter` with `SimpleDelegator` (Already deprecated in [\#8758](https://github.com/decidim/decidim/pull/8758))
- **decidim-core**: The `searchlight` gem has been removed in favor of Ransach as of [\#8748](https://github.com/decidim/decidim/pull/8748). Please review the **Changed** notes regarding the required changes. Please review all your search classes that were inheriting from `Searchlight::Search`. You should migrate your search filtering to Ransack.
- **decidim-core**: The `search_params` and `default_search_params` methods within the participant-facing controllers are now removed in favor of using `filter_params` and `default_filter_params` as of [\#8748](https://github.com/decidim/decidim/pull/8748). The duplicate methods were redundant after the Ransack migration which is why they were removed. In case you had overridden these methods in your controllers, they no longer do anything. In case you were calling these methods before, you will now receive a `NoMethodError` because they are removed. Please use `filter_params` and `default_filter_params` instead.
- **decidim-accountability**, **decidim-assemblies**, **decidim-budgets**, **decidim-consultations**, **decidim-core**, **decidim-elections**, **decidim-initiatives**, **decidim-participatory_processes**, **decidim-proposals**, **decidim-sortitions**: The search service classes inheriting from `Searchlight::Search` that are no longer necessary due to the Ransack migration have been removed in all modules as of [\#8748](https://github.com/decidim/decidim/pull/8748). This includes `Decidim::Accountability::ResultSearch`, `Decidim::Assemblies::AssemblySearch`, `Decidim::Budgets::ProjectSearch`, `Decidim::Consultations::ConsultationSearch`, `Decidim::HomeActivitySearch`, `Decidim::ParticipatorySpaceSearch`, `Decidim::Elections::ElectionsSearch`, `Decidim::Votings::VotingSearch`, `Decidim::Meetings::Directory::MeetingSearch`, `Decidim::ParticipatoryProcesses::ParticipatoryProcessesSearch`, `Decidim::Proposals::CollaborativeDraftSearch`, `Decidim::Proposals::ProposalSearch` and `Decidim::Sortitions::SortitionSearch`.

#### Developer improvements

- Replace graphql-docs npm package with gem  [\#8631](https://github.com/decidim/decidim/pull/8631)
- Migrate from `Virtus` to `ActiveModel::Attributes` (and get rid of `Rectify::Form`) [\#8669](https://github.com/decidim/decidim/pull/8669)
- Replace various autocomplete solutions [\#8524](https://github.com/decidim/decidim/pull/8524)
- Fix webpacker generator for modules [\#8715](https://github.com/decidim/decidim/pull/8715)
- Add parallel_tests for test suite in CI [\#8678](https://github.com/decidim/decidim/pull/8678)
- Replace `searchlight` with `ransack` which is already a core dependency [\#8748](https://github.com/decidim/decidim/pull/8748)
- Update docs in Webpacker app migration [\#8881](https://github.com/decidim/decidim/pull/8881)
- Move VAPID keys generators to core [\#8923](https://github.com/decidim/decidim/pull/8923)
- Update docs in Webpacker app migration (part II) [\#8911](https://github.com/decidim/decidim/pull/8911)
- Fix Devise configs that depend on Decidim configs [\#9014](https://github.com/decidim/decidim/pull/9014)
- Update rails to 6.1 [\#8411](https://github.com/decidim/decidim/pull/8411)
- Add useful error for custom-authorizations development [\#8834](https://github.com/decidim/decidim/pull/8834)
- Prevent Faker Address country_code from raising RetryLimitExceeded [\#9036](https://github.com/decidim/decidim/pull/9036)
- Fix Spring errors with Rails 6.1 [\#9032](https://github.com/decidim/decidim/pull/9032)
- Disable webpack-dev-server overlay [\#9082](https://github.com/decidim/decidim/pull/9082)
- Make frontend development 10-12x faster (compile SCSS through sass-embedded) [\#9081](https://github.com/decidim/decidim/pull/9081)
- Fix webpacker configuration when sass-loader is not available [\#9149](https://github.com/decidim/decidim/pull/9149)
- Remove Rectify Gem dependency [\#9101](https://github.com/decidim/decidim/pull/9101)
- Fix webpacker thread safety [\#9203](https://github.com/decidim/decidim/pull/9203)
- Fix budget amounts in project seeds [\#9174](https://github.com/decidim/decidim/pull/9174)
- Update ruby to 3.0 [\#8452](https://github.com/decidim/decidim/pull/8452)
- Remove unused helper method from UserInterestsController [\#9237](https://github.com/decidim/decidim/pull/9237)
- Light refactor for fetching admins [\#9287](https://github.com/decidim/decidim/pull/9287)
- Fix local storage protocol options for uploaders [\#9285](https://github.com/decidim/decidim/pull/9285)
- Add empty database (aka no seed) installation manual [\#9349](https://github.com/decidim/decidim/pull/9349)
- Bump letter_opener_web from 1.3 to 2.0 [\#9395](https://github.com/decidim/decidim/pull/9395)
- Change docs to use decidim_system:create_admin command [\#9372](https://github.com/decidim/decidim/pull/9372)
- Add documentation for logic customization [\#9325](https://github.com/decidim/decidim/pull/9325)
- External link improvements [\#9402](https://github.com/decidim/decidim/pull/9402)
- Improve asset routing logic [\#9403](https://github.com/decidim/decidim/pull/9403)
- Remove the threads limit from the Capybara Puma server [\#9422](https://github.com/decidim/decidim/pull/9422)

## Previous versions

Please check [release/0.26-stable](https://github.com/decidim/decidim/blob/release/0.26-stable/CHANGELOG.md) for previous changes.
