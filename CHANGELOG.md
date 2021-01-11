# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

**Added**

**Changed**

**Fixed**

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
- **decidim-meetings**: Fix InvitePresenter when invitation does not exist anymore. [\#6469](https://github.com/decidim/decidim/pull/6469)
- **decidim-conferences**, **decidim-core**: Backport "Sanitize inputs in conferences" to 0.22 [\6567](https://github.com/decidim/decidim/pull/6567)

**Removed**:

## [v0.22.0](https://github.com/decidim/decidim/releases/tag/v0.22.0)

### Upgrade notes

- **Endorsements**

This new version of Decidim has extracted the Endorsement feature into a generic concern that can now be applied to many resources.
To keep current Decidim::Proposals::Proposal's endorsement information, endorsements are copied into the new `Decidim::Endorsable` tables and counter cache columns. This is done via migrations.

After this, `Decidim::Proposals::ProposalEndorsement` and the corresponding counter cache column in `decidim_proposals_proposal.proposal_endorsements_count` should be removed. To do so, Decidim will provide the corresponding migration in the next release.

- **Data portability**

Thanks to [\#5342](https://github.com/decidim/decidim/pull/5342), Decidim now supports removal of user's data portability expired files from Amazon S3. Check out the [scheduled tasks in the getting started guide](https://github.com/decidim/decidim/blob/master/docs/getting_started.md#scheduled-tasks) for information in how to configure it.

- **SSL is forced on by default**

Due to [\#5553](https://github.com/decidim/decidim/pull/5553), SSL is turned on by default.

- **New "extras" key in authorization metadata**

[\#6044](https://github.com/decidim/decidim/pull/6044) adds the possibility to have an "extras" key in the Authentication metadata that will be ignored. For example when
signing an initiative (decidim-initiatives/app/forms/decidim/initiatives/vote_form.rb) or on Authorization renewal (decidim-verifications/app/cells/decidim/verifications/authorization_metadata/show.erb).

This key may be used to persist whatever information related to the user's authentication that should not be used for authenticating her.
The use case that originated this change is the persistence of the user's gender for statistical uses.

**Added**:

- **decidim-initiative**: Skip initiative type selection if there is only one initiative type. [\#5835](https://github.com/decidim/decidim/pull/5835)
- **decidim-docs**: Add doc in how to release following Gitflow. [\#5766](https://github.com/decidim/decidim/pull/5766)
- **decidim-docs**: Add documentation related with the permissions system. [\#6160](https://github.com/decidim/decidim/pull/6160)
- **decidim-participatory_processes**: Add related assemblies to participatory processes [\#5868](https://github.com/decidim/decidim/pull/5868)
- **decidim-comments**: Fix comment link on Last Activity. [\#5999](https://github.com/decidim/decidim/pull/5999)
- **decidim-system**: Add from_label to Organization SMTP settings. [#\6125](https://github.com/decidim/decidim/pull/6125)
- **decidim-initiatives**: Send notification when signature threshold reached. [\#6098](https://github.com/decidim/decidim/pull/6098)
- **decidim-proposals**: Add an information message when there aren't proposals. [\#6063](https://github.com/decidim/decidim/pull/6063)
- **decidim-core**: Set email asset host dynamically. [\#5888](https://github.com/decidim/decidim/pull/5888)
- **decidim-meetings**: Include year in meetings' card [\#6102](https://github.com/decidim/decidim/pull/6102)
- **decidim-initiatives**: Add attachments to initiatives [\#5844](https://github.com/decidim/decidim/pull/5844)
- **decidim-proposals**: Improve proposal preview: Use proposal card when previewing a proposal draft. [\#6064](https://github.com/decidim/decidim/pull/6064)
- **decidim-core**: Allow groups to have private conversations with other users or groups. [\#6009](https://github.com/decidim/decidim/pull/6009)
- **decidim-api**: Use organization time zone [\#6088](https://github.com/decidim/decidim/pull/6088)
- **decidim-docs**: Add helpful info to install docs for seed errors during installation process. [\#6085](https://github.com/decidim/decidim/pull/6085)
- **decidim-forms**: Collapse and expand questions when editing questionnaire [\#5945](https://github.com/decidim/decidim/pull/5945)
- **decidim-forms**: New question type "Matrix" [\#5948](https://github.com/decidim/decidim/pull/5948)
- **decidim-core**: Notify admins o user_group created or updated. [\#5906](https://github.com/decidim/decidim/pull/5906)
- **decidim-comments**: Notify user_group followers when it posts a comment. [\#5906](https://github.com/decidim/decidim/pull/5906)
- **decidim-initiatives**: Notify admins when an initiative is sent to technical validation. [\#5906](https://github.com/decidim/decidim/pull/5906)
- **decidim-proposals**: Notify admins and valuators when someone leaves a private note on a proposal. [\#5906](https://github.com/decidim/decidim/pull/5906)
- **decidim-forms**: Update move up and down buttons after dragging questions when managing questionnaire. [\#5947](https://github.com/decidim/decidim/pull/5947)
- **decidim-meetings**: Automatic task for deleting Meeting Inscription data. [\#5989](https://github.com/decidim/decidim/pull/5989)
- **decidim-core**: Don't follow the header x forwarded host by default. [\#5899](https://github.com/decidim/decidim/pull/5899)
- **decidim-initiative**: Add CTA on initiative submission. [\#5838](https://github.com/decidim/decidim/pull/5838)
- **decidim-core**: Allow users to register with a preferred language. [\#5789](https://github.com/decidim/decidim/pull/5789)
- **decidim-dev**: Retry failed test to avoid flaky. [\#5894](https://github.com/decidim/decidim/pull/5894)
- **decidim-core**: Filter options to Timeline and Activity tabs. [\#5845](https://github.com/decidim/decidim/pull/5845)
- **decidim-core**: Add scroll to last message and apply it on conversations. [\#5718](https://github.com/decidim/decidim/pull/5718)
- **decidim-core**: Allow to restric direct messages to only people followed by the user. [\#5720](https://github.com/decidim/decidim/pull/5720)
- **decidim-comments**: Comments can mention groups and its members are notified. [\#5763](https://github.com/decidim/decidim/pull/5763)
- **decidim-core**: Now messages inside conversations have their urls identified as links. [\#5755](https://github.com/decidim/decidim/pull/5755)
- **decidim-verifications**: Added Verification's Revocation [\#5814](https://github.com/decidim/decidim/pull/5814)
- **decidim-verifications**: Participants can renew verifications [\#5854](https://github.com/decidim/decidim/pull/5854)
- **decidim-core**: Support node.js semver rules for release candidates. [\#5828](https://github.com/decidim/decidim/pull/5828)
- **decidim-proposals**, **decidim-core**, **decidim-blogs**: Extract proposals' endorsements into a polymorphic concern that can now be applied no any resource. It has, in turn, been aplied to blog posts. [\#5542](https://github.com/decidim/decidim/pull/5542)
- **decidim-proposals**, **decidim-core**, **decidim-blogs**: Apply generalized endorsements to the GraphQL API and add it to the blog posts query. [\#5847](https://github.com/decidim/decidim/pull/5847)
- **decidim-core**: Allow users to have private conversations with more than one participant. [\#5861](https://github.com/decidim/decidim/pull/5861)
- **decidim-budgets**: Allow projects to be sorted by different criteria [\#5808](https://github.com/decidim/decidim/pull/5808)
- **decidim-budgets**: Request confirmation to exit budgets component [\#5765](https://github.com/decidim/decidim/pull/5765)
- **decidim-budgets**: Add minimum projects rule to Budgets [\#5865](https://github.com/decidim/decidim/pull/5865)
- **decidim-proposals**: Proposals selector added [\#5863](https://github.com/decidim/decidim/pull/5863)
- **decidim-admin**: Allow to see a participant's email from the admin panel [\#5849](https://github.com/decidim/decidim/pull/5849)
- **decidim-admin**: As an Admin, add existing participant to an assembly by searching their email [\#5952](https://github.com/decidim/decidim/pull/5952)
- **decidim**: Add missing indexs on foreign keys on the DB [\#5885](https://github.com/decidim/decidim/pull/5885)
- **decidim-core**: Redesign activity cards for the home page [\#5672](https://github.com/decidim/decidim/pull/5672)
- **decidim-core**: Redesign activity cards on Timeline and Activity Tabs for a consistent user experience [\#5779](https://github.com/decidim/decidim/issues/5779)
- **decidim-admin**: Counter of active users. [\#5907](https://github.com/decidim/decidim/pull/5907)
- **decidim-proposals**: Update rspec proposal_activity_cell_spec to check existence of card\_\_content css class instead of car-data css class [#5779](https://github.com/decidim/decidim/issues/5779)
- **decidim-comments**: Update rspec comment_activity_cell_spec to check existence of card\_\_content css class instead of car-data css class[#5779](https://github.com/decidim/decidim/issues/5779)
- **decidim-core**: Add newsletter templates [\#5887](https://github.com/decidim/decidim/pull/5887)
- **decidim-core**: Fix clearing the current_user after sign out [\#5823](https://github.com/decidim/decidim/pull/5823)
- **decidim-budgets**: Send email with summary on order checkout [\#6006](https://github.com/decidim/decidim/pull/6006)
- **decidim-admin**: Show activity charts on admin dashboard [\#6030](https://github.com/decidim/decidim/pull/6030)
- **decidim-budgets**: Projects filter by multiple categories [\#5992](https://github.com/decidim/decidim/pull/5992)
- **decidim-budgets**: Improve the budget page and the project card [\#5809](https://github.com/decidim/decidim/pull/5809)
- **decidim-assemblies** **decidim-conferences** **decidim-participatory-processes**: Notify users on adding roles. [\#5886](https://github.com/decidim/decidim/pull/5886)
- **decidim-budgets**: Projects filter by multiple categories [/#5992](https://github.com/decidim/decidim/pull/5992)
- **decidim-initiatives**: Add option to enable/disable attachments to initiatives [/#6036](https://github.com/decidim/decidim/pull/6036)
- **decidim-core**: Adds new language: Slovak [\#6039](https://github.com/decidim/decidim/pull/6039)
- **decidim-core**: Add redesign for responsive public profile navigation tabs [\#6032](https://github.com/decidim/decidim/pull/6032)
- **decidim-initiatives**: Add pages for versioning. [\#5935](https://github.com/decidim/decidim/pull/5935)
- **decidim-core**: Explain how to initialize a custom oauth2 client provider [\#6055](https://github.com/decidim/decidim/pull/6055)
- **decidim-core**: Added support for enum settings for components [\#6001](https://github.com/decidim/decidim/pull/6001)
- **decidim-core**: Added support for readonly settings for components [\#6001](https://github.com/decidim/decidim/pull/6001)
- **decidim-accountability**: Added support for import csv files [\#6028](https://github.com/decidim/decidim/pull/6028)
- **decidim-initiatives**: Add filter by type to admin. [\#6093](https://github.com/decidim/decidim/pull/6093)
- **decidim-initiatives**: New search/filters design [\#6090](https://github.com/decidim/decidim/pull/6090)
- **decidim-core**: Improvements to conversations with more than one participant. [\#6094](https://github.com/decidim/decidim/pull/6094)
- **decidim-elections**: Elections module and election administration. [\#6065](https://github.com/decidim/decidim/pull/6065)
- **decidim-forms**: Split forms in steps using separators [\#6108](https://github.com/decidim/decidim/pull/6108)
- **decidim-initiatives**: Enhanced initiatives search [\#6086](https://github.com/decidim/decidim/pull/6086)
- **decidim-initiatives**: Add setting in `Decidim::InitiativesType` to enable users to set a custom signature end date in their initiatives. [\#5998](https://github.com/decidim/decidim/pull/5998)
- **decidim-initiatives**: Sorting by publish date and supports count on admin, by publish date on front [/#6016](https://github.com/decidim/decidim/pull/6016)
- **decidim-assemblies**: Added a setting for assemblies to enable or disable the visibility of the organization chart. [\#6040](https://github.com/decidim/decidim/pull/6040)
- **decidim-initiatives**: Allow admins to export initiatives [\#6070](https://github.com/decidim/decidim/pull/6070)
- **decidim-elections**: Add questions and answers to elections [\#6129](https://github.com/decidim/decidim/pull/6129)
- **decidim-forms**: Request confirmation when leaving the form half-answered [\#6118](https://github.com/decidim/decidim/pull/6118)
- **decidim-initiatives**: Add areas to initiatives. [\#6111](https://github.com/decidim/decidim/pull/6111)

**Changed**:

- **decidim-admin**, **decidim-core**: Improve explanation on image management on Layout Appearance. [\#6089](https://github.com/decidim/decidim/pull/6089)
- **decidim-surveys**: Remove decidim-surveys legacy tables after migrating to decidim-forms. [\#6178](https://github.com/decidim/decidim/pull/6178)
- **decidim-initiatives**: Change initiatives committee request permission to prevent homepage redirection. [\#6115](https://github.com/decidim/decidim/pull/6115)
- **decidim-accountability**, **decidim-core**, **decidim-meetings**, **decidim-proposals**: Optimize queries for performance in Homepage, process page, proposals page and coauthorable cell. [\#5903](https://github.com/decidim/decidim/pull/5903)
- **decidim-assemblies**: Replace current meetings hook with highlighted elements hook [\#5897](https://github.com/decidim/decidim/pull/5897)
- **decidim-core**: Change the map marker color to the Decidim primary color [\#5870](https://github.com/decidim/decidim/pull/5870)
- **decidim-core**: Add whitespace: nowrap style to compact buttons. [\#5891](https://github.com/decidim/decidim/pull/5891)
- **decidim-core**: Hide password fields on Accounts page when organization sign in is disabled. [\#6130](https://github.com/decidim/decidim/pull/6130)
- **decidim-initiatives**: Ignore new "extras" key when checking authorization/variation metadata [\#6044](https://github.com/decidim/decidim/pull/6044)
- **decidim-assemblies**: Change user permission to list assemblies. Users can only list the assemblies that they have been assigned permission [\#5944](https://github.com/decidim/decidim/pull/5944)
- **decidim-accountability**: Using the new proposals selector for choosing result proposals [\#5863](https://github.com/decidim/decidim/pull/5863)
- **decidim-meetings**: Using the new proposals selector for choosing meeting close proposals [\#5863](https://github.com/decidim/decidim/pull/5863)

**Fixed**:

- **decidim-surveys**: Fix ip_hash not being saved in anonymous surveys. [\#6156](https://github.com/decidim/decidim/pull/6156)
- **decidim-proposals**: Fix participatory text newline absence. [\#6158](https://github.com/decidim/decidim/pull/6158)
- **decidim-consultations**: Fix permissions in order to make components inside of questions accessible. [\#6079](https://github.com/decidim/decidim/pull/6079)
- **decidim-core**: Patch various security alerts reported by GitHub. [\#6148](https://github.com/decidim/decidim/pull/6148)
- **decidim-core**: Fix user's avatar icon in CSS. [\#5990](https://github.com/decidim/decidim/pull/5990)
- **decidim-core**: Use internal Organization class in migration. [\#6052](https://github.com/decidim/decidim/pull/6052)
- **decidim-core**: Fix email not being sent to some users when uploading a CSV file. [\#6011](https://github.com/decidim/decidim/pull/6011)
- **decidim-core**: Fix broken puma version in generator's Gemfile. [\#6060](https://github.com/decidim/decidim/pull/6060)
- **decidim-core,decidim-system**: Fix using Decidim as a provider for omniauth authentication. [\#6042](https://github.com/decidim/decidim/pull/6042)
- **decidim-proposals**: Fix missing values for filter values in proposals admin. [\#6013](https://github.com/decidim/decidim/pull/6013)
- **decidim-api**: Fix broken documentation if using Decidim from a Gem. [\#5996](https://github.com/decidim/decidim/pull/5996)
- **decidim-core**: Fix supported versions in SECURITY.md file. [\#5957](https://github.com/decidim/decidim/pull/5957)
- **decidim-debates**: Fix a notification failure when the creating a new debate event is fired. [\#5964](https://github.com/decidim/decidim/pull/5964)
- **decidim-proposals**: Fix a migration failure when generalizing proposal endorsements. [\#5953](https://github.com/decidim/decidim/pull/5953)
- **decidim-assemblies**: Fix parent-child loophole when setting a child as and parent and making assemblies disappear. [\#5807](https://github.com/decidim/decidim/pull/5807)
- **decidim-forms**: Fixes a performance degradation when displaying forms in surveys. [\#5819](https://github.com/decidim/decidim/pull/5819)
- **decidim-proposals**: Fix relative path in mentioned proposal email [\#5852](https://github.com/decidim/decidim/pull/5852)
- **decidim-proposals**: Use simple_format to add a wrapper to proposals body [\#5753](https://github.com/decidim/decidim/pull/5753)
- **decidim-sortitions**: Fix incorrect proposals sortition. [\#5620](https://github.com/decidim/decidim/pull/5620)
- **decidim-admin**: Fix: let components without step settings be added [\#5568](https://github.com/decidim/decidim/pull/5568)
- **decidim-proposals**: Fix proposals that have their state not published [\#5832](https://github.com/decidim/decidim/pull/5832)
- **decidim-core**: Fix map hovering over the secondary navigation element [\#5871](https://github.com/decidim/decidim/pull/5871)
- **decidim-core**: Fix follow button not doing anything when not logged in [\#5872](https://github.com/decidim/decidim/pull/5872)
- **decidim-core**: Fix missing tribute source map [\#5869](https://github.com/decidim/decidim/pull/5869)
- **decidim-api**: Force signin on API if the organization requires it [\#5859](https://github.com/decidim/decidim/pull/5859)
- **decidim-core**: Apply security patch for GHSA-65cv-r6x7-79hv [\#5896](https://github.com/decidim/decidim/pull/5896)
- **decidim-core**: Fix proposals filtering by scope in Chrome [\#5901](https://github.com/decidim/decidim/pull/5901)
- **decidim-comments**: Don't allow comments deeper than a certain depth, at the API level [\#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-core**: Force SSL and HSTS [\#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-core**: Do not expose Ruby version in production [\#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-verifications**: Throttle failed authorization attempts [\#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-core**: Prevent timing attacks on login and avoid leaking timing info [\#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-core**: Expire sessions after 24h of creation [\#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-participatory_processes**: Do not expose process statistics in the API if hidden [\#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-core**: Invalidate sessions on logout [\#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-core**: Do now allow uploading SVGs [\#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-core**: Do not leak image processing errors [\#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-core**, **decidim-proposals**, **decidim-participatory_processes**, **decidim-meetings**, **decidim-sortitions**: XSS sanitization [\#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-core**: Fix the scopes picker rendereding escaped characters [#5939](https://github.com/decidim/decidim/pull/5939)
- **decidim-core**: Fix the destroy account command removing relations with spaces [\#6041](https://github.com/decidim/decidim/pull/6041)
- **decidim-core**: Avoid server hanging up when rendering newsletter templates previews on develoment or test env [\#6096](https://github.com/decidim/decidim/pull/6096)
- **decidim-initiatives**: Fix attachments related module inclusion [\#6140](https://github.com/decidim/decidim/pull/6140)
- **decidim-core**: Fix scopes filter when a participatory space scope has subscopes [\#6110](https://github.com/decidim/decidim/pull/6110)
- **decidim-core**, **decidim-assemblies**: Fix the edit link test failing seemingly randomly [\#6161](https://github.com/decidim/decidim/pull/6161)
- **decidim-participatory_processes**: Fix the edit link test failing randomly for participatory processes spec [\#6180](https://github.com/decidim/decidim/pull/6180)

**Removed**:

- **decidim-comments**: Fix comments JS errors and delays [\#6193](https://github.com/decidim/decidim/pull/6193)
- **decidim-elections**: Improve navigation consistency in the admin zone for elections questions and answers [\#6139](https://github.com/decidim/decidim/pull/6139)
- **decidim-participatory_processes**: Fix rubocop errors arising from capybara upgrade [\#6197](https://github.com/decidim/decidim/pull/6197)
- **decidim-assemblies**: Fix rubocop errors arising from capybara upgrade [\#6197](https://github.com/decidim/decidim/pull/6197)
- **decidim-proposals**: Fix rubocop errors arising from capybara upgrade [\#6197](https://github.com/decidim/decidim/pull/6197)
- **decidim-dev**: Fix rubocop errors arising from capybara upgrade [\#6197](https://github.com/decidim/decidim/pull/6197)
- **decidim-core**: Fix rubocop errors arising from capybara upgrade [\#6197](https://github.com/decidim/decidim/pull/6197)
- **decidim-forms**: Fix rubocop errors arising from capybara upgrade [\#6197](https://github.com/decidim/decidim/pull/6197)

- **decidim-assemblies**: Removed legacy `assembly_type` fields. [\#5617](https://github.com/decidim/decidim/pull/5617)

## Previous versions

Please check [release/0.22-stable](https://github.com/decidim/decidim/blob/release/0.22-stable/CHANGELOG.md) for previous changes.
