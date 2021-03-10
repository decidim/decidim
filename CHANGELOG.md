# Change Log

## [0.23.4](https://github.com/decidim/decidim/tree/v0.23.4)

**Added**

**Changed**

**Fixed**

- **decidim-admin**: Fix and tests to avoid registered users being invited again [\#7455](https://github.com/decidim/decidim/pull/7455)
- **decidim-proposals**: Fix the proposal body validation error messages [\#7495](https://github.com/decidim/decidim/pull/7495)
- **decidim-admin**: Only share tokens if component exists [\#7503](https://github.com/decidim/decidim/pull/7503)
- **decidim-core**: Invalidate all user sessions when destroying the account [\#7510](https://github.com/decidim/decidim/pull/7510)
- **decidim-core**: Fix user profile timeline activity cards texts showing "New resource" on updates [\#7559](https://github.com/decidim/decidim/pull/7559)
- **decidim-core**: Sanitize address inputs [\#7577](https://github.com/decidim/decidim/pull/7577)

**Removed**

## [0.23.3](https://github.com/decidim/decidim/tree/v0.23.3)

**Added**

- **decidim-initiatives**: Raise an alert when there's an error signing an initiative [\#7407](https://github.com/decidim/decidim/pull/7407)
- **decidim-proposals**: Let admins delete proposal attachments [\#7435](https://github.com/decidim/decidim/pull/7435)

**Changed**

**Fixed**

- **decidim-initiatives**: Fix initiatives type permissions page [\#7357](https://github.com/decidim/decidim/pull/7357)
- **decidim-meetings**: Fix etherpad compatibility for old meetings [\#7387](https://github.com/decidim/decidim/pull/7387)
- **decidim-core**: Fix subhero content block removing strip_tags from it [\#7414](https://github.com/decidim/decidim/pull/7414)

**Removed**

## [0.23.2](https://github.com/decidim/decidim/tree/v0.23.2)

**Added**

**Changed**

**Fixed**

- **decidim-admin**: Allow selecting multiple files on gallery forms [\#7064](https://github.com/decidim/decidim/pull/7064)
- **decidim-proposals**: Fix proposals admin form when editing. Closes #7031 (#7042) [\#7051](https://github.com/decidim/decidim/pull/7051)
- **decidim-admin**, **decidim-assemblies**, **decidim-core**: Add some missing i18n keys (#7039) [\#7043](https://github.com/decidim/decidim/pull/7043)
- **decidim-participatory_processes**: Fix ParticipatoryProcess metrics ajax call in show (#6971) [\#6977](https://github.com/decidim/decidim/pull/6977)
- **decidim-core**: Backport "Fix newsletter html containing style tag content" to 0.23-stable [\#6963](https://github.com/decidim/decidim/pull/6963)
- **decidim-core**, **decidim-meetings**: Backport to 0.23-stable release of fix access to detail on a visible meeting [\#6934](https://github.com/decidim/decidim/pull/6934)
- **decidim-meetings**: Backport to 0.23-stable release of fix visible_meetings_for scope [\#6932](https://github.com/decidim/decidim/pull/6932)
- **decidim-all**: Fix broken dashboard action logs under certain conditions (#6857) [\#6930](https://github.com/decidim/decidim/pull/6930)
- **decidim-assemblies**, **decidim-core**, **decidim-dev**: Fix traceability logs with invalid record (#6879) [\#6928](https://github.com/decidim/decidim/pull/6928)
- **decidim-forms**: Backport "Fix mixing answers exports and admin management in questionnaires" to v0.23 [\#6906](https://github.com/decidim/decidim/pull/6906)
- **decidim-templates**: Backport "Fix decidim-templates gem definition to include templates migrations" to v0.23 [\#6900](https://github.com/decidim/decidim/pull/6900)
- **decidim-core**, **decidim-dev**, **decidim-system**: Backport 'Correct smtp_settings keys type #6908' on release/0.23-stable [\#6904](https://github.com/decidim/decidim/pull/6904)
- **decidim-admin**, **decidim-core**: Fix newsletter delivery issue to all recipients with no scopes (#6875) [\#6909](https://github.com/decidim/decidim/pull/6909)
- **decidim-core**: Backport 'backport smtp settings correction' to 0.23 [\#6877](https://github.com/decidim/decidim/pull/6877)
- **decidim-all**: Backport "Add margin between back link and title" to v0.23 [\#6858](https://github.com/decidim/decidim/pull/6858)
- **decidim-admin**: Backport "Fix color text on unpublish button" to v0.23 [\#6848](https://github.com/decidim/decidim/pull/6848)
- **decidim-blogs**: Backport Add logic in view to prevent visual error in blog post [\#7278](https://github.com/decidim/decidim/pull/7278)
- **decidim-consultations**: Backport 'Restore consultation's description rich text format' to v0.23 [\#7219](https://github.com/decidim/decidim/pull/7219)
- **decidim-admin**, **decidim-budgets**, **decidim-comments**, **decidim-core**, **decidim-debates**, **decidim-dev**, **decidim-proposals**: Backport "Fix comments newsletter participant ids" to v0.23 [\#7184](https://github.com/decidim/decidim/pull/7184)
- **decidim-core**: Quickfix bug in seeds for 0.23-stable [\#7061](https://github.com/decidim/decidim/pull/7061)
- **decidim-participatory_processes**: Fix space private user in process admin [\#7073](https://github.com/decidim/decidim/pull/7073)
- **decidim-core**: Backport "fix avoid removing tag style on custom sanitize" to v0.23-stable [\#7019](https://github.com/decidim/decidim/pull/7019)
- **decidim-admin**, **decidim-core**: Fix editor image alt tag (#6920) [\#6990](https://github.com/decidim/decidim/pull/6990)
- **decidim-meetings**: Backport "Fix visible_meeting_for scope if Decidim::Conference is not defined" to v0.23 [\#6980](https://github.com/decidim/decidim/pull/6980)
- **decidim-admin**, **decidim-core**: Backport "Fix private participants pagination crash" [\#7000](https://github.com/decidim/decidim/pull/7000)
- **decidim-core**: Remove sticky from tos agreement (#6716) [\#6954](https://github.com/decidim/decidim/pull/6954)
- **decidim-admin**, **decidim-assemblies**, **decidim-participatory_processes**: Allow admin to be registered as a participatory space user [\#7316](https://github.com/decidim/decidim/pull/7316)
- **decidim-core**: Fixing error caused by Missing Organization [\#7317](https://github.com/decidim/decidim/pull/7317)
- **decidim-core**: Adding Organization scopes to uploaders [\#7318](https://github.com/decidim/decidim/pull/7318)
- **decidim-core**, **decidim-forms**, **decidim-meetings**: Fix security token generation in anonymous surveys and pads [\#7327](https://github.com/decidim/decidim/pull/7327)

**Removed**

## [0.23.1](https://github.com/decidim/decidim/tree/v0.23.1)

**Added**

**Changed**

**Fixed**

- **decidim-core**: Fix searchable issues with resources with unexisting organization (#6839) [\#6843](https://github.com/decidim/decidim/pull/6843)
- **decidim-proposals**: Fix issues with move proposal fields to i18n (#6838) [\#6842](https://github.com/decidim/decidim/pull/6842)
- **decidim-forms**: Backport "fix display conditions validations with choices" to 0.23 [\#6840](https://github.com/decidim/decidim/pull/6840)
- **decidim-budgets**: Backport "Fix broken notifications page due to multi-budget changes" to 0.23 [\#6840](https://github.com/decidim/decidim/pull/6840)
- **decidim-core**, **decidim-surveys**: Fix dependency between surveys and templates [\#6814](https://github.com/decidim/decidim/pull/6814)

**Removed**

## [0.23.0](https://github.com/decidim/decidim/tree/v0.23.0)

## Upgrade Notes

- **Bump Ruby to v2.6**

As per [\#6320](https://github.com/decidim/decidim/pull/6320) we've bumped the minimum Ruby version to 2.6.6.

- **Stable branches nomenclature changes**

Since this release we're changing the branch nomenclature for stable branches. Until now we were using `x.y-stable`, now we will use `release/x.y-stable`.
Legacy names for stable branches will be kept for a while but won't be created anymore, so new releases won't have the old `x.y-stable` nomenclature.

The plan is to keep new and old nomenclatures until the release of v0.25, so they will coexist until that release.
When releasing v0.25 all stable branches with the nomenclature `x.y-stable` will be removed.

- **Maps**

Maps functionality is now fully configurable. It defaults to HERE Maps as you'd expect when upgrading from an older version and it works still fine with your legacy style geocoder configuration after the update. This is, however, deprecated and it is highly recommended to define your maps configuration with the new style:

```ruby
# Before:
Decidim.configure do |config|
  config.geocoder = {
    static_map_url: "https://image.maps.ls.hereapi.com/mia/1.6/mapview",
    here_api_key: Rails.application.secrets.geocoder[:here_api_key],
    timeout: 5,
    units: :km
  }
end

# After (remember to also update your secrets):
Decidim.configure do |config|
  config.maps = {
    provider: :here,
    api_key: Rails.application.secrets.maps[:api_key],
    static: { url: "https://image.maps.ls.hereapi.com/mia/1.6/mapview" }
  }
  config.geocoder = {
    timeout: 5,
    units: :km
  }
end
```

- **Debates and Comments are now in global search**

Debates and Comments have been added to the global search and need to be
indexed, otherwise all previous content won't be available as search results.
You should run this in a Rails console at your server or create a migration to
do it.

Please be aware that it could take a while if your database has a lot of
content.

```ruby
  Decidim::Comments::Comment.find_each(&:try_update_index_for_search_resource)
  Decidim::Debates::Debate.find_each(&:try_update_index_for_search_resource)
```

- **Settings `maximum_attachment_size` and `maximum_avatar_size` moved to organization system settings**

As per [\#6377](https://github.com/decidim/decidim/pull/6377), the `maximum_attachment_size` and `maximum_avatar_size` settings will no longer have any effect if configured through the Decidim initializer configurations. Instead, these are now configured from the organization system settings at the `/system` path of your installation.

Note that if you had these previously configured in the initializer, these previous settings have been automatically migrated to all organizations in your installation after running the Decidim upgrade migrations.

### Added

- **decidim-initiatives**: Initiatives signature gauge [\#6143](https://github.com/decidim/decidim/pull/6143)
- **decidim-i18n**: Complete Latvian language translation [\#6424](https://github.com/decidim/decidim/pull/6424)
- **decidim-templates**: Templates module [\#6247](https://github.com/decidim/decidim/pull/6247)
- **decidim-admin**, **decidim-core**, **decidim-elections**: Configure Decidim Bulletin Board [\#6420](https://github.com/decidim/decidim/pull/6420)
- **decidim-core**, **decidim-app_design**: Process groups template [\#6530](https://github.com/decidim/decidim/pull/6530)
- **decidim-comments**, **decidim-core**, **decidim-debates**, **decidim-dev**, **decidim-meetings**, **decidim-proposals**: Add hashtags to comments [\#6429](https://github.com/decidim/decidim/pull/6429)
- **decidim-accountability**, **decidim-blogs**, **decidim-budgets**, **decidim-comments**, **decidim-consultations**, **decidim-core**, **decidim-debates**, **decidim-initiatives**, **decidim-meetings**, **decidim-proposals**, **decidim-sortitions**: Debates filtering [\#6438](https://github.com/decidim/decidim/pull/6438)
- **decidim-budgets**, **decidim-core**, **decidim-debates**, **decidim-meetings**, **decidim-proposals**, **decidim-surveys**: Add scope to Budgets, Debates, Meetings, Proposals and Surveys components [\#6309](https://github.com/decidim/decidim/pull/6309)
- **decidim-all**: Share unpublished components with manageable tokens [\#6271](https://github.com/decidim/decidim/pull/6271)
- **decidim-budgets**: Selected projects on budgets [\#6365](https://github.com/decidim/decidim/pull/6365)
- **decidim-debates**, **decidim-meetings**, **decidim-proposals**: Meetings by participants or groups [\#6095](https://github.com/decidim/decidim/pull/6095)
- **decidim-core**, **docs**: Add a task to fix locale issues [\#6510](https://github.com/decidim/decidim/pull/6510)
- **decidim-elections**: Add NOTA option to election questions [\#6519](https://github.com/decidim/decidim/pull/6519)
- **decidim-core**: Implement self-XSS console warning [\#6489](https://github.com/decidim/decidim/pull/6489)
- **decidim-core**, **decidim-debates**, **decidim-proposals**: Add hashtags to debate [\#6396](https://github.com/decidim/decidim/pull/6396)
- **decidim-core**, **decidim-debates**, **decidim-accountability**, **decidim-proposals** and **decidim-meetings**: Keep filter and ordering params [\#6432](https://github.com/decidim/decidim/pull/6432)
- **decidim-elections**, **decidim-design_app**: Add elections list filter and sorting [\#6386](https://github.com/decidim/decidim/pull/6386)
- **decidim-initiatives**: Image on the Initiatives page and card [\#6427](https://github.com/decidim/decidim/pull/6427)
- **decidim-core**, **decidim-debates**: Add comments metadata to debates [\#6428](https://github.com/decidim/decidim/pull/6428)
- **decidim-debates**, **decidim-proposals**, **decidim-docs**: Users can endorse debates. [\#6368](https://github.com/decidim/decidim/pull/6368)
- **decidim-all**: Feature: Machine translation for user-generated content [\#6127](https://github.com/decidim/decidim/pull/6127)
- **decidim-debates**: Close debates [\#6278](https://github.com/decidim/decidim/pull/6278)
- **decidim-all**, **decidim-debates**: Embed debates [\#6306](https://github.com/decidim/decidim/pull/6306)
- **decidim-core**, **decidim-initiatives**, **decidim-verifications**: Better initiative button [\#6375](https://github.com/decidim/decidim/pull/6375)
- **decidim-elections**: Create voting booth [\#6294](https://github.com/decidim/decidim/pull/6294)
- **decidim-core**: Add CSV/Excel exporter sanitizer [\#6325](https://github.com/decidim/decidim/pull/6325)
- **decidim-debates**: Edit debates [\#6268](https://github.com/decidim/decidim/pull/6268)
- **decidim-dev**, **decidim-generators**, **decidim-docs**: Setup profiling tooling [\#6281](https://github.com/decidim/decidim/pull/6281)
- **decidim-accountability, decidim-admin, decidim-blogs, decidim-budget, decidim-comments, decidim-core, decidim-debates, decidim-dev, decidim-meetings, decidim-proposals, decidim-sortition**: Make character limit for comments configurable [\#6280](https://github.com/decidim/decidim/pull/6280)
- **decidim-elections**: Elections authorizations [\#6181](https://github.com/decidim/decidim/pull/6181)
- **decidim-core**: Add Romanian as a new language [\#6231](https://github.com/decidim/decidim/pull/6231)
- **decidim-docs**: Document when contributors should contribute to changelog [\#6209](https://github.com/decidim/decidim/pull/6209)
- **decidim-core**, **decidim-processes**: Add custom steps CTA for Process cards index [\#6284](https://github.com/decidim/decidim/pull/6284)
- **decidim-accountability**, **decidim-budgets**, **decidim-meetings**, **decidim-proposals**, **decidim-sortitions**, **decidim-core**, **decidim-consultations**: Make proposals handle i18n [\#6285](https://github.com/decidim/decidim/pull/6285)
- **decidim-proposals**: Add migration to update Proposal endorsement Notifications [\#6367](https://github.com/decidim/decidim/pull/6367)
- **decidim-docs**: Documentation: Add "not up to date" next to official documentation links [\#6364](https://github.com/decidim/decidim/pull/6364)
- **decidim-docs**: Add official documentation in the readme [\#6354](https://github.com/decidim/decidim/pull/6354)
- **decidim-surveys**: Do not migrate surveys that were already migrated in the past [\#6380](https://github.com/decidim/decidim/pull/6380)
- **decidim-surveys**: Add a migration to migrate data from legacy surveys' tables [\#6299](https://github.com/decidim/decidim/pull/6299)
- **decidim-core**: Polymorphic route support for ResourceLocatorPresenter [\#6274](https://github.com/decidim/decidim/pull/6274)
- **decidim-surveys**: View and manage responses to surveys directly in the admin [\#5770](https://github.com/decidim/decidim/pull/5770)
- **decidim-core**: Introduce a standardized branch naming [\#6210](https://github.com/decidim/decidim/pull/6210)
- **decidim-all**: Add line feeds at the end of paragraphs and lists [\#6200](https://github.com/decidim/decidim/pull/6200)
- **decidim-proposals**: Add tests to proposal_presenter [\#6265](https://github.com/decidim/decidim/pull/6265)
- **decidim-core**: Rename stable branches and add changelog upgrade note [\#6222](https://github.com/decidim/decidim/pull/6222)
- **decidim-assemblies**: Import and export for Assemblies [\#5624](https://github.com/decidim/decidim/pull/5624)
- **decidim-elections**: Publish and unpublish an election [\#6152](https://github.com/decidim/decidim/pull/6152)
- **decidim-proposals**: Import from proposals to answers [\#6163](https://github.com/decidim/decidim/pull/6163)

### Changed

- **decidim-core**, **decidim-proposals**: Add more than one attachment to proposals [\#6532](https://github.com/decidim/decidim/pull/6532)
- **decidim-core**: Remove default static pages [\#6596](https://github.com/decidim/decidim/pull/6596)
- **decidim-core**, **decidim-dev**, **decidmi-generators**, **decidim-meetings**, **decidim-proposals**: Make maps actually configurable [\#6340](https://github.com/decidim/decidim/pull/6340)
- **decidim-design**: Update Faker quotes in design module in order to match the current gem syntax [\#6560](https://github.com/decidim/decidim/pull/6560)
- **decidim-generators**: Change default initializer settings [\#6566](https://github.com/decidim/decidim/pull/6566)
- **decidim-all**: Make file upload settings configurable [\#6377](https://github.com/decidim/decidim/pull/6377)
- **decidim-admin**, **decidim-comments**, **decidim-core**: Upgrade JavaScript dependencies [\#6524](https://github.com/decidim/decidim/pull/6524)
- **decidim-proposal**: Add editor to new_proposal_body_template [\#6517](https://github.com/decidim/decidim/pull/6517)
- **decidim-core**: Upgrade seven_zip_ruby to 1.3.0 to be compatible with Ruby 2.7 [\#6509](https://github.com/decidim/decidim/pull/6509)
- **decidim-doc**: Update release process [\#6460](https://github.com/decidim/decidim/pull/6460)
- **decidim-system**: Move OAUTH Application management to system panel [\#5955](https://github.com/decidim/decidim/pull/5955)
- **decidim-budgets**, **decidim-comments**: Budget component with many budgets [\#6223](https://github.com/decidim/decidim/pull/6223)
- **decidim-documentation**: Change Subtasks to Checklist in PR template [\#6536](https://github.com/decidim/decidim/pull/6536)
- **decidim-admin**, **decidim-core**: Adding dropdown option to locales list [\#6462](https://github.com/decidim/decidim/pull/6462)
- **decidim-core**: Make cookie consent name configurable [\#6451](https://github.com/decidim/decidim/pull/6451)
- **decidim-elections**: Remove election subtitle and add election image [\#6390](https://github.com/decidim/decidim/pull/6390)
- **decidim-elections**: Require confirmation on exiting election voting process [\#6394](https://github.com/decidim/decidim/pull/6394)
- **decidim-i18n**: Renaming files sl-SI.yml to sl.yml [\#6414](https://github.com/decidim/decidim/pull/6414)
- **decidim-core**, **decidim-docs**: Change locale checker's default branch [\#6406](https://github.com/decidim/decidim/pull/6406)
- **decidim-all**: Add missing locales from Crowdin [\#6389](https://github.com/decidim/decidim/pull/6389)
- **decidim-accountability**, **decidim-assemblies**, **decidim-comments**, **decidim-core**, **decidim-debates**, **decidim-meetings**, **decidim-proposals**, **decidim-surveys**: Performance improvements for metrics [\#5575](https://github.com/decidim/decidim/pull/5575)
- **decidim-initiatives**: Fallback to closed initiatives when there are no open ones [\#6376](https://github.com/decidim/decidim/pull/6376)
- **decidim-core**: Bump Ruby version to 2.6.6 [\#6320](https://github.com/decidim/decidim/pull/6320)
- **decidim-core**, **all modules**: Rework accessibility improvements [\#6253](https://github.com/decidim/decidim/pull/6253)
- **decidim-core**: Memoize current_user [\#6305](https://github.com/decidim/decidim/pull/6305)
- **decidim-accountability**, **decidim-comments**, **decidim-proposals**, **decidim-core**: Make comments handle i18n [\#6276](https://github.com/decidim/decidim/pull/6276)
- **decidim-core**: Improve email notifications for reported content [\#6053](https://github.com/decidim/decidim/pull/6053)
- **decidim-core**: Improve newsletter real time counters performance when using segmentation  [\#6258](https://github.com/decidim/decidim/pull/6258)
- **decidim-core**: Memoizes and caches provider settings to improve performance [\#6236](https://github.com/decidim/decidim/pull/6236)
- **decidim-core**: Update to Rails 5.2.4.4 [\#6513](https://github.com/decidim/decidim/pull/6513)
- **decidim-core**: Use simplecov 0.19.0 [\#6449](https://github.com/decidim/decidim/pull/6449)
- **decidim-core**: Upgrade to bundler 2 to be able to run `rake release` [\#6452](https://github.com/decidim/decidim/pull/6452)
- **decidim-core**: Make codecov ignore module declaration files [\#6321](https://github.com/decidim/decidim/pull/6321)
- **decidim-core**: Upgrade mdl to have kramdown upgraded [\#6405](https://github.com/decidim/decidim/pull/6405)
- **decidim-core**: Only load SimpleCov if the env variable is set [\#6392](https://github.com/decidim/decidim/pull/6392)
- **decidim-core**: Update rack gem to patch CVE-2020-8184 [\#6273](https://github.com/decidim/decidim/pull/6273)
- **decidim-elections**: Align icons in elections admin [\#6218](https://github.com/decidim/decidim/pull/6218)
- **decidim-core**: Retry `bundle install` step through an action [\#5995](https://github.com/decidim/decidim/pull/5995)
- **decidim-surveys**: Supersede "Manage conditions to hide or show questions in surveys" [\#6241](https://github.com/decidim/decidim/pull/6241)
- **decidim-core**: Update stale.yml configuration for stale-bot [\#6199](https://github.com/decidim/decidim/pull/6199)

### Fixed

- **decidim-meetings**: Backport "Do not html_escape twice meetings title in cells" to v0.23 [\#6780](https://github.com/decidim/decidim/pull/6780)
- **decidim-consultations**: Fix aria-label attribute in the vote modal confirm close button [\#6783](https://github.com/decidim/decidim/pull/6783)
- **decidim-assemblies**: Backport "Fix images url in assemblies presenter on cloud storage" to 0.23 [\#6757](https://github.com/decidim/decidim/pull/6757)
- **decidim-admin**: Fix newsletter create and update actions (\#6755) [\#6773](https://github.com/decidim/decidim/pull/6773)
- **decidim-meetings**: Backport "Fix upcoming meetings content block should only show visible meetings" to v0.23 [\#6779](https://github.com/decidim/decidim/pull/6779)
- **decidim-budgets**: Fix budgeting projects ordered ids (\#6761) [\#6774](https://github.com/decidim/decidim/pull/6774)
- **decidim-admin**, **decidim-core**: Backport "Fix content block image updates" to v0.23 [\#6752](https://github.com/decidim/decidim/pull/6752)
- **decidim-budgets**, **decidim-core**, **decidim-meetings**: Refactor meetings test to be resilient to flakys (\#6694) [\#6706](https://github.com/decidim/decidim/pull/6706)
- **decidim-forms**: Fix dependencies for decidim-templates within decidim-forms (\#6652) [\#6743](https://github.com/decidim/decidim/pull/6743)
- **decidim-meetings**: Fix meetings creation (\#6695) [\#6732](https://github.com/decidim/decidim/pull/6732)
- **decidim-meetings**: Backport of showing only meetings visible for current user to release 0.23 [\#6708](https://github.com/decidim/decidim/pull/6708)
- **decidim-core**: Fix the file validator humanizer with static numeric values (\#6682) [\#6688](https://github.com/decidim/decidim/pull/6688)
- **decidim-core**: Backport "Ensure `resource_text` is a string in NotificationMailer" to 0.23 [\#6689](https://github.com/decidim/decidim/pull/6689)
- **decidim-verifications**: Fix pending authorization list (\#6680) [\#6690](https://github.com/decidim/decidim/pull/6690)
- **decidim-core**: Backport "Fix elections count in Homepage statistics" to 0.23 [\#6686](https://github.com/decidim/decidim/pull/6686)
- **decidim-debates**, **decidim-meetings**: Fix meeting and debate presenters with machine translations (\#6643) [\#6647](https://github.com/decidim/decidim/pull/6647)
- **decidim-all**: Ensure translatable resources save their fields as JSON objects (\#6587) [\#6646](https://github.com/decidim/decidim/pull/6646)
- **decidim-admin**: Fix page's slug help not generating the right URL [\#6591](https://github.com/decidim/decidim/pull/6591)
- **decidim-core**: Lock resource when updating machine translations [\#6580](https://github.com/decidim/decidim/pull/6580)
- **decidim-core**: Fix missing translation in Forms [\#6597](https://github.com/decidim/decidim/pull/6597)
- **decidim-proposals**: Fix proposals creation [\#6585](https://github.com/decidim/decidim/pull/6585)
- **decidim-core**: Take the first image attachment when rendering a proposal card [\#6592](https://github.com/decidim/decidim/pull/6592)
- **decidim-system**: Fix issue when the file upload settings is not a hash [\#6600](https://github.com/decidim/decidim/pull/6600)
- **decidim-core**: Fix notifications with missing event classes [\#6599](https://github.com/decidim/decidim/pull/6599)
- **decidim-forms**: Fix expanding new questions when questionnaire has errors [\#6565](https://github.com/decidim/decidim/pull/6565)
- **decidim-system**: Fix system omniauth settings with disabled OmniAuth providers [\#6549](https://github.com/decidim/decidim/pull/6549)
- **decidim-conferences**, **decidim-core**: Sanitize inputs in conferences [\#6563](https://github.com/decidim/decidim/pull/6563)
- **decidim-assemblies**, **decidim-core**, **decidim-consultations**, **decidim-initiatives**, **decidim-processes**, **decidim-conferences**: Fix carrierwave re-upload image quality reduction [\#6447](https://github.com/decidim/decidim/pull/6447)
- **decidim-elections**: Fix election presenter namespace [\#6293](https://github.com/decidim/decidim/pull/6293)
- **decidim-core**: remove admin role when user destroys account [\#6312](https://github.com/decidim/decidim/pull/6312)
- **decidim-core**, **decidim-initiatives**, **decidim-proposals**: Custom validator that checks string fields [\#6304](https://github.com/decidim/decidim/pull/6304)
- **decidim-forms**: fix sorted questions mantaining order on submit errors [\#6251](https://github.com/decidim/decidim/pull/6251)
- **decidim-meetings**: Move meeting services to their own model [\#6269](https://github.com/decidim/decidim/pull/6269)
- **decidim-debates**: Allow testing surveys prior to publication [\#6176](https://github.com/decidim/decidim/pull/6176)
- **decidim-initiative**: Fix admin initiative's answer redirection [\#6279](https://github.com/decidim/decidim/pull/6279)
- **decidim-budgets**, **decidim-proposals**: Improve proposal selection [\#6213](https://github.com/decidim/decidim/pull/6213)
- **decidim-core**: New Crowdin updates [\#6282](https://github.com/decidim/decidim/pull/6282)
- **decidim-debates**: Truncate debate cell text & do not sanitize instructions [\#6224](https://github.com/decidim/decidim/pull/6224)
- **decidim-core**: New Crowdin updates [\#6270](https://github.com/decidim/decidim/pull/6270)
- **decidim-core**: Fix and improve amendments diff visualizations [\#6260](https://github.com/decidim/decidim/pull/6260)
- **decidim-initiatives**: Don't send notification if threshold has already been reached [\#6261](https://github.com/decidim/decidim/pull/6261)
- **decidim-debates**: Enable debate reporting. Closes #6190 [\#6254](https://github.com/decidim/decidim/pull/6254)
- **decidim-meetings**: Avoid deleting a meeting when it has at least one proposal originated in it [\#6242](https://github.com/decidim/decidim/pull/6242)
- **decidmi-core**, **decidim-proposals**: Fix admin logs proposal presenter (\#6637) [\#6651](https://github.com/decidim/decidim/pull/6651)
- **decidim-admin**: Fix bug with Participants Admin active menu [\#6578](https://github.com/decidim/decidim/pull/6578)
- **decidim-admin**, **decidim-assemblies**, **decidim-processes**: Fix form validations for user's invitation [\#6556](https://github.com/decidim/decidim/pull/6556)
- **I18n**: Fix key for :no locale at begining of yaml [\#6588](https://github.com/decidim/decidim/pull/6588)
- **decidim-meetings**: Fixing namespace issue with the meeting admin controller [\#6508](https://github.com/decidim/decidim/pull/6508)
- **decidim-core**: Add an error message modal for the conversations [\#6446](https://github.com/decidim/decidim/pull/6446)
- **decidim-core**, **decidim-proposals**: Fix resource free text search [\#6465](https://github.com/decidim/decidim/pull/6465)
- **decidim-core**, **decidim-admin**: Fix issue with disappearing list elements in rich text editors [\#6422](https://github.com/decidim/decidim/pull/6422)
- **decidim-admin**, **decidim-core**: Fix problem showing emails from different participants  [\#6503](https://github.com/decidim/decidim/pull/6503)
- **decidim-core**, **decidim-proposals**: Fix proposal creation [\#6518](https://github.com/decidim/decidim/pull/6518)
- **decidim-elections**: Add validation for max selections on election questions [\#6505](https://github.com/decidim/decidim/pull/6505)
- **decidim-meetings**: Fix InvitePresenter when invitation does not exist anymore [\#6468](https://github.com/decidim/decidim/pull/6468)
- **decidim-core**, **decidim-proposals**: Amendments validations enhancement for participatory texts [\#6344](https://github.com/decidim/decidim/pull/6344)
- **decidim-core**: fix maltese translation for foundation datepicker [\#6410](https://github.com/decidim/decidim/pull/6410)
- **decidim-core**: Use followers counter cache when available [\#6383](https://github.com/decidim/decidim/pull/6383)
- **decidim-budgets**, **decidim-elections**: Fix import proposals to election answers i18n bug [\#6391](https://github.com/decidim/decidim/pull/6391)
- **decidim-core**: Link is lost when user logs in [\#6300](https://github.com/decidim/decidim/pull/6300)
- **decidim-initiative**: Fix initiative state notification [\#6331](https://github.com/decidim/decidim/pull/6331)
- **decidim-admin**, **decidim-consultations**, **decidim-core**: Fix newsletter target selection exception due to consultations [\#5561](https://github.com/decidim/decidim/pull/5561)
- **decidim-core**: Remove validation rule that detects long words [\#6272](https://github.com/decidim/decidim/pull/6272)
- **decidim-core**: Fix crash when proposals meeting author is deleted [\#6232](https://github.com/decidim/decidim/pull/6232)
- **decidim-comments**: Fix comments JS errors and delays [\#6193](https://github.com/decidim/decidim/pull/6193)
- **decidim-core**: Change popup button from "Keep uncheck" to "Keep unchecked" [\#6488](https://github.com/decidim/decidim/pull/6488)
- **decidim-accountability**, **decidim-proposals**, **decidim-admin**, **decidim-core**, **decidim-initiatives**, **decidim-participatory_processes**: Bugfix 0.22.0.rc1 [\#6381](https://github.com/decidim/decidim/pull/6381)
- **decidim-elections**: Improve navigation consistency in the admin zone for elections questions and answers [\#6139](https://github.com/decidim/decidim/pull/6139)
- **decidim-assemblies**, **decidim-core**, **decidim-dev**, **decidim-forms**, **decidim-participatory_processes**, **decidim-proposals**: Fix rubocop errors arising from capybara upgrade [\#6197](https://github.com/decidim/decidim/pull/6197)
- **decidim-assemblies**: Take into account that assembly images are optional [\#6786](https://github.com/decidim/decidim/pull/6786)
- **decidim-core**: Backport on release 0.23 of fix register a meeting invitation for an user [\#6728](https://github.com/decidim/decidim/pull/6728)
- **decidim-meetings**: Mark meetings spec as slow [\#6595](https://github.com/decidim/decidim/pull/6595)
- **decidim-core**: Reorganize before sentences to avoid flaky tests [\#6571](https://github.com/decidim/decidim/pull/6571)
- **decidim-core**: Remove restore cache keys fallbacks and solve CI segfault problem [\#6557](https://github.com/decidim/decidim/pull/6557)
- **decidim-templates**: Fix "no" Norwegian key for decidim-templates [\#6609](https://github.com/decidim/decidim/pull/6609)
- **decidim-debates**: Fix debates comments count migration [\#6564](https://github.com/decidim/decidim/pull/6564)
- **decidim-elections**: Fix NOTA option [\#6573](https://github.com/decidim/decidim/pull/6573)
- **decidim-docs**: Fix documentation URL in README
- **decidim-core**: Fix random indent style on notifications [\#6415](https://github.com/decidim/decidim/pull/6415)
- **decidim-core**: Fix text after merging spanish translations [\#6421](https://github.com/decidim/decidim/pull/6421)
- **decidim-proposals**: Fix bugs after proposals i18n move [\#6384](https://github.com/decidim/decidim/pull/6384)
- **decidim-core**: Fix crash at newsletter preview [\#6369](https://github.com/decidim/decidim/pull/6369)
- **decidim-core**: Fix spec failing at specific dates [\#6366](https://github.com/decidim/decidim/pull/6366)
- **decidim-debates**: Remove duplicated locales in debates i18n fields [\#6283](https://github.com/decidim/decidim/pull/6283)
- **decidim-core**: Fix linter on recipient counter text for newsletter helper [\#6289](https://github.com/decidim/decidim/pull/6289)
- **decidim-core**: Point simplecov to master to fix a coverage on monorepos [\#6240](https://github.com/decidim/decidim/pull/6240)
- **decidim-core**: Fix install profiling gems in development_app rake task [\#6338](https://github.com/decidim/decidim/pull/6338)
- **decidim-participatory_processes**: Fix highlighted participatory processes title [\#6799](https://github.com/decidim/decidim/pull/6799)
- **decidim-budgets**: Add translation for "selected" projects (\#6770) [\#6796](https://github.com/decidim/decidim/pull/6796)
- **decidim-assemblies**, **decidim-participatory_processes**, **decidim-proposals**: Fix missing translation keys for mime types (\#6766) [\#6795](https://github.com/decidim/decidim/pull/6795)
- **decidim-core**: Require the necessary "zip" gem in the open data exporter (\#6464) [\#6791](https://github.com/decidim/decidim/pull/6791)
- **decidim-core**: Bubble jQuery events (\#6610) [\#6792](https://github.com/decidim/decidim/pull/6792)
- **decidim-consultations**: Fix question#show view when question has no hero_image (\#6802) [\#6802](https://github.com/decidim/decidim/pull/6802)

### Removed

- **decidim-all**: Remove redundant translation files for Latvian [\#6439](https://github.com/decidim/decidim/pull/6439)
- **decidim-proposals**: Remove legacy Proposals endorsements table [\#5643](https://github.com/decidim/decidim/pull/5643)
- **decidim-core**, **decidim-initiatives**, **decidim-proposals**: Revert "Custom validator that checks string fields (\#6304)" [\#6316](https://github.com/decidim/decidim/pull/6316)

## Previous versions

Please check [release/0.22-stable](https://github.com/decidim/decidim/blob/release/0.22-stable/CHANGELOG.md) for previous changes.
