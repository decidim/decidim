# Changelog

## [0.31.4](https://github.com/decidim/decidim/tree/0.31.4)

### Added

Nothing.

### Changed

Nothing.

### Fixed

- **decidim-admin**: Backport 'Do not send notifications in unpublished posts' attachments' to v0.31 [\#16497](https://github.com/decidim/decidim/pull/16497)
- **decidim-accountability**: Backport 'Fix images in milestones' to v0.31 [\#16502](https://github.com/decidim/decidim/pull/16502)
- **decidim-assemblies**, **decidim-initiatives**, **decidim-participatory processes**, **decidim-surveys**: Backport 'Add screen reader indicators (live and atomic) to spaces counters' to v0.31 [\#16510](https://github.com/decidim/decidim/pull/16510)
- **decidim-system**: Backport 'Add validations to the host format at system panel' to v0.31 [\#16506](https://github.com/decidim/decidim/pull/16506)
- Backport 'Take into account the modules that actually have code during release' to v0.31 [\#16549](https://github.com/decidim/decidim/pull/16549)
- **decidim-core**: Backport 'Remove the roles menu on tabbed partial' to v0.31 [\#16562](https://github.com/decidim/decidim/pull/16562)
- **decidim-core**, **decidim-proposals**: Backport 'Improve accessibility on new registration form: email and ToS fields' to v0.31 [\#16556](https://github.com/decidim/decidim/pull/16556)
- **decidim-blogs**, **decidim-core**: Backport 'Fix display of embeded images in notification emails' to v0.31 [\#16559](https://github.com/decidim/decidim/pull/16559)
- **decidim-assemblies**, **decidim-core**: Backport 'Fix links to members profiles page' to v0.31 [\#16572](https://github.com/decidim/decidim/pull/16572)
- **decidim-core**: Backport 'Fix images in editors with strange characters' to v0.31 [\#16570](https://github.com/decidim/decidim/pull/16570)
- **decidim-blogs**, **decidim-debates**, **decidim-initiatives**, **decidim-meetings**, **decidim-proposals**: Backport 'Fix disabled data attribute in submit buttons' to v0.31 [\#16573](https://github.com/decidim/decidim/pull/16573)
- **decidim-meetings**: Backport 'Fix the "Attending organizations" container in meetings' to v0.31 [\#16604](https://github.com/decidim/decidim/pull/16604)
- **decidim-proposals**: Backport 'Fix icon for disabled delete in proposals states' to v0.31 [\#16611](https://github.com/decidim/decidim/pull/16611)
- **decidim-blogs**, **decidim-core**, **decidim-debates**, **decidim-initiatives**, **decidim-meetings**, **decidim-proposals**: Backport 'Fix anouncement form error for screen readers' to v0.31 [\#16606](https://github.com/decidim/decidim/pull/16606)
- **decidim-core**: Backport 'Remove the roles menu on filters' to v0.31 [\#16621](https://github.com/decidim/decidim/pull/16621)
- **decidim-budgets**, **decidim-proposals**: Backport 'Show only component specific states in proposals to projects import' to v0.31 [\#16618](https://github.com/decidim/decidim/pull/16618)
- **decidim-generators**: Backport 'Fix the "SMTP_STARTTLS_AUTO" env var in `production.rb`' to v0.31 [\#16615](https://github.com/decidim/decidim/pull/16615)
- **decidim-core**: Backport 'Remove the roles menu on footer' to v0.31 [\#16622](https://github.com/decidim/decidim/pull/16622)
- **decidim-core**, **decidim-participatory processes**: Backport 'Remove the roles menu on spaces nav links' to v0.31 [\#16624](https://github.com/decidim/decidim/pull/16624)
- **decidim-design**: Backport 'Fix decidim-design section by removing MeetingsSCell call' to v0.31 [\#16629](https://github.com/decidim/decidim/pull/16629)
- Backport 'Lock webpack to v5.105' to v0.31 [\#16632](https://github.com/decidim/decidim/pull/16632)
- **decidim-core**: Backport 'Allow adding links in images using the WYSIWYG editor' to v0.31 [\#16633](https://github.com/decidim/decidim/pull/16633)
- **decidim-core**: Backport 'Allow overriding the role attribute on accordions' to v0.31 [\#16631](https://github.com/decidim/decidim/pull/16631)

### Removed

Nothing.

### Developer improvements

Nothing.

### Internal

- Clean-up the releases notes for v0.31 branch [\#16564](https://github.com/decidim/decidim/pull/16564)
- **decidim-conferences**: New Crowdin updates [\#16579](https://github.com/decidim/decidim/pull/16579)

## [0.31.3](https://github.com/decidim/decidim/tree/0.31.3)

### Added

Nothing.

### Changed

- **decidim-core**, **decidim-proposals**: Backport 'Show only component specific states in proposal to proposal import' to v0.31 [\#16403](https://github.com/decidim/decidim/pull/16403)

### Fixed

- **decidim-budgets**: Backport 'Fix ux resolve encoding issues in the admin budget title' to v0.31 [\#16231](https://github.com/decidim/decidim/pull/16231)
- **decidim-admin**, **decidim-core**: Backport 'Fix password help text for admins and users' to v0.31 [\#16224](https://github.com/decidim/decidim/pull/16224)
- **decidim-admin**, **decidim-core**: Backport 'Fix error state is not visible when translation is missing' to v0.31 [\#16229](https://github.com/decidim/decidim/pull/16229)
- **decidim-admin**: Backport 'Fix long names and components counter in admin' to v0.31 [\#16252](https://github.com/decidim/decidim/pull/16252)
- **decidim-budgets**: Backport 'Add a validation and increase the amounts for budgets' to v0.31 [\#16262](https://github.com/decidim/decidim/pull/16262)
- **decidim-forms**, **decidim-surveys**: Backport 'Fix count of valid questions types in survey' to v0.31 [\#16267](https://github.com/decidim/decidim/pull/16267)
- **decidim-forms**: Backport 'Remove 'free text' option from sorting questions' responses options' to v0.31 [\#16268](https://github.com/decidim/decidim/pull/16268)
- **decidim-assemblies**, **decidim-participatory processes**: Backport 'Fix importing attachments within processes/assemblies' to v0.31 [\#16278](https://github.com/decidim/decidim/pull/16278)
- **decidim-core**, **decidim-elections**, **decidim-forms**, **decidim-meetings**: Backport 'Avoid removing questions with "enter" key in surveys' admin' to v0.31 [\#16283](https://github.com/decidim/decidim/pull/16283)
- **decidim-meetings**: Backport 'Fix for editing a meeting page from related process' to v0.31 [\#16305](https://github.com/decidim/decidim/pull/16305)
- **decidim-assemblies**: Backport 'Fix grandchildren navigation in assemblies' to v0.31 [\#16311](https://github.com/decidim/decidim/pull/16311)
- **decidim-meetings**: Backport 'Remove calendar from highlighted meetings content block' to v0.31 [\#16312](https://github.com/decidim/decidim/pull/16312)
- **decidim-core**, **decidim-meetings**: Backport 'Fix showing end dates when meetings have multiple dates' to v0.31 [\#16314](https://github.com/decidim/decidim/pull/16314)
- **decidim-conferences**: Backport 'Add action log for conferences' duplicate action' to v0.31 [\#16331](https://github.com/decidim/decidim/pull/16331)
- **decidim-core**: Backport 'Fix focus guard related bugs' to v0.31 [\#16318](https://github.com/decidim/decidim/pull/16318)
- **decidim-core**, **decidim-meetings**: Backport 'Show spaces names in meetings outside of its space' to v0.31 [\#16347](https://github.com/decidim/decidim/pull/16347)
- **decidim-initiatives**: Backport 'Show or not initiatives components menu depending on state' to v0.31 [\#16350](https://github.com/decidim/decidim/pull/16350)
- **decidim-forms**, **decidim-surveys**: Backport 'Fix for sorting newly added questions' to v0.31 [\#16352](https://github.com/decidim/decidim/pull/16352)
- **decidim-meetings**: Backport 'Show agenda before the tab panels in meetings' to v0.31 [\#16362](https://github.com/decidim/decidim/pull/16362)
- **decidim-forms**: Backport 'Remove automatic numbering of questions in the frontend' to v0.31 [\#16372](https://github.com/decidim/decidim/pull/16372)
- **decidim-accountability**, **decidim-blogs**, **decidim-budgets**, **decidim-collaborative_texts**, **decidim-core**, **decidim-debates**, **decidim-dev**, **decidim-elections**, **decidim-meetings**, **decidim-pages**, **decidim-proposals**, **decidim-surveys**: Backport 'Fix search indexing rules on component publication' to v0.31 [\#16379](https://github.com/decidim/decidim/pull/16379)
- **decidim-core**, **decidim-proposals**: Backport 'Show only component specific states in proposal to proposal import' to v0.31 [\#16403](https://github.com/decidim/decidim/pull/16403)
- **decidim-core**, **decidim-proposals**: Backport 'Fix edit proposal with attachment' to v0.31 [\#16386](https://github.com/decidim/decidim/pull/16386)
- **decidim-admin**: Backport 'Fix entire duplicate page appears when adding a filter to a debate' to v0.31 [\#16417](https://github.com/decidim/decidim/pull/16417)
- **decidim-core**: Backport 'Prevent taxonomy importer from removing custom component settings' to v0.31 [\#16423](https://github.com/decidim/decidim/pull/16423)
- **decidim-admin**, **decidim-elections**, **decidim-forms**, **decidim-participatory processes**: Backport 'Fix cursor for hover and icon for draggable' to v0.31 [\#16427](https://github.com/decidim/decidim/pull/16427)
- **decidim-admin**: Backport 'Fix component settings disabled when it is readonly' to v0.31 [\#16430](https://github.com/decidim/decidim/pull/16430)
- **decidim-budgets**: Backport 'Fix budgets list still displayed empty after voting on all budgets' to v0.31 [\#16431](https://github.com/decidim/decidim/pull/16431)
- **decidim-core**, **decidim-meetings**: Backport 'Prevent infinite loops on FindAndUpdateDescendantsJob' to v0.31 [\#16434](https://github.com/decidim/decidim/pull/16434)
- **decidim-admin**: Backport 'Fix flaky spec on `admin_moderates_user_spec.rb`' to v0.31 [\#16436](https://github.com/decidim/decidim/pull/16436)
- **decidim-core**: Backport 'Fix datepicker position when is placed at the bottom of the page' to v0.31 [\#16446](https://github.com/decidim/decidim/pull/16446)
- **decidim-core**: Backport 'Fix bug with the announcements break words rules' to v0.31 [\#16440](https://github.com/decidim/decidim/pull/16440)
- **decidim-admin**, **decidim-assemblies**, **decidim-budgets**, **decidim-conferences**, **decidim-core**, **decidim-dev**, **decidim-elections**, **decidim-forms**, **decidim-generators**, **decidim-initiatives**, **decidim-meetings**, **decidim-participatory processes**, **decidim-proposals**, **decidim-surveys**, **decidim-verifications**: Backport 'Fix meetings end date when it is multiyear' to v0.31 [\#16443](https://github.com/decidim/decidim/pull/16443)
- **decidim-admin**, **decidim-core**: Backport 'Do not ask password on invitations when organization has only external accounts' to v0.31 [\#16467](https://github.com/decidim/decidim/pull/16467)

### Removed

Nothing.

### Developer improvements

Nothing.

### Internal

Nothing.

## [0.31.2](https://github.com/decidim/decidim/tree/0.31.2)

### Added

Nothing.

### Changed

Nothing.

### Fixed

- **decidim-core**, **decidim-elections**: Backport 'Fix correct icon & name assignment for elections' to v0.31 [\#15973](https://github.com/decidim/decidim/pull/15973)
- **decidim-collaborative_texts**, **decidim-core**: Backport 'Fix collaborative texts name & icon in search' to v0.31 [\#15976](https://github.com/decidim/decidim/pull/15976)
- **decidim-initiatives**: Backport 'Fix disabled 'true' continue button in initiatives creation/edit' to v0.31 [\#15971](https://github.com/decidim/decidim/pull/15971)
- **decidim-assemblies**, **decidim-participatory processes**: Backport 'Make the document a required field in spaces import' to v0.31 [\#15982](https://github.com/decidim/decidim/pull/15982)
- **decidim-admin**, **decidim-core**: Backport 'Fix image removal bug in the hero block' to v0.31 [\#15985](https://github.com/decidim/decidim/pull/15985)
- **decidim-assemblies**, **decidim-core**, **decidim-participatory processes**: Backport 'Fix markup and UX between the spaces imports' to v0.31 [\#15990](https://github.com/decidim/decidim/pull/15990)
- **decidim-core**: Backport 'Fix notifications flaky specs' to v0.31 [\#16004](https://github.com/decidim/decidim/pull/16004)
- **decidim-core**, **decidim-participatory processes**: Backport 'Fix caching issue in processes content block' to v0.31 [\#15995](https://github.com/decidim/decidim/pull/15995)
- **decidim-initiatives**: Backport 'Fix for explanation what means a draft and pending initiative' to v0.31 [\#15997](https://github.com/decidim/decidim/pull/15997)
- **decidim-admin**, **decidim-proposals**: Backport 'Fix proposal to proposal component import' to v0.31 [\#15998](https://github.com/decidim/decidim/pull/15998)
- **decidim-core**: Backport 'Allow Attachment to answer to `can_participate?` based on it's attached model' to v0.31 [\#16006](https://github.com/decidim/decidim/pull/16006)
- **decidim-core**: Backport 'Show errors outside of the upload modal' to v0.31 [\#16009](https://github.com/decidim/decidim/pull/16009)
- **decidim-admin**, **decidim-assemblies**, **decidim-participatory processes**: Backport 'Fix can_participate? into ParticipatoryProcessStep' to v0.31 [\#16012](https://github.com/decidim/decidim/pull/16012)
- **decidim-core**: Backport 'Fix errors in account page when login is disabled' to v0.31 [\#16027](https://github.com/decidim/decidim/pull/16027)
- **decidim-proposals**: Backport 'Fix proposal vote button in show page' to v0.31 [\#16025](https://github.com/decidim/decidim/pull/16025)
- **decidim-admin**, **decidim-initiatives**: Backport 'Fix export buttons in Initiatives' to v0.31 [\#16031](https://github.com/decidim/decidim/pull/16031)
- **decidim-core**, **decidim-system**: Backport 'Fix semantic on flash messages' to v0.31 [\#16032](https://github.com/decidim/decidim/pull/16032)
- **decidim-admin**, **decidim-core**, **decidim-proposals**: Backport 'Attachment not persisting on error.' to v0.31 [\#16017](https://github.com/decidim/decidim/pull/16017)
- **decidim-conferences**, **decidim-core**: Backport 'Fix conference JumpTo button' to v0.31 [\#16062](https://github.com/decidim/decidim/pull/16062)
- **decidim-accountability**, **decidim-admin**: Backport 'Fix visual links missing from milestones' to v0.31 [\#16065](https://github.com/decidim/decidim/pull/16065)
- **decidim-meetings**, **decidim-proposals**: Backport 'Do not show withdrawn links if there aren't any' to v0.31 [\#16066](https://github.com/decidim/decidim/pull/16066)
- **decidim-budgets**: Backport 'Fix budgets list ordering' to v0.31 [\#16072](https://github.com/decidim/decidim/pull/16072)
- **decidim-admin**, **decidim-core**, **decidim-design**, **decidim-elections**, **decidim-proposals**, **decidim-system**: Backport 'Fix deprecation warnings for SASS' to v0.31 [\#16077](https://github.com/decidim/decidim/pull/16077)
- **decidim-assemblies**, **decidim-core**, **decidim-participatory processes**: Backport 'Show a warning message when the space images URL have errors' to v0.31 [\#16070](https://github.com/decidim/decidim/pull/16070)
- **decidim-core**, **decidim-system**: Backport 'Fix CSRF error on login pages' to v0.31 [\#16096](https://github.com/decidim/decidim/pull/16096)
- **decidim-participatory processes**: Backport 'Make the process groups admin navigation consistent with others spaces' to v0.31 [\#16098](https://github.com/decidim/decidim/pull/16098)
- **decidim-admin**, **decidim-participatory processes**: Backport 'Admin moderation unable to undo reported users' to v0.31 [\#16074](https://github.com/decidim/decidim/pull/16074)
- **decidim-blogs**, **decidim-comments**, **decidim-debates**, **decidim-dev**, **decidim-initiatives**, **decidim-meetings**, **decidim-proposals**: Backport 'Fix activity displayed as user instead of user group' to v0.31 [\#16101](https://github.com/decidim/decidim/pull/16101)
- **decidim-surveys**: Backport 'Fix survey export exporting wrong survey ' to v0.31 [\#16111](https://github.com/decidim/decidim/pull/16111)
- **decidim-assemblies**, **decidim-participatory processes**: Backport 'Show a warning message when the attachments URL are 404' to v0.31 [\#16112](https://github.com/decidim/decidim/pull/16112)
- **decidim-initiatives**: Backport 'Fix flaky spec in initiatives' filters' to v0.31 [\#16154](https://github.com/decidim/decidim/pull/16154)
- **decidim-accountability**, **decidim-core**: Backport 'Fix fail to upload file in survey when not logged in' to v0.31 [\#16149](https://github.com/decidim/decidim/pull/16149)
- **decidim-admin**, **decidim-core**, **decidim-forms**: Backport 'Fix translating taxonomies items doesn't work' to v0.31 [\#16147](https://github.com/decidim/decidim/pull/16147)
- **decidim-core**: Backport 'Fix flaky spec with lockable on authentication' to v0.31 [\#16152](https://github.com/decidim/decidim/pull/16152)
- **decidim-assemblies**, **decidim-meetings**, **decidim-participatory processes**: Backport 'Add validation for the import space with empty JSON' to v0.31 [\#16163](https://github.com/decidim/decidim/pull/16163)
- **decidim-assemblies**, **decidim-conferences**, **decidim-core**, **decidim-initiatives**, **decidim-participatory processes**: Backport 'Fix export for private spaces' to v0.31 [\#16162](https://github.com/decidim/decidim/pull/16162)
- **decidim-core**: Backport 'Fix showing announcement content block with only the default locale' to v0.31 [\#16179](https://github.com/decidim/decidim/pull/16179)
- **decidim-accountability**, **decidim-blogs**, **decidim-budgets**, **decidim-collaborative_texts**, **decidim-debates**, **decidim-dev**, **decidim-elections**, **decidim-meetings**, **decidim-pages**, **decidim-proposals**, **decidim-surveys**: Backport 'Fix serialization error in resource on component publication' to v0.31 [\#16168](https://github.com/decidim/decidim/pull/16168)
- **decidim-assemblies**, **decidim-conferences**, **decidim-core**, **decidim-initiatives**, **decidim-participatory processes**: Backport 'Fix component menu hidden feature for all the spaces' to v0.31 [\#16166](https://github.com/decidim/decidim/pull/16166)
- **decidim-core**: Backport 'Fix to allow locale-specific `user_name` placement in mobile greeting' to v0.31 [\#16182](https://github.com/decidim/decidim/pull/16182)
- **decidim-comments**: Backport 'Fix CommentSerializer NoMethodError when author is deleted' to v0.31 [\#16185](https://github.com/decidim/decidim/pull/16185)
- **decidim-admin**, **decidim-core**: Backport 'Fix allow admins deleting attachments with links' to v0.31 [\#16170](https://github.com/decidim/decidim/pull/16170)
- **decidim-assemblies**, **decidim-comments**, **decidim-core**, **decidim-participatory processes**, **decidim-proposals**: Backport 'Fix semantic html in some pages' to v0.31 [\#16173](https://github.com/decidim/decidim/pull/16173)
- **decidim-elections**: Backport 'Fix elections' manual start checkbox on edit' to v0.31 [\#16188](https://github.com/decidim/decidim/pull/16188)
- **decidim-admin**, **decidim-debates**, **decidim-elections**, **decidim-initiatives**, **decidim-proposals**: Backport 'Fix access to components in initiatives' to v0.31 [\#16175](https://github.com/decidim/decidim/pull/16175)
- **decidim-assemblies**: Backport 'Fix transparent checkbox for assembly on edit' to v0.31 [\#16210](https://github.com/decidim/decidim/pull/16210)

### Removed

Nothing.

### Developer improvements

Nothing.

### Internal

- **decidim-initiatives**: Backport 'Fix flaky spec in initiatives' filters' to v0.31 [\#16154](https://github.com/decidim/decidim/pull/16154)

## [0.31.1](https://github.com/decidim/decidim/tree/0.31.1)

### Added

Nothing.

### Changed

Nothing.

### Fixed

- **decidim-elections**: Backport 'Use proper action authorizer for internal census form validation' to v0.31 [\#15586](https://github.com/decidim/decidim/pull/15586)
- **decidim-admin**, **decidim-core**: Backport 'Fix deleted users follow in private participatory spaces' to v0.31 [\#15599](https://github.com/decidim/decidim/pull/15599)
- **decidim-admin**, **decidim-assemblies**, **decidim-conferences**, **decidim-participatory processes**: Backport 'Conference admin seeing processes' to v0.31 [\#15597](https://github.com/decidim/decidim/pull/15597)
- **decidim-participatory processes**: Backport 'Fix validation for start/end dates in processes' to v0.31 [\#15595](https://github.com/decidim/decidim/pull/15595)
- **decidim-generators**: Backport 'Fix gitignore for ServiceWorker related files' to v0.31 [\#15602](https://github.com/decidim/decidim/pull/15602)
- **decidim-core**: Backport 'Remove user data left behind by `Decidim::DestroyAccount`' to v0.31 [\#15623](https://github.com/decidim/decidim/pull/15623)
- **decidim-proposals**: Backport 'Proposal index grid cards ' to v0.31 [\#15629](https://github.com/decidim/decidim/pull/15629)
- **decidim-dev**, **decidim-participatory processes**: Backport 'System test for reordering component issue' to v0.31 [\#15628](https://github.com/decidim/decidim/pull/15628)
- **decidim-admin**, **decidim-core**, **decidim-proposals**: Backport 'Fix I18n source strings' to v0.31 [\#15621](https://github.com/decidim/decidim/pull/15621)
- **decidim-core**, **decidim-participatory processes**: Backport 'Process page announcement bug fix with system test' to v0.31 [\#15634](https://github.com/decidim/decidim/pull/15634)
- **decidim-core**: Backport 'Fix accessibility on mobile account modal' to v0.31 [\#15644](https://github.com/decidim/decidim/pull/15644)
- **decidim-core**, **decidim-proposals**: Backport 'Remove alt image on cards' to v0.31 [\#15646](https://github.com/decidim/decidim/pull/15646)
- **decidim-core**: Backport 'Fix  accessibility on active order element' to v0.31 [\#15648](https://github.com/decidim/decidim/pull/15648)
- **decidim-forms**, **decidim-surveys**: Backport 'Survey seperator on metadata & display condtion' to v0.31 [\#15651](https://github.com/decidim/decidim/pull/15651)
- **decidim-forms**: Backport 'Fix alignment on survey responses' to v0.31 [\#15656](https://github.com/decidim/decidim/pull/15656)
- **decidim-core**: Backport 'Fix accessibility update aria-current to static pages nav' to v0.31 [\#15653](https://github.com/decidim/decidim/pull/15653)
- **decidim-admin**, **decidim-system**: Backport 'Fix for editing an organization on system with 5 locales' to v0.31 [\#15668](https://github.com/decidim/decidim/pull/15668)
- **decidim-core**: Backport 'Fix participants selection and list in conversations' to v0.31 [\#15660](https://github.com/decidim/decidim/pull/15660)
- **decidim-core**, **decidim-proposals**: Backport 'Prevent whitespace collapse in fingerprint source in fingerprint modal' to v0.31 [\#15672](https://github.com/decidim/decidim/pull/15672)
- **decidim-conferences**: Backport 'Fix styles for registration modal in conferences' to v0.31 [\#15679](https://github.com/decidim/decidim/pull/15679)
- **decidim-assemblies**: Backport 'Show children assemblies in breadcrumb with components' to v0.31 [\#15677](https://github.com/decidim/decidim/pull/15677)
- **decidim-admin**, **decidim-core**, **decidim-dev**, **decidim-meetings**: Backport 'Reduce the number of parallel workers' to v0.31 [\#15691](https://github.com/decidim/decidim/pull/15691)
- **decidim-budgets**, **decidim-initiatives**: Backport 'Missing route on admin-engine initiatives' to v0.31 [\#15697](https://github.com/decidim/decidim/pull/15697)
- **decidim-accountability**, **decidim-comments**, **decidim-core**: Backport 'Filter invalid notifications from emails being sent' to v0.31 [\#15695](https://github.com/decidim/decidim/pull/15695)
- **decidim-assemblies**, **decidim-conferences**, **decidim-initiatives**, **decidim-participatory processes**: Backport 'Show processes groups in breadcrumb with components' to v0.31 [\#15699](https://github.com/decidim/decidim/pull/15699)
- **decidim-conferences**, **decidim-core**, **decidim-dev**, **decidim-generators**, **decidim-proposals**: Backport 'Change references from Faker::Twitter to Faker::X' to v0.31 [\#15716](https://github.com/decidim/decidim/pull/15716)
- **decidim-comments**, **decidim-core**, **decidim-dev**: Backport 'Improve the commentable GraphQL field' to v0.31 [\#15705](https://github.com/decidim/decidim/pull/15705)
- **decidim-accountability**, **decidim-admin**, **decidim-blogs**, **decidim-budgets**, **decidim-core**, **decidim-debates**, **decidim-meetings**, **decidim-proposals**: Backport 'Resources are displayed in general search if their component is unpublished' to v0.31 [\#15704](https://github.com/decidim/decidim/pull/15704)
- **decidim-elections**: Backport 'Remove duplicate code in elections' to v0.31 [\#15725](https://github.com/decidim/decidim/pull/15725)
- **decidim-accountability**, **decidim-blogs**, **decidim-debates**, **decidim-elections**, **decidim-meetings**, **decidim-participatory processes**, **decidim-proposals**: Backport 'Remove duplicate inclusion of SanitizeHelper' to v0.31 [\#15726](https://github.com/decidim/decidim/pull/15726)
- **decidim-admin**, **decidim-demographics**, **decidim-elections**, **decidim-forms**, **decidim-meetings**: Backport 'Fix questionnaire drag-and-drop blocking input text selection' to v0.31 [\#15728](https://github.com/decidim/decidim/pull/15728)
- **decidim-core**: Backport 'Fixing bug of off center external link warning modals in design pages' to v0.31 [\#15739](https://github.com/decidim/decidim/pull/15739)
- **decidim-admin**: Backport 'Add taxonomy missing strings' to v0.31 [\#15741](https://github.com/decidim/decidim/pull/15741)
- **decidim-core**, **decidim-generators**: Backport 'Lock connection_pool to 2.5.5' to v0.31 [\#15746](https://github.com/decidim/decidim/pull/15746)
- **decidim-meetings**: Backport 'Fix copy meeting taxonomies' to v0.31 [\#15745](https://github.com/decidim/decidim/pull/15745)
- **decidim-initiatives**: Backport 'Fix "request too large" error when exporting initiatives' to v0.31 [\#15751](https://github.com/decidim/decidim/pull/15751)
- **decidim-admin**, **decidim-core**: Backport 'Fixing issue of link target reverting back to _blank' to v0.31 [\#15753](https://github.com/decidim/decidim/pull/15753)
- **decidim-admin**, **decidim-budgets**, **decidim-core**, **decidim-proposals**: Backport 'Vote link updated to "button" within auth permissions' to v0.31 [\#15755](https://github.com/decidim/decidim/pull/15755)
- **decidim-elections**: Backport 'Add total votes count to election results in admin and public views' to v0.31 [\#15780](https://github.com/decidim/decidim/pull/15780)
- **decidim-elections**: Backport 'Allow editing last question on receipt page for per-question elections' to v0.31 [\#15781](https://github.com/decidim/decidim/pull/15781)
- **decidim-elections**: Backport 'Change Vote button to Edit vote when user has already voted' to v0.31 [\#15784](https://github.com/decidim/decidim/pull/15784)
- **decidim-elections**: Backport 'Prevent election editing after start regardless of publication status' to v0.31 [\#15783](https://github.com/decidim/decidim/pull/15783)
- **decidim-comments**, **decidim-core**: Backport 'Fix search result comment with link' to v0.31 [\#15805](https://github.com/decidim/decidim/pull/15805)
- **decidim-admin**, **decidim-surveys**: Backport 'Show responses menu entry in Surveys' admin' to v0.31 [\#15809](https://github.com/decidim/decidim/pull/15809)
- **decidim-comments**, **decidim-core**: Backport 'Fix focus trap in modal dialog for sharing' to v0.31 [\#15815](https://github.com/decidim/decidim/pull/15815)
- **decidim-budgets**: Backport 'Do not show "more information" modal when there isn't any' to v0.31 [\#15837](https://github.com/decidim/decidim/pull/15837)
- **decidim-core**: Backport 'Fix notification from Component publication' to v0.31 [\#15835](https://github.com/decidim/decidim/pull/15835)
- **decidim-admin**, **decidim-assemblies**, **decidim-conferences**, **decidim-initiatives**, **decidim-participatory processes**: Backport 'Sorting via created_at attribute within spaces' to v0.31 [\#15812](https://github.com/decidim/decidim/pull/15812)
- **decidim-pages**: Backport 'Fix factories location pages module' to v0.31 [\#15840](https://github.com/decidim/decidim/pull/15840)
- **decidim-assemblies**, **decidim-participatory processes**: Backport 'Fix process and assembly admin members action logs' to v0.31 [\#15818](https://github.com/decidim/decidim/pull/15818)
- **decidim-admin**, **decidim-core**, **decidim-system**: Backport 'Add short_name field to Organizations for PWA' to v0.31 [\#15817](https://github.com/decidim/decidim/pull/15817)
- **decidim-accountability**: Backport 'Fix accountability results filtering' to v0.31 [\#15870](https://github.com/decidim/decidim/pull/15870)
- **decidim-api**, **decidim-dev**, **decidim-initiatives**: Backport 'Fix error when there are too many aliases in GraphQL API' to v0.31 [\#15902](https://github.com/decidim/decidim/pull/15902)
- **decidim-accountability**, **decidim-api**, **decidim-assemblies**, **decidim-blogs**, **decidim-budgets**, **decidim-collaborative_texts**, **decidim-conferences**, **decidim-debates**, **decidim-dev**, **decidim-initiatives**, **decidim-meetings**, **decidim-pages**, **decidim-participatory processes**, **decidim-proposals**, **decidim-surveys**: Backport 'Disable introspection for regular users' to v0.31 [\#15905](https://github.com/decidim/decidim/pull/15905)
- **decidim-api**, **decidim-budgets**, **decidim-dev**, **decidim-initiatives**, **decidim-meetings**: Backport 'Avoid GraphQL circular query (recursion limit)' to v0.31 [\#15907](https://github.com/decidim/decidim/pull/15907)
- **decidim-core**: Backport 'Fix validation error in user name regular expression' to v0.31 [\#15923](https://github.com/decidim/decidim/pull/15923)
- **decidim-participatory processes**: Backport 'Fix quality indicator content block' to v0.31 [\#15935](https://github.com/decidim/decidim/pull/15935)
- **decidim-admin**, **decidim-assemblies**, **decidim-blogs**, **decidim-comments**, **decidim-conferences**, **decidim-core**, **decidim-dev**: Backport 'Fix username handling exceptions' to v0.31 [\#15940](https://github.com/decidim/decidim/pull/15940)
- **decidim-elections**: Backport 'Fix auto-redirect when question voting closes' to v0.31 [\#15948](https://github.com/decidim/decidim/pull/15948)
- **decidim-proposals**: Backport 'Prevent server error on proposal page when the user is not logged in' to v0.31 [\#15946](https://github.com/decidim/decidim/pull/15946)
- **decidim-forms**, **decidim-surveys**: Backport 'Fix survey matrix responses export in forms' to v0.31 [\#15952](https://github.com/decidim/decidim/pull/15952)
- **decidim-conferences**, **decidim-initiatives**, **decidim-meetings**: Backport 'Fix breadcrumb in conferences' program' to v0.31 [\#15941](https://github.com/decidim/decidim/pull/15941)
- 387a30d87b Fix proposal import with other proposals states in budgets [\#15846](https://github.com/decidim/decidim/pull/15846)

### Removed

Nothing.

### Developer improvements

- Backport 'Remove duplicate code in elections' to v0.31 [\#15725](https://github.com/decidim/decidim/pull/15725)
- Backport 'Remove duplicate inclusion of SanitizeHelper' to v0.31 [\#15726](https://github.com/decidim/decidim/pull/15726)

### Internal

- **decidim-admin**, **decidim-core**, **decidim-proposals**: Backport 'Fix I18n source strings' to v0.31 [\#15621](https://github.com/decidim/decidim/pull/15621)
- **decidim-elections**: Backport 'Remove duplicate code in elections' to v0.31 [\#15725](https://github.com/decidim/decidim/pull/15725)
- **decidim-accountability**, **decidim-blogs**, **decidim-debates**, **decidim-elections**, **decidim-meetings**, **decidim-participatory processes**, **decidim-proposals**: Backport 'Remove duplicate inclusion of SanitizeHelper' to v0.31 [\#15726](https://github.com/decidim/decidim/pull/15726)

### Unsorted

Nothing.

## [0.31.0](https://github.com/decidim/decidim/tree/0.31.0)

### Added

- **decidim-elections**: Backport 'Display the description of each question in the voting booth' to v0.31 [\#15458](https://github.com/decidim/decidim/pull/15458)

### Changed

Nothing.

### Fixed

- **decidim-admin**, **decidim-core**: Backport 'Fix visibility type in action log for menu_hide action' to v0.31 [\#15444](https://github.com/decidim/decidim/pull/15444)
- **decidim-admin**, **decidim-elections**: Backport 'UI adjustments for Elections part 2' to v0.31 [\#15453](https://github.com/decidim/decidim/pull/15453)
- **decidim-api**: Backport 'Change spec on decidim-api that removes the views directory' to v0.31 [\#15456](https://github.com/decidim/decidim/pull/15456)
- **decidim-core**, **decidim-elections**: Backport 'Disable start/end time when election is published' to v0.31 [\#15452](https://github.com/decidim/decidim/pull/15452)
- **decidim-elections**: Backport 'Display the description of each question in the voting booth' to v0.31 [\#15458](https://github.com/decidim/decidim/pull/15458)
- **decidim-comments**, **decidim-core**: Backport 'Fix missing `reportable_content_url` method' to v0.31 [\#15454](https://github.com/decidim/decidim/pull/15454)
- Backport 'Lock graphql-ws to stable version' to v0.31 [\#15474](https://github.com/decidim/decidim/pull/15474)
- **decidim-generators**: Backport 'Remove github directory in newly generated apps' to v0.31 [\#15477](https://github.com/decidim/decidim/pull/15477)
- **decidim-core**: Backport 'Add local `app/views` to `Cell::ViewModel` view paths' to v0.31 [\#15480](https://github.com/decidim/decidim/pull/15480)
- **decidim-admin**: Backport 'Do not update the weight when updating the component form' to v0.31 [\#15493](https://github.com/decidim/decidim/pull/15493)
- **decidim-core**, **decidim-dev**: Backport 'Fix flaky specs on private exports' to v0.31 [\#15504](https://github.com/decidim/decidim/pull/15504)
- **decidim-core**, **decidim-dev**: Backport 'Fix production alert error for deprecated js components' to v0.31 [\#15510](https://github.com/decidim/decidim/pull/15510)
- **decidim-core**: Backport 'Search & filter in mobile responsive view' to v0.31 [\#15520](https://github.com/decidim/decidim/pull/15520)
- **decidim-blogs**: Backport 'Order posts by publication date' to v0.31 [\#15521](https://github.com/decidim/decidim/pull/15521)
- **decidim-core**: Backport 'Prevent shakapacker related flakys in CI' to v0.31 [\#15513](https://github.com/decidim/decidim/pull/15513)
- **decidim-core**: Backport 'Fix markers displayed in meeting page' to v0.31 [\#15517](https://github.com/decidim/decidim/pull/15517)
- **decidim-admin**, **decidim-assemblies**: Backport 'Fix JS lint warning about absolute path with import statement' to v0.31 [\#15498](https://github.com/decidim/decidim/pull/15498)
- **decidim-accountability**, **decidim-admin**, **decidim-blogs**, **decidim-budgets**, **decidim-collaborative_texts**, **decidim-debates**, **decidim-elections**, **decidim-meetings**, **decidim-pages**, **decidim-proposals**, **decidim-surveys**: Backport 'Fix for process admins accessing some components' to v0.31 [\#15531](https://github.com/decidim/decidim/pull/15531)
- **decidim-accountability**, **decidim-admin**, **decidim-ai**, **decidim-api**, **decidim-assemblies**, **decidim-blogs**, **decidim-budgets**, **decidim-collaborative_texts**, **decidim-comments**, **decidim-conferences**, **decidim-core**, **decidim-debates**, **decidim-demographics**, **decidim-dev**, **decidim-elections**, **decidim-forms**, **decidim-generators**, **decidim-initiatives**, **decidim-meetings**, **decidim-pages**, **decidim-participatory processes**, **decidim-proposals**, **decidim-sortitions**, **decidim-surveys**, **decidim-templates**, **decidim-verifications**: Backport 'Add data-migrate gem' to v0.31 [\#15527](https://github.com/decidim/decidim/pull/15527)
- **decidim-meetings**: Backport 'Use same card for Meeting always' to v0.31 [\#15545](https://github.com/decidim/decidim/pull/15545)
- **decidim-core**: Backport 'Fix links in footer when using the organizations' description' to v0.31 [\#15542](https://github.com/decidim/decidim/pull/15542)
- **decidim-assemblies**, **decidim-conferences**, **decidim-core**, **decidim-initiatives**, **decidim-participatory processes**: Backport 'Fix duplicated participatory spaces in open data exports' to v0.31 [\#15549](https://github.com/decidim/decidim/pull/15549)
- **decidim-conferences**: Backport 'Add missing i18n string in Conference program page' to v0.31 [\#15553](https://github.com/decidim/decidim/pull/15553)
- **decidim-conferences**: Backport 'Use taxonomies instead of categories for the conferences' program' to v0.31 [\#15562](https://github.com/decidim/decidim/pull/15562)
- **decidim-core**: Backport 'Fix strong tags color in footer organization description' to v0.31 [\#15559](https://github.com/decidim/decidim/pull/15559)
- **decidim-admin**, **decidim-core**: Backport 'Fix table filter names disappear on hover in admin panel' to v0.31 [\#15557](https://github.com/decidim/decidim/pull/15557)
- **decidim-meetings**: Backport 'Fix reminder default value in legacy meetings' to v0.31 [\#15551](https://github.com/decidim/decidim/pull/15551)
- **decidim-comments**, **decidim-core**: Backport 'Fix references for legacy UserGroups in Comments' to v0.31 [\#15556](https://github.com/decidim/decidim/pull/15556)

### Removed

Nothing.

### Developer improvements

Nothing.

### Internal

- Add deprecation notes for modules in v0.31 [\#15441](https://github.com/decidim/decidim/pull/15441)
- **decidim-api**: Backport 'Change spec on decidim-api that removes the views directory' to v0.31 [\#15456](https://github.com/decidim/decidim/pull/15456)
- **decidim-core**: Backport 'Prevent shakapacker related flakys in CI' to v0.31 [\#15513](https://github.com/decidim/decidim/pull/15513)
- **decidim-admin**, **decidim-assemblies**: Backport 'Fix JS lint warning about absolute path with import statement' to v0.31 [\#15498](https://github.com/decidim/decidim/pull/15498)
- Add warning regarding a User Group activity bug [\#15558](https://github.com/decidim/decidim/pull/15558)

## [0.31.0.rc2](https://github.com/decidim/decidim/tree/0.31.0.rc2)

### Added

Nothing.

### Changed

- **decidim-elections**: Backport 'Elections admin layout update' to v0.31 [\#15312](https://github.com/decidim/decidim/pull/15312)

### Fixed

- **decidim-dev**: Backport 'Remove the `parallel_tests/tasks` from `common_rake`' to v0.31 [\#15225](https://github.com/decidim/decidim/pull/15225)
- **decidim-design**: Backport 'Fix some accessibility violations in design's a11y page' to v0.31 [\#15230](https://github.com/decidim/decidim/pull/15230)
- **decidim-participatory processes**: Backport 'Fix translation missing for duplicate landing blocks' to v0.31 [\#15218](https://github.com/decidim/decidim/pull/15218)
- **decidim-participatory processes**, **decidim-system**: Backport 'Fix quality page indicators page' to v0.31 [\#15234](https://github.com/decidim/decidim/pull/15234)
- **decidim-meetings**: Backport 'Fix meetings' seeds with 'Reminder time in hours before the meeting' field' to v0.31 [\#15239](https://github.com/decidim/decidim/pull/15239)
- **decidim-core**: Backport 'Prevent reload on filters when the 'Skip to' links are clicked' to v0.31 [\#15240](https://github.com/decidim/decidim/pull/15240)
- **decidim-accountability**, **decidim-admin**, **decidim-assemblies**, **decidim-conferences**, **decidim-core**, **decidim-demographics**, **decidim-design**, **decidim-elections**, **decidim-forms**, **decidim-meetings**, **decidim-participatory processes**, **decidim-surveys**: Backport 'Fix drag and drop sorting for questionnaires' to v0.31 [\#15241](https://github.com/decidim/decidim/pull/15241)
- **decidim-admin**: Backport 'Fix officialization view for users without nickname' to v0.31 [\#15244](https://github.com/decidim/decidim/pull/15244)
- **decidim-forms**, **decidim-surveys**: Backport 'Refine the translation for a survey setting' to v0.31 [\#15263](https://github.com/decidim/decidim/pull/15263)
- **decidim-meetings**: Backport 'Show the question confirmation when unpublishing a meeting' to v0.31 [\#15264](https://github.com/decidim/decidim/pull/15264)
- **decidim-admin**: Backport 'Fix admin officialization specs' to v0.31 [\#15252](https://github.com/decidim/decidim/pull/15252)
- **decidim-meetings**: Backport 'Add published/unpublished state in the Meetings' admin index page' to v0.31 [\#15275](https://github.com/decidim/decidim/pull/15275)
- **decidim-surveys**: Backport 'Add published/unpublished state in the Surveys' admin index page' to v0.31 [\#15278](https://github.com/decidim/decidim/pull/15278)
- **decidim-meetings**: Backport 'Show unpublished meetings in the Meetings' admin sidebar counter' to v0.31 [\#15279](https://github.com/decidim/decidim/pull/15279)
- **decidim-collaborative_texts**: Backport 'Add published status in collaborative texts in admin' to v0.31 [\#15283](https://github.com/decidim/decidim/pull/15283)
- **decidim-meetings**: Backport 'Fix meeting frontend menu items entries' to v0.31 [\#15286](https://github.com/decidim/decidim/pull/15286)
- **decidim-verifications**: Backport 'Fix incorrectly named initialize methods in `decidim-verifications`' to v0.31 [\#15292](https://github.com/decidim/decidim/pull/15292)
- **decidim-elections**: Backport 'Elections admin layout update' to v0.31 [\#15312](https://github.com/decidim/decidim/pull/15312)
- **decidim-elections**: Backport 'Fix election states in admin' to v0.31 [\#15305](https://github.com/decidim/decidim/pull/15305)
- **decidim-core**: Backport 'Fix focus with tab navigation on small avatar images' to v0.31 [\#15301](https://github.com/decidim/decidim/pull/15301)
- **decidim-assemblies**, **decidim-budgets**, **decidim-core**, **decidim-debates**, **decidim-meetings**, **decidim-participatory processes**, **decidim-proposals**: Backport 'Fix collapse not working in the filters' to v0.31 [\#15310](https://github.com/decidim/decidim/pull/15310)
- **decidim-core**: Backport 'Fix adjacent links in author's cell and make styling consistent' to v0.31 [\#15302](https://github.com/decidim/decidim/pull/15302)
- **decidim-core**: Backport 'Fix active record scope on Decidim::User ' to v0.31 [\#15313](https://github.com/decidim/decidim/pull/15313)
- **decidim-meetings**, **decidim-proposals**, **decidim-sortitions**: Backport 'Add deprecation notices for Polls, Sortitions, and Collaborative Drafts' to v0.31 [\#15314](https://github.com/decidim/decidim/pull/15314)
- **decidim-budgets**: Backport 'Fix exception in search with budgets' projects' to v0.31 [\#15325](https://github.com/decidim/decidim/pull/15325)
- **decidim-core**: Backport 'Show badges next to user nicknames' to v0.31 [\#15320](https://github.com/decidim/decidim/pull/15320)
- **decidim-core**, **decidim-proposals**: Backport 'Fix adjacent links in the related documents/attachments links' to v0.31 [\#15330](https://github.com/decidim/decidim/pull/15330)
- **decidim-comments**, **decidim-debates**: Backport 'Change user links in Comments and Debates' to v0.31 [\#15327](https://github.com/decidim/decidim/pull/15327)
- Backport 'Fix w3c validator CI pipeline (NuValidator json errors)' to v0.31 [\#15342](https://github.com/decidim/decidim/pull/15342)
- **decidim-core**: Backport 'Fix error unexpected value at params[:host]' to v0.31 [\#15336](https://github.com/decidim/decidim/pull/15336)
- **decidim-core**: Backport 'Allow password validator to use the fallback translation' to v0.31 [\#15333](https://github.com/decidim/decidim/pull/15333)
- **decidim-core**: Backport 'Make the WYSIWYG editor vertical resizable' to v0.31 [\#15370](https://github.com/decidim/decidim/pull/15370)
- Backport 'Add notes for configuring CSP with ActiveStorage' to v0.31 [\#15373](https://github.com/decidim/decidim/pull/15373)
- **decidim-admin**, **decidim-forms**, **decidim-surveys**: Backport 'Back to responses button in surveys' to v0.31 [\#15375](https://github.com/decidim/decidim/pull/15375)
- **decidim-admin**: Backport 'Fix the color chooser selector with enter' to v0.31 [\#15374](https://github.com/decidim/decidim/pull/15374)
- **decidim-core**: Backport 'Fix deleted comments on public profile' to v0.31 [\#15376](https://github.com/decidim/decidim/pull/15376)
- Revert "Fix w3c validator CI pipeline (#15342)"  [\#15380](https://github.com/decidim/decidim/pull/15380)
- **decidim-forms**: Backport 'Fix drag_and_drop on mobile without scrolling' to v0.31 [\#15387](https://github.com/decidim/decidim/pull/15387)
- **decidim-admin**: Backport 'Add missing translation key for enable machine translation' to v0.31 [\#15384](https://github.com/decidim/decidim/pull/15384)
- **decidim-proposals**: Backport 'Fix proposal evaluation migration' to v0.31 [\#15392](https://github.com/decidim/decidim/pull/15392)
- **decidim-core**: Backport 'Fix Regex expression in Etiquette Validator' to v0.31 [\#15394](https://github.com/decidim/decidim/pull/15394)
- **decidim-participatory processes**: Backport 'Fix ActiveRecord::AssociationTypeMismatch in AddDemocraticQualityStaticPage' to v0.31 [\#15404](https://github.com/decidim/decidim/pull/15404)
- **decidim-participatory processes**: Backport 'Fix phase and date order in "Phase & duration" block ' to v0.31 [\#15401](https://github.com/decidim/decidim/pull/15401)
- **decidim-proposals**: Backport 'Fix saving geocoding data when present in proposals' to v0.31 [\#15403](https://github.com/decidim/decidim/pull/15403)
- **decidim-generators**: Backport 'Fix expiring Cloud Storage tokens' to v0.31 [\#15400](https://github.com/decidim/decidim/pull/15400)
- **decidim-core**: Backport 'Fix highlight card displaying unpublished process' to v0.31 [\#15415](https://github.com/decidim/decidim/pull/15415)
- **decidim-core**: Backport 'Fix user group deprecation email messages' to v0.31 [\#15418](https://github.com/decidim/decidim/pull/15418)
- **decidim-admin**, **decidim-elections**: Backport 'Start election sticky button ' to v0.31 [\#15419](https://github.com/decidim/decidim/pull/15419)
- **decidim-comments**: Backport 'Fix for comment sort by dropdown' to v0.31 [\#15422](https://github.com/decidim/decidim/pull/15422)
- **decidim-admin**, **decidim-elections**, **decidim-forms**: Backport 'Dynamic question sorting Elections ' to v0.31 [\#15420](https://github.com/decidim/decidim/pull/15420)
- **decidim-core**: Backport 'Patch user groups that have invalid emails' to v0.31 [\#15427](https://github.com/decidim/decidim/pull/15427)
- **decidim-generators**, **decidim-system**: Backport 'Fix broken URL to CSP documentation in organization settings (#14909)' to v0.31 [\#15430](https://github.com/decidim/decidim/pull/15430)

### Removed

Nothing.

### Developer improvements

Nothing.

### Internal

- **decidim-dev**: Backport 'Remove the `parallel_tests/tasks` from `common_rake`' to v0.31 [\#15225](https://github.com/decidim/decidim/pull/15225)
- Make Releases Notes consistent with v0.30 [\#15429](https://github.com/decidim/decidim/pull/15429)

## [0.31.0.rc1](https://github.com/decidim/decidim/tree/0.31.0.rc1)

### Added

Nothing.

### Changed

- Documentation update for ```ruby``` version in develop [\#14201](https://github.com/decidim/decidim/pull/14201)
- **decidim-accountability**, **decidim-api**, **decidim-assemblies**, **decidim-blogs**, **decidim-budgets**, **decidim-comments**, **decidim-conferences**, **decidim-core**, **decidim-debates**, **decidim-forms**, **decidim-initiatives**, **decidim-meetings**, **decidim-pages**, **decidim-participatory processes**, **decidim-proposals**, **decidim-sortitions**, **decidim-surveys**: Refactor specs paths for `decidim-api` examples [\#14246](https://github.com/decidim/decidim/pull/14246)
- **decidim-accountability**, **decidim-admin**, **decidim-ai**, **decidim-api**, **decidim-blogs**, **decidim-budgets**, **decidim-comments**, **decidim-conferences**, **decidim-core**, **decidim-debates**, **decidim-dev**, **decidim-forms**, **decidim-generators**, **decidim-initiatives**, **decidim-meetings**, **decidim-pages**, **decidim-proposals**, **decidim-sortitions**, **decidim-system**: Transform user groups into regular users [\#14130](https://github.com/decidim/decidim/pull/14130)
- **decidim-accountability**, **decidim-admin**, **decidim-api**, **decidim-assemblies**, **decidim-budgets**, **decidim-comments**, **decidim-conferences**, **decidim-core**, **decidim-debates**, **decidim-dev**, **decidim-forms**, **decidim-initiatives**, **decidim-meetings**, **decidim-participatory processes**, **decidim-proposals**, **decidim-sortitions**, **decidim-surveys**, **decidim-system**, **decidim-templates**, **decidim-verifications**: Change "Valuator" for "Evaluator" [\#13684](https://github.com/decidim/decidim/pull/13684)
- **decidim-core**, **decidim-dev**, **decidim-forms**, **decidim-initiatives**, **decidim-meetings**, **decidim-participatory processes**, **decidim-surveys**, **decidim-templates**: Rename answers to responses in surveys, forms and meetings [\#14316](https://github.com/decidim/decidim/pull/14316)
- **decidim-admin**, **decidim-assemblies**, **decidim-conferences**, **decidim-core**, **decidim-initiatives**, **decidim-participatory processes**: Make the form borders and spacings consistents [\#14366](https://github.com/decidim/decidim/pull/14366)
- **decidim-blogs**, **decidim-core**: Migrate to proper publish behavior in blogs [\#13291](https://github.com/decidim/decidim/pull/13291)
- **decidim-participatory processes**: Related processes to process group help text [\#14439](https://github.com/decidim/decidim/pull/14439)
- **decidim-accountability**, **decidim-api**, **decidim-budgets**, **decidim-core**, **decidim-generators**, **decidim-initiatives**, **decidim-meetings**, **decidim-proposals**, **decidim-system**, **decidim-verifications**: Migrate `Rails.application.secrets` to Environment Variables [\#13268](https://github.com/decidim/decidim/pull/13268)
- **decidim-admin**, **decidim-conferences**, **decidim-core**, **decidim-design**, **decidim-system**: Change the metatags to rails tags [\#14533](https://github.com/decidim/decidim/pull/14533)
- **decidim-core**, **decidim-meetings**: Align global Search page with other search pages  [\#14133](https://github.com/decidim/decidim/pull/14133)
- **decidim-core**, **decidim-participatory processes**: Allow searching for participatory processes groups [\#14578](https://github.com/decidim/decidim/pull/14578)
- **decidim-assemblies**, **decidim-conferences**, **decidim-initiatives**, **decidim-sortitions**: Change timestamps to a new format in the API [\#14640](https://github.com/decidim/decidim/pull/14640)
- **decidim-accountability**, **decidim-api**, **decidim-blogs**, **decidim-budgets**, **decidim-comments**, **decidim-core**, **decidim-debates**, **decidim-initiatives**, **decidim-meetings**, **decidim-pages**, **decidim-participatory processes**, **decidim-proposals**, **decidim-sortitions**, **decidim-surveys**: Add missing URL for resources in GraphQL API [\#14639](https://github.com/decidim/decidim/pull/14639)
- **decidim-accountability**, **decidim-budgets**, **decidim-generators**, **decidim-meetings**: Remove `enable_proposal_linking` setting [\#14453](https://github.com/decidim/decidim/pull/14453)
- **decidim-admin**: Restructure admin settings form [\#14724](https://github.com/decidim/decidim/pull/14724)
- **decidim-api**, **decidim-blogs**, **decidim-budgets**, **decidim-core**, **decidim-debates**, **decidim-design**, **decidim-dev**, **decidim-initiatives**, **decidim-meetings**, **decidim-proposals**: Rename "Endorsement" to "Like"  [\#14666](https://github.com/decidim/decidim/pull/14666)
- README section for endorsements to likes [\#14738](https://github.com/decidim/decidim/pull/14738)
- **decidim-admin**, **decidim-core**: Move appearance sections to organizations' settings form [\#14736](https://github.com/decidim/decidim/pull/14736)
- **decidim-core**, **decidim-generators**, **decidim-initiatives**, **decidim-proposals**: Change framework defaults from Rails v6.1 to v7.0 [\#14735](https://github.com/decidim/decidim/pull/14735)
- **decidim-admin**, **decidim-core**, **decidim-verifications**: Move CTA button configuration to Hero content block [\#14741](https://github.com/decidim/decidim/pull/14741)
- **decidim-accountability**, **decidim-admin**, **decidim-api**, **decidim-assemblies**, **decidim-blogs**, **decidim-budgets**, **decidim-collaborative_texts**, **decidim-comments**, **decidim-conferences**, **decidim-core**, **decidim-debates**, **decidim-dev**, **decidim-forms**, **decidim-generators**, **decidim-initiatives**, **decidim-meetings**, **decidim-participatory processes**, **decidim-proposals**, **decidim-sortitions**, **decidim-surveys**, **decidim-system**, **decidim-templates**, **decidim-verifications**: Update Rails to v7.1 [\#13267](https://github.com/decidim/decidim/pull/13267)
- **decidim-accountability**, **decidim-admin**, **decidim-assemblies**, **decidim-blogs**, **decidim-budgets**, **decidim-collaborative_texts**, **decidim-comments**, **decidim-conferences**, **decidim-core**, **decidim-debates**, **decidim-initiatives**, **decidim-meetings**, **decidim-participatory processes**, **decidim-proposals**, **decidim-surveys**, **decidim-templates**: Migrate dropdowns in admin from Foundation to Tailwind [\#14713](https://github.com/decidim/decidim/pull/14713)
- **decidim-admin**, **decidim-core**, **decidim-initiatives**, **decidim-system**: Remove Appearance page [\#14797](https://github.com/decidim/decidim/pull/14797)
- **decidim-admin**, **decidim-assemblies**, **decidim-dev**, **decidim-participatory processes**: Change content blocks (layout) pages titles [\#14866](https://github.com/decidim/decidim/pull/14866)
- **decidim-accountability**, **decidim-admin**, **decidim-core**, **decidim-initiatives**, **decidim-participatory processes**: Rename projects entries to milestones in accountability [\#14728](https://github.com/decidim/decidim/pull/14728)
- **decidim-conferences**: Implement cards in the Conferences form and improve UX [\#14989](https://github.com/decidim/decidim/pull/14989)
- **decidim-conferences**: Rename copy to duplicate in conferences  [\#14993](https://github.com/decidim/decidim/pull/14993)
- **decidim-accountability**, **decidim-admin**, **decidim-assemblies**, **decidim-blogs**, **decidim-budgets**, **decidim-collaborative_texts**, **decidim-conferences**, **decidim-core**, **decidim-debates**, **decidim-demographics**, **decidim-elections**, **decidim-forms**, **decidim-initiatives**, **decidim-meetings**, **decidim-pages**, **decidim-participatory processes**, **decidim-proposals**, **decidim-sortitions**, **decidim-surveys**, **decidim-system**, **decidim-templates**, **decidim-verifications**: Add :unprocessable_entity state urls where form validation failed [\#15010](https://github.com/decidim/decidim/pull/15010)
- **decidim-accountability**, **decidim-admin**, **decidim-assemblies**, **decidim-blogs**, **decidim-budgets**, **decidim-collaborative_texts**, **decidim-conferences**, **decidim-core**, **decidim-debates**, **decidim-initiatives**, **decidim-meetings**, **decidim-participatory processes**, **decidim-proposals**, **decidim-surveys**: Change actions' names and orders in admins' meatballs [\#14972](https://github.com/decidim/decidim/pull/14972)
- **decidim-admin**, **decidim-surveys**: Suvery admin page update  [\#15032](https://github.com/decidim/decidim/pull/15032)
- **decidim-assemblies**: Rename copy to duplicate assemblies [\#15040](https://github.com/decidim/decidim/pull/15040)
- **decidim-core**, **decidim-meetings**, **decidim-participatory processes**: Meetings permissions refactor [\#14501](https://github.com/decidim/decidim/pull/14501)
- **decidim-participatory processes**: Rename copy to duplicate in participatory processes [\#15047](https://github.com/decidim/decidim/pull/15047)
- **decidim-admin**, **decidim-core**, **decidim-demographics**, **decidim-participatory processes**: Quality indicator questions update [\#15037](https://github.com/decidim/decidim/pull/15037)
- **decidim-accountability**, **decidim-admin**, **decidim-assemblies**, **decidim-blogs**, **decidim-budgets**, **decidim-collaborative_texts**, **decidim-conferences**, **decidim-debates**, **decidim-elections**, **decidim-meetings**, **decidim-participatory processes**, **decidim-proposals**, **decidim-verifications**: Underline page removal admin [\#15051](https://github.com/decidim/decidim/pull/15051)
- Versions update docs [\#15060](https://github.com/decidim/decidim/pull/15060)
- **decidim-assemblies**, **decidim-blogs**, **decidim-conferences**, **decidim-core**, **decidim-debates**, **decidim-meetings**, **decidim-participatory processes**, **decidim-proposals**, **decidim-surveys**: Fix so user can't update a meeting with empty body [\#14281](https://github.com/decidim/decidim/pull/14281)
- **decidim-admin**, **decidim-participatory processes**: Update to democratic quality indicators [\#15148](https://github.com/decidim/decidim/pull/15148)
- **decidim-admin**, **decidim-budgets**: Replace the 'Voting rules' checkboxes with radio buttons in budgets [\#15175](https://github.com/decidim/decidim/pull/15175)
- **decidim-budgets**: Remove permissions from budgets' projects [\#15176](https://github.com/decidim/decidim/pull/15176)

### Fixed

- **decidim-sortitions**: Fix display proposals in sortitions when votes enabled [\#14087](https://github.com/decidim/decidim/pull/14087)
- **decidim-core**: Add extra details to decidim:upgrade:migrations task [\#14125](https://github.com/decidim/decidim/pull/14125)
- **decidim-blogs**, **decidim-budgets**, **decidim-core**, **decidim-debates**, **decidim-meetings**, **decidim-proposals**, **decidim-sortitions**: Fix share modal on budget projects page [\#14088](https://github.com/decidim/decidim/pull/14088)
- **decidim-core**: Hide help buttons if no help content is given in admin-side [\#14063](https://github.com/decidim/decidim/pull/14063)
- **decidim-core**, **decidim-proposals**: Avoid server error when accepting a proposal without giving it a cost [\#14062](https://github.com/decidim/decidim/pull/14062)
- **decidim-proposals**: Fix error handling when proposal answer form has errors [\#14143](https://github.com/decidim/decidim/pull/14143)
- **decidim-admin**, **decidim-ai**, **decidim-comments**, **decidim-core**, **decidim-meetings**, **decidim-proposals**: Hide comments when parent resource is hidden [\#13554](https://github.com/decidim/decidim/pull/13554)
- **decidim-proposals**: Fix proposal state label in admin [\#14138](https://github.com/decidim/decidim/pull/14138)
- **decidim-core**: Use leaflet-tilelayer-here v2.0.3 [\#14164](https://github.com/decidim/decidim/pull/14164)
- **decidim-core**: Fix excessive categories nesting when converting to taxonomies [\#14148](https://github.com/decidim/decidim/pull/14148)
- **decidim-budgets**: Fix an UI error in budgeting in the progress bar [\#14183](https://github.com/decidim/decidim/pull/14183)
- **decidim-budgets**: Fix budget index card width [\#14186](https://github.com/decidim/decidim/pull/14186)
- Fix Aitools documentation [\#14187](https://github.com/decidim/decidim/pull/14187)
- **decidim-proposals**: Import proposals from one component to another in the background [\#14162](https://github.com/decidim/decidim/pull/14162)
- **decidim-core**: Add PaperTrailJob to help migration [\#14139](https://github.com/decidim/decidim/pull/14139)
- **decidim-admin**, **decidim-core**: Fix modal for reported participants [\#14031](https://github.com/decidim/decidim/pull/14031)
- **decidim-proposals**: Fix proposal state when importing from another component [\#14209](https://github.com/decidim/decidim/pull/14209)
- **decidim-core**: Fix user activity filter [\#14170](https://github.com/decidim/decidim/pull/14170)
- **decidim-debates**, **decidim-meetings**, **decidim-proposals**, **decidim-sortitions**: Fix WCAG status messages when update filter [\#14016](https://github.com/decidim/decidim/pull/14016)
- **decidim-comments**, **decidim-core**, **decidim-meetings**: Fix CSS details (mostly alignments and gaps) [\#14228](https://github.com/decidim/decidim/pull/14228)
- **decidim-core**, **decidim-generators**: Fix static map image fetching with Here maps service [\#14180](https://github.com/decidim/decidim/pull/14180)
- Document additional scheduled tasks [\#14233](https://github.com/decidim/decidim/pull/14233)
- **decidim-initiatives**: Fix initiative admin main menu disappearing in other spaces [\#14245](https://github.com/decidim/decidim/pull/14245)
- **decidim-core**: Fix accordion in Open Data page [\#14248](https://github.com/decidim/decidim/pull/14248)
- **decidim-proposals**: Fix linked proposals [\#14244](https://github.com/decidim/decidim/pull/14244)
- Update oauth.adoc, fix typo [\#14257](https://github.com/decidim/decidim/pull/14257)
- **decidim-proposals**: Fix proposals votes frontend issues [\#14221](https://github.com/decidim/decidim/pull/14221)
- **decidim-core**, **decidim-forms**, **decidim-participatory processes**, **decidim-proposals**, **decidim-surveys**: Fix details and minor details  [\#14270](https://github.com/decidim/decidim/pull/14270)
- **decidim-admin**: Fix submit on button on forms with taxonomies [\#14262](https://github.com/decidim/decidim/pull/14262)
- **decidim-comments**: Fix default order shown in comments dropdown [\#14038](https://github.com/decidim/decidim/pull/14038)
- **decidim-core**: Register user without avatar on omniauth registration if avatar_url is unreachable [\#14135](https://github.com/decidim/decidim/pull/14135)
- **decidim-core**: Fix invalid chars in name when using OAuth login [\#13566](https://github.com/decidim/decidim/pull/13566)
- **decidim-admin**, **decidim-core**: Fix lower casing for user's nickname [\#14272](https://github.com/decidim/decidim/pull/14272)
- **decidim-budgets**, **decidim-core**: Fix budget detail with "You voted for this" string [\#14284](https://github.com/decidim/decidim/pull/14284)
- **decidim-core**, **decidim-proposals**, **decidim-sortitions**: Change `hide_voting` argument on proposal cell to `show_voting` [\#14267](https://github.com/decidim/decidim/pull/14267)
- **decidim-core**, **decidim-initiatives**: Fix QR code generation [\#14300](https://github.com/decidim/decidim/pull/14300)
- **decidim-core**: Fix hide comment from interface [\#14301](https://github.com/decidim/decidim/pull/14301)
- **decidim-ai**, **decidim-generators**: Add delay of `spam_analysis` queue [\#14304](https://github.com/decidim/decidim/pull/14304)
- **decidim-core**: Fix image missing error [\#14175](https://github.com/decidim/decidim/pull/14175)
- **decidim-core**: Fix white bottom on proposal show with voting [\#14285](https://github.com/decidim/decidim/pull/14285)
- **decidim-blogs**, **decidim-debates**, **decidim-meetings**, **decidim-proposals**: Add title tag on pages for blogs, debates and meetings [\#14110](https://github.com/decidim/decidim/pull/14110)
- **decidim-comments**: Fix editing comment with max length setting [\#14275](https://github.com/decidim/decidim/pull/14275)
- **decidim-comments**: Fix comment cell to not show reply button when passing MAX_DEPTH [\#14291](https://github.com/decidim/decidim/pull/14291)
- **decidim-core**: Fix WCAG search filters navigation [\#14014](https://github.com/decidim/decidim/pull/14014)
- **decidim-verifications**: Fix title on spec for the 'Create new proposal' page [\#14347](https://github.com/decidim/decidim/pull/14347)
- **decidim-core**: Fix searches filtering results when not are commentable [\#14355](https://github.com/decidim/decidim/pull/14355)
- **decidim-core**: Fix profile user display on some resolutions [\#14371](https://github.com/decidim/decidim/pull/14371)
- **decidim-budgets**: Fix alignment of sorting options on projects [\#14362](https://github.com/decidim/decidim/pull/14362)
- **decidim-core**, **decidim-proposals**: Prevent the error generating the diff for non-translatable fields in old version records [\#14363](https://github.com/decidim/decidim/pull/14363)
- **decidim-comments**: Fix edit comment modal cell displaying old cached values [\#14365](https://github.com/decidim/decidim/pull/14365)
- **decidim-admin**, **decidim-assemblies**, **decidim-conferences**, **decidim-core**, **decidim-initiatives**, **decidim-participatory processes**: Make the form borders and spacings consistents [\#14366](https://github.com/decidim/decidim/pull/14366)
- **decidim-meetings**: Fix meeting overriding customized frame-src security policy [\#14391](https://github.com/decidim/decidim/pull/14391)
- **decidim-api**: Decidim version API docs [\#14390](https://github.com/decidim/decidim/pull/14390)
- **decidim-core**: Use a better fallback for the datepicker date format [\#14321](https://github.com/decidim/decidim/pull/14321)
- **decidim-api**: Add test for API docs version disclosure [\#14403](https://github.com/decidim/decidim/pull/14403)
- **decidim-admin**, **decidim-proposals**: Remove costs requirement on proposals [\#14136](https://github.com/decidim/decidim/pull/14136)
- **decidim-templates**: Fix pipeline on costs [\#14412](https://github.com/decidim/decidim/pull/14412)
- **decidim-blogs**, **decidim-core**: Migrate to proper publish behavior in blogs [\#13291](https://github.com/decidim/decidim/pull/13291)
- **decidim-core**: Fix wcag keyboard modal cookie settings [\#14357](https://github.com/decidim/decidim/pull/14357)
- **decidim-core**, **decidim-proposals**: Fix `avatar_url` in UserPresenter [\#14388](https://github.com/decidim/decidim/pull/14388)
- **decidim-participatory processes**: Related processes to process group help text [\#14439](https://github.com/decidim/decidim/pull/14439)
- **decidim-core**: Change deprecated user groups notifications to groups owners [\#14299](https://github.com/decidim/decidim/pull/14299)
- **decidim-admin**, **decidim-core**: QR share modal image [\#14447](https://github.com/decidim/decidim/pull/14447)
- **decidim-assemblies**, **decidim-core**: Evenly distrbuted content blocks [\#14460](https://github.com/decidim/decidim/pull/14460)
- **decidim-admin**: Prevent unhide resource that has a moderated parent [\#14303](https://github.com/decidim/decidim/pull/14303)
- **decidim-core**: Error displayed when accessing admin dashboard after a user deletes its account [\#14323](https://github.com/decidim/decidim/pull/14323)
- **decidim-proposals**: Fix proposal voting scenarios [\#14385](https://github.com/decidim/decidim/pull/14385)
- **decidim-core**: Fix nickname casing task and add validation in account edit form [\#14405](https://github.com/decidim/decidim/pull/14405)
- **decidim-generators**: Fix the releases notes after the Env Vars change [\#14452](https://github.com/decidim/decidim/pull/14452)
- **decidim-core**: Fix WCAG add nav tag to proposals dropdown menu [\#14440](https://github.com/decidim/decidim/pull/14440)
- **decidim-dev**: Fix admin pipeline with `welcome_notification_body` spec error [\#14475](https://github.com/decidim/decidim/pull/14475)
- **decidim-core**: Fix the storage URL generation [\#14450](https://github.com/decidim/decidim/pull/14450)
- **decidim-admin**, **decidim-assemblies**, **decidim-blogs**, **decidim-conferences**, **decidim-core**, **decidim-initiatives**, **decidim-participatory processes**, **decidim-proposals**: Fix image editor permissions for spaces' admins [\#13772](https://github.com/decidim/decidim/pull/13772)
- **decidim-core**, **decidim-proposals**: Disable tooltips due to poor performance [\#14515](https://github.com/decidim/decidim/pull/14515)
- **decidim-admin**: Align date and time inputs icons on forms [\#14507](https://github.com/decidim/decidim/pull/14507)
- **decidim-core**: Fix broken breadcrumb menu width on spaces [\#14509](https://github.com/decidim/decidim/pull/14509)
- **decidim-core**: Use better URI regexp to detect host part of blobs and prevent errors [\#14454](https://github.com/decidim/decidim/pull/14454)
- **decidim-core**: Fix error in announcement field when has a link with an attachment [\#14370](https://github.com/decidim/decidim/pull/14370)
- **decidim-core**, **decidim-proposals**: Fix spacing in proposal amendments [\#14530](https://github.com/decidim/decidim/pull/14530)
- **decidim-core**, **decidim-surveys**: Fix datetime format used to parse TimeWithZone attribute [\#14503](https://github.com/decidim/decidim/pull/14503)
- **decidim-core**: Fix missing image label in attachment [\#14532](https://github.com/decidim/decidim/pull/14532)
- **decidim-comments**: Add unique aria-label on comments list items for accessibility [\#14211](https://github.com/decidim/decidim/pull/14211)
- **decidim-core**, **decidim-debates**, **decidim-meetings**, **decidim-proposals**: Fix version visibility in resources [\#14493](https://github.com/decidim/decidim/pull/14493)
- **decidim-conferences**, **decidim-core**, **decidim-design**, **decidim-meetings**, **decidim-proposals**: Remove user tooltips in the application [\#14442](https://github.com/decidim/decidim/pull/14442)
- **decidim-verifications**: Fix missing label in verifications [\#14556](https://github.com/decidim/decidim/pull/14556)
- **decidim-assemblies**, **decidim-conferences**, **decidim-core**, **decidim-participatory processes**: Fix ransack error when visiting the process admins area [\#14542](https://github.com/decidim/decidim/pull/14542)
- **decidim-proposals**: Fix label on proposals landing page block [\#14494](https://github.com/decidim/decidim/pull/14494)
- **decidim-admin**, **decidim-core**: Fix missing details in moderators mailer [\#14555](https://github.com/decidim/decidim/pull/14555)
- **decidim-admin**, **decidim-comments**, **decidim-conferences**, **decidim-core**, **decidim-dev**, **decidim-initiatives**, **decidim-meetings**, **decidim-proposals**: Fix specs with no expectation [\#14508](https://github.com/decidim/decidim/pull/14508)
- **decidim-core**, **decidim-participatory processes**: Allow searching for participatory processes groups [\#14578](https://github.com/decidim/decidim/pull/14578)
- **decidim-admin**, **decidim-blogs**, **decidim-comments**, **decidim-core**, **decidim-debates**, **decidim-dev**, **decidim-initiatives**, **decidim-meetings**, **decidim-proposals**: Fix resource redirect after resource has been hidden [\#14553](https://github.com/decidim/decidim/pull/14553)
- **decidim-admin**, **decidim-core**: Fix parent hidden notification mailer explanation [\#14554](https://github.com/decidim/decidim/pull/14554)
- **decidim-core**: Fix project URL in QR share widget [\#14552](https://github.com/decidim/decidim/pull/14552)
- **decidim-proposals**: Allow admin users to see proposal votes on private spaces [\#14529](https://github.com/decidim/decidim/pull/14529)
- **decidim-core**: Remove `decidim:upgrade:clean:hidden_resources` task [\#14592](https://github.com/decidim/decidim/pull/14592)
- **decidim-proposals**: Show disabled button in proposals page when 'votes disabled' [\#14482](https://github.com/decidim/decidim/pull/14482)
- **decidim-core**: Fix digest emails to use organization timezone [\#14419](https://github.com/decidim/decidim/pull/14419)
- **decidim-assemblies**, **decidim-participatory processes**: Fix copy blocks when duplicating assemblies or spaces [\#14521](https://github.com/decidim/decidim/pull/14521)
- **decidim-core**, **decidim-debates**, **decidim-meetings**, **decidim-proposals**: Fix visibility of resources in QR Code controller [\#14534](https://github.com/decidim/decidim/pull/14534)
- **decidim-core**: The message textarea on Conversations page is missing an appropriate label [\#14167](https://github.com/decidim/decidim/pull/14167)
- **decidim-meetings**: Hide remaining slots counter after user registers for meetings [\#14599](https://github.com/decidim/decidim/pull/14599)
- **decidim-core**, **decidim-dev**, **decidim-meetings**: Fix meeting registration mail digest and user export [\#14437](https://github.com/decidim/decidim/pull/14437)
- **decidim-core**, **decidim-proposals**: Fix bug on history when resource's title is too long [\#14568](https://github.com/decidim/decidim/pull/14568)
- **decidim-budgets**: Fix crash when phase end_date is NULL when sending order reminders [\#14632](https://github.com/decidim/decidim/pull/14632)
- **decidim-core**: Separate manual and automatic moderation mails [\#14588](https://github.com/decidim/decidim/pull/14588)
- **decidim-core**: Hidden resource report translation [\#14646](https://github.com/decidim/decidim/pull/14646)
- **decidim-core**, **decidim-meetings**: Fix text in meeting show page [\#14566](https://github.com/decidim/decidim/pull/14566)
- **decidim-core**, **decidim-meetings**: Fix text in calendar share modal [\#14641](https://github.com/decidim/decidim/pull/14641)
- **decidim-blogs**: Fix attachment folder in Blogs when attachment disabled [\#14661](https://github.com/decidim/decidim/pull/14661)
- Fix warnings for documentation project [\#14665](https://github.com/decidim/decidim/pull/14665)
- **decidim-core**, **decidim-forms**, **decidim-surveys**: Fix export of a single survey answer [\#14638](https://github.com/decidim/decidim/pull/14638)
- **decidim-accountability**, **decidim-api**, **decidim-blogs**, **decidim-budgets**, **decidim-comments**, **decidim-core**, **decidim-debates**, **decidim-initiatives**, **decidim-meetings**, **decidim-pages**, **decidim-participatory processes**, **decidim-proposals**, **decidim-sortitions**, **decidim-surveys**: Add missing URL for resources in GraphQL API [\#14639](https://github.com/decidim/decidim/pull/14639)
- **decidim-core**: Fix pagination visibility issue [\#14499](https://github.com/decidim/decidim/pull/14499)
- **decidim-comments**: Fix comment refresh bug when replying [\#14637](https://github.com/decidim/decidim/pull/14637)
- **decidim-collaborative_texts**: Fix pipeline with Collaborative Text component url on API [\#14674](https://github.com/decidim/decidim/pull/14674)
- **decidim-admin**, **decidim-conferences**, **decidim-core**, **decidim-dev**, **decidim-meetings**: Require organization in `nicknamize` method [\#14669](https://github.com/decidim/decidim/pull/14669)
- **decidim-core**, **decidim-initiatives**: Fix home menu layout [\#14680](https://github.com/decidim/decidim/pull/14680)
- **decidim-budgets**, **decidim-core**, **decidim-dev**, **decidim-meetings**, **decidim-proposals**: Improve the map specs in order to avoid random failures [\#14679](https://github.com/decidim/decidim/pull/14679)
- **decidim-admin**, **decidim-proposals**: Add attachments button in proposals [\#14670](https://github.com/decidim/decidim/pull/14670)
- **decidim-core**: Generate a random nickname to ephemeral users [\#14691](https://github.com/decidim/decidim/pull/14691)
- **decidim-admin**, **decidim-assemblies**, **decidim-conferences**, **decidim-core**, **decidim-meetings**, **decidim-participatory processes**: Preview unpublished meetings as a process admin [\#14522](https://github.com/decidim/decidim/pull/14522)
- **decidim-core**: Fix pipeline after Crowdin update in `organization_spec.rb` [\#14709](https://github.com/decidim/decidim/pull/14709)
- **decidim-meetings**: Fix I18n scoping in Upcoming meeting event [\#14710](https://github.com/decidim/decidim/pull/14710)
- **decidim-core**: Fix script that synchronize migrations [\#14612](https://github.com/decidim/decidim/pull/14612)
- **decidim-admin**, **decidim-assemblies**, **decidim-conferences**, **decidim-participatory processes**: Collaborator view of deleted processes [\#14645](https://github.com/decidim/decidim/pull/14645)
- **decidim-elections**: Fix Decidim::Elections::Seeds [\#14729](https://github.com/decidim/decidim/pull/14729)
- Fix CORS instructions for cloud providers [\#14733](https://github.com/decidim/decidim/pull/14733)
- **decidim-conferences**, **decidim-core**, **decidim-meetings**: Fix warning for 'user-follow-line' icon [\#14740](https://github.com/decidim/decidim/pull/14740)
- **decidim-budgets**, **decidim-core**: Fix WCAG logo link description [\#14498](https://github.com/decidim/decidim/pull/14498)
- **decidim-core**: Fix accessibility in extra_data content_block cell in process show page [\#14730](https://github.com/decidim/decidim/pull/14730)
- **decidim-assemblies**, **decidim-participatory processes**: Fix order of participatory processes and assemblies [\#14737](https://github.com/decidim/decidim/pull/14737)
- **decidim-meetings**: Fix list of meetings' participants in mobile [\#14716](https://github.com/decidim/decidim/pull/14716)
- **decidim-core**: Withdrawn proposals/meetings displayed in the last activity feed [\#14712](https://github.com/decidim/decidim/pull/14712)
- **decidim-core**: Fix author's name display in posts in participatory process show page [\#14543](https://github.com/decidim/decidim/pull/14543)
- **decidim-accountability**: Fix accountability seeds with taxonomies [\#14743](https://github.com/decidim/decidim/pull/14743)
- **decidim-admin**: Fix javascript exception "countElement is null" [\#14756](https://github.com/decidim/decidim/pull/14756)
- **decidim-core**: Fix flaky spec in announcements [\#14773](https://github.com/decidim/decidim/pull/14773)
- **decidim-proposals**: Prevent importing withdrawn or moderated proposals to another component [\#14777](https://github.com/decidim/decidim/pull/14777)
- **decidim-core**: Fix missing for attribute on label and id on input [\#14807](https://github.com/decidim/decidim/pull/14807)
- **decidim-core**: Fix accessibility on filters label [\#14759](https://github.com/decidim/decidim/pull/14759)
- **decidim-core**, **decidim-proposals**: Fix get rid of preview alt [\#14788](https://github.com/decidim/decidim/pull/14788)
- **decidim-core**: Fix background color of default avatar image for accessibility [\#14772](https://github.com/decidim/decidim/pull/14772)
- **decidim-core**: Fix accessibility on svg in card metadata cell [\#14799](https://github.com/decidim/decidim/pull/14799)
- **decidim-core**, **decidim-debates**, **decidim-proposals**: Fix view mode active icon in proposals for accessibility [\#14779](https://github.com/decidim/decidim/pull/14779)
- **decidim-core**: Hide empty announcement block when no text is present [\#14775](https://github.com/decidim/decidim/pull/14775)
- **decidim-comments**: Fix opinion buttons on comments for accessibility [\#14781](https://github.com/decidim/decidim/pull/14781)
- **decidim-initiatives**: Fix flaky initiatives creation spec [\#14833](https://github.com/decidim/decidim/pull/14833)
- **decidim-core**: Re enable the localized specs [\#14711](https://github.com/decidim/decidim/pull/14711)
- **decidim-core**: Fix NoMethodError in Decidim::UploadValidationForm::AttachmentContextProxy [\#14814](https://github.com/decidim/decidim/pull/14814)
- **decidim-admin**: Fix questionnaires javascript on Rails 7.1 [\#14861](https://github.com/decidim/decidim/pull/14861)
- **decidim-ai**: Fix reporting user for multi tenant in decidim AI [\#14855](https://github.com/decidim/decidim/pull/14855)
- **decidim-core**: Fix flaky spec on comment example [\#14853](https://github.com/decidim/decidim/pull/14853)
- **decidim-core**: Fix report modals to improve accessibility [\#14844](https://github.com/decidim/decidim/pull/14844)
- **decidim-comments**: Fix Accessibility Like/Dislike Buttons on Comments [\#14837](https://github.com/decidim/decidim/pull/14837)
- **decidim-design**: Fix GH Action pipelines [\#14882](https://github.com/decidim/decidim/pull/14882)
- **decidim-conferences**: Fix grammar in conference admin registration count info [\#14891](https://github.com/decidim/decidim/pull/14891)
- **decidim-admin**: Fix filters for impersonatable users admin table [\#14913](https://github.com/decidim/decidim/pull/14913)
- **decidim-core**: Fix aria label in date pickers of meetings form [\#14204](https://github.com/decidim/decidim/pull/14204)
- **decidim-core**: Fix buttons on participants' profiles [\#14919](https://github.com/decidim/decidim/pull/14919)
- **decidim-core**: Fix structure of search page's filters [\#14789](https://github.com/decidim/decidim/pull/14789)
- **decidim-comments**: Add aria labels for comment 'like' and 'dislike' buttons [\#14905](https://github.com/decidim/decidim/pull/14905)
- **decidim-core**: Fix hidden content in "More information" [\#14888](https://github.com/decidim/decidim/pull/14888)
- **decidim-core**: Fix truncated document name [\#14862](https://github.com/decidim/decidim/pull/14862)
- **decidim-admin**: Fix admin visibility menu of insights [\#14896](https://github.com/decidim/decidim/pull/14896)
- **decidim-core**: Fix search filter area for accessibility [\#14950](https://github.com/decidim/decidim/pull/14950)
- **decidim-assemblies**, **decidim-participatory processes**: Fix importing attachments collections for processes and assemblies and process_groups [\#14880](https://github.com/decidim/decidim/pull/14880)
- **decidim-core**: Fix main bar dropdown container fo accessibility [\#14869](https://github.com/decidim/decidim/pull/14869)
- **decidim-core**: Breadcrumb mobile responsiveness nitpicks [\#14908](https://github.com/decidim/decidim/pull/14908)
- **decidim-core**: Fix specs running on local development environments [\#14959](https://github.com/decidim/decidim/pull/14959)
- **decidim-initiatives**: Events removal for followers in initiatives [\#14887](https://github.com/decidim/decidim/pull/14887)
- **decidim-collaborative_texts**, **decidim-elections**, **decidim-surveys**: Add missing component actions translations [\#14977](https://github.com/decidim/decidim/pull/14977)
- **decidim-accountability**, **decidim-admin**, **decidim-blogs**, **decidim-budgets**, **decidim-collaborative_texts**, **decidim-debates**, **decidim-elections**, **decidim-meetings**, **decidim-pages**, **decidim-proposals**, **decidim-sortitions**, **decidim-surveys**: Fix wrong permission name in surveys component [\#14940](https://github.com/decidim/decidim/pull/14940)
- **decidim-generators**: Fix AJAX requests after Rails 7.2 upgrade [\#14971](https://github.com/decidim/decidim/pull/14971)
- **decidim-dev**: Better defaults in test environment [\#14991](https://github.com/decidim/decidim/pull/14991)
- **decidim-blogs**, **decidim-core**, **decidim-participatory processes**: Participatory process card & blog post author fix [\#14978](https://github.com/decidim/decidim/pull/14978)
- **decidim-dev**, **decidim-templates**: Fix flaky spec on 'bulk proposal answer templates" [\#14992](https://github.com/decidim/decidim/pull/14992)
- **decidim-core**, **decidim-proposals**: Change default seeding strategy to have fast seeds [\#14985](https://github.com/decidim/decidim/pull/14985)
- **decidim-accountability**, **decidim-admin**, **decidim-assemblies**, **decidim-blogs**, **decidim-budgets**, **decidim-collaborative_texts**, **decidim-conferences**, **decidim-core**, **decidim-debates**, **decidim-demographics**, **decidim-elections**, **decidim-forms**, **decidim-initiatives**, **decidim-meetings**, **decidim-pages**, **decidim-participatory processes**, **decidim-proposals**, **decidim-sortitions**, **decidim-surveys**, **decidim-system**, **decidim-templates**, **decidim-verifications**: Add :unprocessable_entity state urls where form validation failed [\#15010](https://github.com/decidim/decidim/pull/15010)
- **decidim-core**: Sticky footer 404 page [\#14998](https://github.com/decidim/decidim/pull/14998)
- **decidim-meetings**: Fix meetings duplication feature [\#14943](https://github.com/decidim/decidim/pull/14943)
- Fix deploy for Netlify documentation project [\#15021](https://github.com/decidim/decidim/pull/15021)
- **decidim-proposals**: Fixed proposal creation for admin when "Participants can create proposals" is unchecked [\#15006](https://github.com/decidim/decidim/pull/15006)
- **decidim-generators**: Check if initiatives is installed within the example initializer [\#15056](https://github.com/decidim/decidim/pull/15056)
- **decidim-generators**: Define the generated app's sidekiq version based on the redis version [\#15055](https://github.com/decidim/decidim/pull/15055)
- **decidim-surveys**: Previewing questionnaires as a process admin [\#15063](https://github.com/decidim/decidim/pull/15063)
- **decidim-core**: Fix subscribe to newsletter when using omniauth [\#15000](https://github.com/decidim/decidim/pull/15000)
- Upgrade Chrome and ChromeDriver to 139.0.7258.66 [\#15067](https://github.com/decidim/decidim/pull/15067)
- **decidim-accountability**: Use proper translation in default taxonomy in accountability [\#15030](https://github.com/decidim/decidim/pull/15030)
- **decidim-core**: Fix callout/flash message announcement to the screen reader [\#15074](https://github.com/decidim/decidim/pull/15074)
- **decidim-comments**, **decidim-core**: Comments extra actions [\#15073](https://github.com/decidim/decidim/pull/15073)
- **decidim-core**: Fix accessibility in header  [\#15062](https://github.com/decidim/decidim/pull/15062)
- **decidim-core**: Change minimun_characters to minimum_characters [\#15038](https://github.com/decidim/decidim/pull/15038)
- **decidim-core**: Fix editor mention selection range when selecting item with mouse [\#15053](https://github.com/decidim/decidim/pull/15053)
- **decidim-admin**, **decidim-assemblies**, **decidim-conferences**, **decidim-initiatives**, **decidim-participatory processes**: Rename share_tokens to share_token in permissions [\#15084](https://github.com/decidim/decidim/pull/15084)
- **decidim-forms**: Error saving survey with empty mandatory fields [\#14997](https://github.com/decidim/decidim/pull/14997)
- **decidim-core**: Fix aria-current on active filter in search page [\#15088](https://github.com/decidim/decidim/pull/15088)
- **decidim-core**, **decidim-proposals**: Fix accessibility in footer [\#15065](https://github.com/decidim/decidim/pull/15065)
- **decidim-core**: Fix `TranslatedEtiquetteValidator` to use `Decidim.enable_etiquette_validator` setting [\#15092](https://github.com/decidim/decidim/pull/15092)
- **decidim-elections**: Fix failing spec in `admin_manages_elections_spec.rb` [\#15127](https://github.com/decidim/decidim/pull/15127)
- Remove `Platoniq/decidim-install` references [\#15130](https://github.com/decidim/decidim/pull/15130)
- Update documentation instructions for Ubuntu 24.04  [\#15138](https://github.com/decidim/decidim/pull/15138)
- Fixed formatting error in documentation [\#15144](https://github.com/decidim/decidim/pull/15144)
- **decidim-proposals**: Fix proposal cards render alt-text when PDF attached [\#15035](https://github.com/decidim/decidim/pull/15035)
- **decidim-assemblies**, **decidim-blogs**, **decidim-conferences**, **decidim-core**, **decidim-debates**, **decidim-meetings**, **decidim-participatory processes**, **decidim-proposals**, **decidim-surveys**: Fix so user can't update a meeting with empty body [\#14281](https://github.com/decidim/decidim/pull/14281)
- **decidim-api**: Refactor the API permissions [\#15116](https://github.com/decidim/decidim/pull/15116)
- **decidim-proposals**: Fix proposal pipeline [\#15154](https://github.com/decidim/decidim/pull/15154)
- **decidim-ai**: Fix `resource_hidden?` within decidim-ai [\#15108](https://github.com/decidim/decidim/pull/15108)
- **decidim-core**: Fix accessibility in breadcrumb_menu by replacing div and span by p [\#15123](https://github.com/decidim/decidim/pull/15123)
- **decidim-core**, **decidim-dev**, **decidim-proposals**: Refactor amendment permissions [\#15007](https://github.com/decidim/decidim/pull/15007)
- **decidim-core**, **decidim-newsletters**: Unsubscribed page redesign   [\#15156](https://github.com/decidim/decidim/pull/15156)
- **decidim-accountability**: Fix order of tabs in accountability's Projects [\#15181](https://github.com/decidim/decidim/pull/15181)
- **decidim-admin**, **decidim-core**: Tooltip displays partially off the screen [\#15075](https://github.com/decidim/decidim/pull/15075)
- **decidim-accountability**, **decidim-admin**, **decidim-assemblies**, **decidim-conferences**, **decidim-core**, **decidim-design**, **decidim-elections**, **decidim-participatory processes**: Trashable components when published [\#15179](https://github.com/decidim/decidim/pull/15179)
- **decidim-core**: Remove the word "new" in front of GDPR from the newsletter opt-in mail [\#15194](https://github.com/decidim/decidim/pull/15194)
- **decidim-core**: Fix 'Skip to main content' button visualization [\#15201](https://github.com/decidim/decidim/pull/15201)
- **decidim-core**: Fix size of the search button and contrast of the search form [\#15198](https://github.com/decidim/decidim/pull/15198)

### Removed

- **decidim-core**: Remove deprecated HERE maps configuration [\#14181](https://github.com/decidim/decidim/pull/14181)
- **decidim-conferences**, **decidim-core**, **decidim-design**, **decidim-meetings**, **decidim-proposals**: Remove user tooltips in the application [\#14442](https://github.com/decidim/decidim/pull/14442)
- **decidim-accountability**, **decidim-budgets**, **decidim-generators**, **decidim-meetings**: Remove `enable_proposal_linking` setting [\#14453](https://github.com/decidim/decidim/pull/14453)
- **decidim-admin**, **decidim-ai**, **decidim-api**, **decidim-assemblies**, **decidim-blogs**, **decidim-comments**, **decidim-conferences**, **decidim-core**, **decidim-debates**, **decidim-dev**, **decidim-elections**, **decidim-initiatives**, **decidim-meetings**, **decidim-participatory processes**, **decidim-proposals**: Remove hashtags fields (part 1) [\#14803](https://github.com/decidim/decidim/pull/14803)
- **decidim-accountability**, **decidim-admin**, **decidim-budgets**, **decidim-collaborative_texts**, **decidim-core**, **decidim-debates**, **decidim-meetings**, **decidim-participatory processes**, **decidim-proposals**: Remove hashtags fields (part 2)  [\#14868](https://github.com/decidim/decidim/pull/14868)
- **decidim-initiatives**: Events removal for followers in initiatives [\#14887](https://github.com/decidim/decidim/pull/14887)

### Developer improvements

- Refactor specs paths for `decidim-api` examples [\#14246](https://github.com/decidim/decidim/pull/14246)
- Transform user groups into regular users [\#14130](https://github.com/decidim/decidim/pull/14130)
- Fix alignment of sorting options on projects [\#14362](https://github.com/decidim/decidim/pull/14362)
- Change deprecated user groups notifications to groups owners [\#14299](https://github.com/decidim/decidim/pull/14299)
- Fix specs running on local development environments [\#14959](https://github.com/decidim/decidim/pull/14959)
- Add :unprocessable_entity state urls where form validation failed [\#15010](https://github.com/decidim/decidim/pull/15010)
- Bump versions in npm packages [\#15023](https://github.com/decidim/decidim/pull/15023)
- Refactor the inputMention widget [\#15034](https://github.com/decidim/decidim/pull/15034)
- Refactor the CopyToClipboard widget [\#15033](https://github.com/decidim/decidim/pull/15033)
- Meetings permissions refactor [\#14501](https://github.com/decidim/decidim/pull/14501)
- Refactor amendment permissions [\#15007](https://github.com/decidim/decidim/pull/15007)

### Internal

- Change release candidate instructions in Releases internal documentation [\#14066](https://github.com/decidim/decidim/pull/14066)
- **decidim-core**: Add extra details to decidim:upgrade:migrations task [\#14125](https://github.com/decidim/decidim/pull/14125)
- **decidim-generators**: Bump rails from v7.0.8.4 to v7.0.8.7 [\#14166](https://github.com/decidim/decidim/pull/14166)
- **decidim-generators**, **decidim-proposals**: Bump doc2text from v0.4.7 to v0.4.8 [\#14165](https://github.com/decidim/decidim/pull/14165)
- Ignore rule 'no duplicate header' for markdown linter [\#14206](https://github.com/decidim/decidim/pull/14206)
- **decidim-accountability**, **decidim-admin**, **decidim-ai**, **decidim-api**, **decidim-assemblies**, **decidim-blogs**, **decidim-budgets**, **decidim-collaborative_texts**, **decidim-comments**, **decidim-conferences**, **decidim-core**, **decidim-debates**, **decidim-design**, **decidim-dev**, **decidim-forms**, **decidim-generators**, **decidim-initiatives**, **decidim-meetings**, **decidim-pages**, **decidim-participatory processes**, **decidim-proposals**, **decidim-sortitions**, **decidim-surveys**, **decidim-system**, **decidim-templates**, **decidim-verifications**: Add tests for private participatory spaces [\#13854](https://github.com/decidim/decidim/pull/13854)
- **decidim-generators**: Update node version from v18 to v22 [\#14224](https://github.com/decidim/decidim/pull/14224)
- Add well known file needed from <https://decidim.org/funding.json> [\#14243](https://github.com/decidim/decidim/pull/14243)
- **decidim-proposals**: Add more configurations on proposals with seeds [\#14268](https://github.com/decidim/decidim/pull/14268)
- Make backporter trigger when unlabeling PRs [\#14292](https://github.com/decidim/decidim/pull/14292)
- Add `publiccode.yml` standard file [\#14367](https://github.com/decidim/decidim/pull/14367)
- Add advanced configuration for CodeQL [\#14359](https://github.com/decidim/decidim/pull/14359)
- **decidim-api**: Add test for API docs version disclosure [\#14403](https://github.com/decidim/decidim/pull/14403)
- Add localization documentation page [\#14400](https://github.com/decidim/decidim/pull/14400)
- **decidim-accountability**, **decidim-admin**, **decidim-assemblies**, **decidim-budgets**, **decidim-comments**, **decidim-core**, **decidim-debates**, **decidim-generators**, **decidim-meetings**, **decidim-participatory processes**, **decidim-proposals**, **decidim-surveys**: Remove Metrics feature [\#14387](https://github.com/decidim/decidim/pull/14387)
- Fix templates workflow configuration [\#14413](https://github.com/decidim/decidim/pull/14413)
- **decidim-admin**: Do not show a CSP warning during admin edits organization spec [\#14414](https://github.com/decidim/decidim/pull/14414)
- **decidim-accountability**, **decidim-api**, **decidim-budgets**, **decidim-core**, **decidim-generators**, **decidim-initiatives**, **decidim-meetings**, **decidim-proposals**, **decidim-system**, **decidim-verifications**: Migrate `Rails.application.secrets` to Environment Variables [\#13268](https://github.com/decidim/decidim/pull/13268)
- **decidim-conferences**, **decidim-core**, **decidim-forms**, **decidim-initiatives**, **decidim-meetings**, **decidim-proposals**, **decidim-surveys**, **decidim-verifications**: Change Digest::MD5 to Digest::SHA256 [\#14426](https://github.com/decidim/decidim/pull/14426)
- **decidim-core**: Disable webpack live reload [\#14441](https://github.com/decidim/decidim/pull/14441)
- **decidim-generators**: Fix the releases notes after the Env Vars change [\#14452](https://github.com/decidim/decidim/pull/14452)
- **decidim-dev**: Fix admin pipeline with `welcome_notification_body` spec error [\#14475](https://github.com/decidim/decidim/pull/14475)
- **decidim-proposals**: Fix flaky spec on proposal filters [\#14474](https://github.com/decidim/decidim/pull/14474)
- **decidim-accountability**, **decidim-assemblies**, **decidim-blogs**, **decidim-budgets**, **decidim-collaborative_texts**, **decidim-conferences**, **decidim-core**, **decidim-debates**, **decidim-initiatives**, **decidim-meetings**, **decidim-participatory processes**, **decidim-proposals**, **decidim-surveys**: Implement FAST_SEEDS env var for improving seeds times [\#14528](https://github.com/decidim/decidim/pull/14528)
- Update supported versions in Security policy with v0.27 deprecation message [\#14624](https://github.com/decidim/decidim/pull/14624)
- **decidim-budgets**, **decidim-core**, **decidim-dev**, **decidim-meetings**, **decidim-proposals**: Improve the map specs in order to avoid random failures [\#14679](https://github.com/decidim/decidim/pull/14679)
- **decidim-accountability**, **decidim-admin**, **decidim-budgets**, **decidim-core**, **decidim-debates**, **decidim-dev**, **decidim-meetings**, **decidim-proposals**, **decidim-surveys**: Update ChromeDriver to 136.0.7103.92 [\#14455](https://github.com/decidim/decidim/pull/14455)
- **decidim-dev**: Assign expected ports for parallel tests [\#14693](https://github.com/decidim/decidim/pull/14693)
- **decidim-core**, **decidim-generators**, **decidim-initiatives**, **decidim-proposals**: Change framework defaults from Rails v6.1 to v7.0 [\#14735](https://github.com/decidim/decidim/pull/14735)
- **decidim-accountability**, **decidim-admin**, **decidim-api**, **decidim-assemblies**, **decidim-blogs**, **decidim-budgets**, **decidim-collaborative_texts**, **decidim-comments**, **decidim-conferences**, **decidim-core**, **decidim-debates**, **decidim-dev**, **decidim-forms**, **decidim-generators**, **decidim-initiatives**, **decidim-meetings**, **decidim-participatory processes**, **decidim-proposals**, **decidim-sortitions**, **decidim-surveys**, **decidim-system**, **decidim-templates**, **decidim-verifications**: Update Rails to v7.1 [\#13267](https://github.com/decidim/decidim/pull/13267)
- **decidim-core**: Fix flaky spec in announcements [\#14773](https://github.com/decidim/decidim/pull/14773)
- **decidim-proposals**: Fix proposal deprecation warning for state alias [\#14785](https://github.com/decidim/decidim/pull/14785)
- **decidim-ai**, **decidim-blogs**, **decidim-comments**, **decidim-core**, **decidim-dev**, **decidim-generators**, **decidim-initiatives**, **decidim-proposals**: Update Rails to v7.2 [\#14784](https://github.com/decidim/decidim/pull/14784)
- **decidim-collaborative_texts**, **decidim-core**, **decidim-elections**, **decidim-forms**, **decidim-initiatives**, **decidim-meetings**, **decidim-proposals**: Fix enum deprecation warnings as result of Rails 7.2 upgrade  [\#14823](https://github.com/decidim/decidim/pull/14823)
- **decidim-admin**, **decidim-core**: Add Rails 7.2 framework defaults file [\#14829](https://github.com/decidim/decidim/pull/14829)
- Patch release notes to add new info about local secrets [\#14831](https://github.com/decidim/decidim/pull/14831)
- Bump @rails/activestorage npm package from v7.0 to v7.2 [\#14830](https://github.com/decidim/decidim/pull/14830)
- Add run id to screenshots folder [\#14857](https://github.com/decidim/decidim/pull/14857)
- **decidim-accountability**, **decidim-core**: Fix flaky spec in accountability API integration schema spec [\#14852](https://github.com/decidim/decidim/pull/14852)
- **decidim-core**, **decidim-generators**: Use Rails 7.2 defaults [\#14851](https://github.com/decidim/decidim/pull/14851)
- **decidim-generators**: Update codecov-action from v4 to v5 [\#14860](https://github.com/decidim/decidim/pull/14860)
- **decidim-dev**: Disable rspec's profile examples in CI [\#14867](https://github.com/decidim/decidim/pull/14867)
- **decidim-design**: Fix GH Action pipelines [\#14882](https://github.com/decidim/decidim/pull/14882)
- **decidim-core**, **decidim-generators**, **decidim-meetings**: Update patch versions of gem dependencies [\#14850](https://github.com/decidim/decidim/pull/14850)
- **decidim-conferences**: Fix grammar in conference admin registration count info [\#14891](https://github.com/decidim/decidim/pull/14891)
- **decidim-accountability**, **decidim-admin**, **decidim-ai**, **decidim-api**, **decidim-assemblies**, **decidim-blogs**, **decidim-collaborative_texts**, **decidim-comments**, **decidim-conferences**, **decidim-core**, **decidim-debates**, **decidim-dev**, **decidim-elections**, **decidim-forms**, **decidim-generators**, **decidim-initiatives**, **decidim-meetings**, **decidim-participatory processes**, **decidim-proposals**, **decidim-system**, **decidim-verifications**: No longer generate the initializer files [\#14832](https://github.com/decidim/decidim/pull/14832)
- **decidim-core**: Fix specs running on local development environments [\#14959](https://github.com/decidim/decidim/pull/14959)
- Migrate from CodeClimate to QLTY [\#14973](https://github.com/decidim/decidim/pull/14973)
- **decidim-comments**, **decidim-core**, **decidim-dev**, **decidim-generators**: Update the Rubocop setup on Decidim [\#14976](https://github.com/decidim/decidim/pull/14976)
- **decidim-api**, **decidim-generators**: Bump graphql to 2.4.17 [\#14979](https://github.com/decidim/decidim/pull/14979)
- **decidim-accountability**, **decidim-blogs**, **decidim-budgets**, **decidim-collaborative_texts**, **decidim-core**, **decidim-debates**, **decidim-dev**, **decidim-elections**, **decidim-initiatives**, **decidim-meetings**, **decidim-participatory processes**, **decidim-proposals**, **decidim-sortitions**: Remove some of the hashtag params [\#14921](https://github.com/decidim/decidim/pull/14921)
- **decidim-comments**, **decidim-core**, **decidim-dev**, **decidim-generators**: Bump rubocop-graphql from v1.5.4 to v1.5.6 [\#14986](https://github.com/decidim/decidim/pull/14986)
- **decidim-admin**, **decidim-comments**, **decidim-conferences**, **decidim-core**, **decidim-design**, **decidim-dev**, **decidim-elections**, **decidim-initiatives**, **decidim-meetings**, **decidim-proposals**, **decidim-system**, **decidim-templates**: Remove SCSS `@import` statements [\#14982](https://github.com/decidim/decidim/pull/14982)
- **decidim-core**, **decidim-proposals**: Change default seeding strategy to have fast seeds [\#14985](https://github.com/decidim/decidim/pull/14985)
- Fix deploy for Netlify documentation project [\#15021](https://github.com/decidim/decidim/pull/15021)
- Bump versions in npm packages [\#15023](https://github.com/decidim/decidim/pull/15023)
- **decidim-generators**: Bump versions in gems [\#15024](https://github.com/decidim/decidim/pull/15024)
- **decidim-comments**, **decidim-core**: Refactor the inputMention widget [\#15034](https://github.com/decidim/decidim/pull/15034)
- **decidim-core**: Refactor the CopyToClipboard widget [\#15033](https://github.com/decidim/decidim/pull/15033)
- **decidim-accountability**, **decidim-admin**, **decidim-api**, **decidim-budgets**, **decidim-collaborative_texts**, **decidim-comments**, **decidim-core**, **decidim-forms**, **decidim-initiatives**, **decidim-meetings**, **decidim-proposals**, **decidim-system**: Refactor javascript in decidim core (Part 1) [\#15045](https://github.com/decidim/decidim/pull/15045)
- Versions update docs [\#15060](https://github.com/decidim/decidim/pull/15060)
- Update 0.28 maintance status [\#15061](https://github.com/decidim/decidim/pull/15061)
- **decidim-admin**, **decidim-blogs**, **decidim-comments**, **decidim-conferences**, **decidim-core**, **decidim-design**, **decidim-dev**, **decidim-forms**, **decidim-meetings**, **decidim-system**: Refactor javascript in decidim core (Part 2) [\#15064](https://github.com/decidim/decidim/pull/15064)
- Upgrade Chrome and ChromeDriver to 139.0.7258.66 [\#15067](https://github.com/decidim/decidim/pull/15067)
- **decidim-core**, **decidim-generators**: Bump rails to v7.2.2.2 [\#15126](https://github.com/decidim/decidim/pull/15126)
- **decidim-accountability**, **decidim-admin**, **decidim-api**, **decidim-assemblies**, **decidim-blogs**, **decidim-budgets**, **decidim-collaborative_texts**, **decidim-comments**, **decidim-conferences**, **decidim-core**, **decidim-debates**, **decidim-demographics**, **decidim-design**, **decidim-dev**, **decidim-elections**, **decidim-forms**, **decidim-generators**, **decidim-initiatives**, **decidim-meetings**, **decidim-pages**, **decidim-participatory processes**, **decidim-proposals**, **decidim-sortitions**, **decidim-surveys**, **decidim-system**, **decidim-templates**, **decidim-verifications**: Bump shakapacker to v8.3.0 [\#15016](https://github.com/decidim/decidim/pull/15016)
- **decidim-accountability**, **decidim-admin**, **decidim-assemblies**, **decidim-budgets**, **decidim-comments**, **decidim-conferences**, **decidim-core**, **decidim-debates**, **decidim-design**, **decidim-elections**, **decidim-forms**, **decidim-initiatives**, **decidim-participatory processes**, **decidim-proposals**: Refactor javascript in decidim core (Part 3) [\#15091](https://github.com/decidim/decidim/pull/15091)
- **decidim-core**: Remove the word "new" in front of GDPR from the newsletter opt-in mail [\#15194](https://github.com/decidim/decidim/pull/15194)

### Unsorted

- 91527ce1b1 Initialize collaborative texts module (#13978) [\#13978](https://github.com/decidim/decidim/pull/13978)
- 854b669167 Improve merge proposals functionality (#13732) [\#13732](https://github.com/decidim/decidim/pull/13732)
- c2d61a5d33 Improve accountability results visualization (#14067) [\#14067](https://github.com/decidim/decidim/pull/14067)
- 6633e867f9 Enhance initiative creation wizard (#13952) [\#13952](https://github.com/decidim/decidim/pull/13952)
- 8bb3db0c7b Add taxonomies and attachments to posts (#14085) [\#14085](https://github.com/decidim/decidim/pull/14085)
- 607f260db5 Add QR code for share modal (#14086) [\#14086](https://github.com/decidim/decidim/pull/14086)
- 87f8900b9f Add admin UI for "Collaborative Texts" component (#14013) [\#14013](https://github.com/decidim/decidim/pull/14013)
- 3b6cb076e3 Split the survey admin interface in tabs (#14182) [\#14182](https://github.com/decidim/decidim/pull/14182)
- 2ef9884a74 Change secondary buttons to transparent in admin panel (#14249) [\#14249](https://github.com/decidim/decidim/pull/14249)
- b1e109f146 Force api authentication with configuration (#14238) [\#14238](https://github.com/decidim/decidim/pull/14238)
- 6e4667550d Change the 'choose template' page for questionnaires to a two column design (#14274) [\#14274](https://github.com/decidim/decidim/pull/14274)
- 7792e21c7a Delete inactive user accounts (#13882) [\#13882](https://github.com/decidim/decidim/pull/13882)
- 6a2ceba2bc Add metadata for each resource in the Open Data README (#13776) [\#13776](https://github.com/decidim/decidim/pull/13776)
- ecb8dbe6b0 Update of the API GraphQL (#13986) [\#13986](https://github.com/decidim/decidim/pull/13986)
- 062422df50 Add body and versioning to collaborative texts documents (#14084) [\#14084](https://github.com/decidim/decidim/pull/14084)
- c6b727d4bb Allow meeting addresses to be unset/TBD (#14389) [\#14389](https://github.com/decidim/decidim/pull/14389)
- ac02619079 Improve the digital signature process for initiatives (#13729) [\#13729](https://github.com/decidim/decidim/pull/13729)
- d9bf1b3f08 Implement share and download buttons in budget successful vote screen (#14283) [\#14283](https://github.com/decidim/decidim/pull/14283)
- 8e46e9385f Manage uploaded census records in the admin panel (#13850) [\#13850](https://github.com/decidim/decidim/pull/13850)
- f2a0e37bd7 Manage meetings registations with QR codes (#14298) [\#14298](https://github.com/decidim/decidim/pull/14298)
- 9f88df2484 Implement focus mode in the budget projects component (#14512) [\#14512](https://github.com/decidim/decidim/pull/14512)
- d6d5384c3a Add proposal autocomplete in editor (#14184) [\#14184](https://github.com/decidim/decidim/pull/14184)
- d99fb35721 Waiting list for the meeting (#14492) [\#14492](https://github.com/decidim/decidim/pull/14492)
- a082c8d62d Init elections module (#14560) [\#14560](https://github.com/decidim/decidim/pull/14560)
- acd4dd9c29 Standardize statistics (#14360) [\#14360](https://github.com/decidim/decidim/pull/14360)
- 30ce201502 Add frontend interaction to collaborative texts (#14137) [\#14137](https://github.com/decidim/decidim/pull/14137)
- 157b49d894 Fix bug on statistic counter height and position (#14664) [\#14664](https://github.com/decidim/decidim/pull/14664)
- 49a1c15e2a Change styles and other details in Surveys' admin form (#14436) [\#14436](https://github.com/decidim/decidim/pull/14436)
- df7efcbc8f Customizing meeting reminders (#14470) [\#14470](https://github.com/decidim/decidim/pull/14470)
- cd550d45c8 Add election model and admin interface (#14605) [\#14605](https://github.com/decidim/decidim/pull/14605)
- b16dca214f Add Grafana integration documentation and examples (#14659) [\#14659](https://github.com/decidim/decidim/pull/14659)
- 832ed5e2be Update API fields for component resources (#14644) [\#14644](https://github.com/decidim/decidim/pull/14644)
- 924e383918 Update API fields for space resources (#14648) [\#14648](https://github.com/decidim/decidim/pull/14648)
- 0da35c615f Implement dropdown menu for actions in spaces index pages (#14805) [\#14805](https://github.com/decidim/decidim/pull/14805)
- a1ee0c8836 Add question and answer models and admin interface for elections (#14696) [\#14696](https://github.com/decidim/decidim/pull/14696)
- 91ee3a7923 Implement dropdown menu for other actions in spaces (#14863) [\#14863](https://github.com/decidim/decidim/pull/14863)
- 85bf2270b5 Add possibility to automatically hide reported spam content (#14870) [\#14870](https://github.com/decidim/decidim/pull/14870)
- 9c7800ba90 Implement dropdown menu for components (part 2) (#14883) [\#14883](https://github.com/decidim/decidim/pull/14883)
- f0a8ea620c Trigger login event on omniauth login (#14865) [\#14865](https://github.com/decidim/decidim/pull/14865)
- 36bfd4a964 Implement dropdown menu for components (part 1) (#14872) [\#14872](https://github.com/decidim/decidim/pull/14872)
- 07e6eb7612 Implement dropdown menu for verifications and templates modules (#14914) [\#14914](https://github.com/decidim/decidim/pull/14914)
- 542911c2c4 Implement dropdown menu for admin module (part 1) (#14897) [\#14897](https://github.com/decidim/decidim/pull/14897)
- 3024a202cf Implement dropdown menu for admin module (part 2) (#14916) [\#14916](https://github.com/decidim/decidim/pull/14916)
- c4c55bf125 Add Census to Elections component (#14783) [\#14783](https://github.com/decidim/decidim/pull/14783)
- aaa33412bd Implement dropdown menu for taxonomies (#14920) [\#14920](https://github.com/decidim/decidim/pull/14920)
- f52501dd64 Add API authentication possibility (#14225) [\#14225](https://github.com/decidim/decidim/pull/14225)
- db3bc654d2 Add demographics collection module (#14486) [\#14486](https://github.com/decidim/decidim/pull/14486)
- fb90a5017b Add Democratic participation indicator content block (#14418) [\#14418](https://github.com/decidim/decidim/pull/14418)
- 2142fa807d Implement dropdown menu for last actions and clean-up  (#14933) [\#14933](https://github.com/decidim/decidim/pull/14933)
- 064d5b4c83 Add an election dashboard (#14859) [\#14859](https://github.com/decidim/decidim/pull/14859)
- 8d32a9b277 Add new turbo:load event (#15011) [\#15011](https://github.com/decidim/decidim/pull/15011)
- e713f35ce6 Implement publish & unpublish actions in spaces (#15008) [\#15008](https://github.com/decidim/decidim/pull/15008)
- 38cd0f8b69 Change the accordion data selector from component to controller (#15028) [\#15028](https://github.com/decidim/decidim/pull/15028)
- 44643377bd Change the dropdown data selector from component to controller (#15027) [\#15027](https://github.com/decidim/decidim/pull/15027)
- 7c74f440c0 Write API: log actions for the API users (#14960) [\#14960](https://github.com/decidim/decidim/pull/14960)
- da653b2a5e Search and display component elections (#15025) [\#15025](https://github.com/decidim/decidim/pull/15025)
- d845ff4a3e Write API: add answer proposals (#14881) [\#14881](https://github.com/decidim/decidim/pull/14881)
- 7256769aa5 Voting booth in an Election (#14915) [\#14915](https://github.com/decidim/decidim/pull/14915)
- ff4b25cec3 Implements enhacements in Budgets (#14903) [\#14903](https://github.com/decidim/decidim/pull/14903)

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

Nothing.

...

## Previous versions

Please check [0.30-stable](https://github.com/decidim/decidim/blob/release/0.30-stable/CHANGELOG.md) for previous changes.
