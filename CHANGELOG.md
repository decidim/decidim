# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

**Fixed**:

## [v0.9.0](https://github.com/decidim/decidim/tree/v0.9.0) (2018-2-5)
[Full Changelog](https://github.com/decidim/decidim/compare/v0.8.0...v0.9.0)
**Upgrade notes**:

Since uglifier `4.0.0`, we need to set `harmony: true` as options in uglifier. This means
you need to change the following line in `config/environments/production.rb`:

```diff
- config.assets.js_compressor = :uglifier
+ config.assets.js_compressor = Uglifier.new(:harmony => true)
```

**Added**:

- **decidim-admin**: Adds administration interface for highlighted content banner [\#2572](https://github.com/decidim/decidim/pull/2572)
- **decidim-core**: Adds support for highlighted content banner.[\#2572](https://github.com/decidim/decidim/pull/2572)
- **decidim-core**: Added support for content processors. [\#2491](https://github.com/decidim/decidim/pull/2491)
- **decidim-comments**: Added support to mention other users and notify them. [\#2491](https://github.com/decidim/decidim/pull/2491)
- **decidim**: Refactor and DRY Decidim events. [\#2582](https://github.com/decidim/decidim/pull/2582)
- **decidim-core**: Added support for omnipresent banner. [\#2547](https://github.com/decidim/decidim/pull/2547)
- **decidim-admin**: Added administration interface for omnipresent banner. [\#2547](https://github.com/decidim/decidim/pull/2547)
- **decidim**: Rubocop has been upgraded. Ruby version in gem specs now fits with ruby version that rubocop uses. [\#2548](https://github.com/decidim/decidim/pull/2548)
- **decidim-admin**: Notify participatory process followers when a step becomes active. [\#2544](https://github.com/decidim/decidim/pull/2544)
- **decidim-admin**: Notify participatory space followers when a new feature is published. [\#2515](https://github.com/decidim/decidim/pull/2515)
- **decidim**: Add `decidim-assemblies` to the `decidim` metagem. [\#2510](https://github.com/decidim/decidim/pull/2510)
- **decidim-proposals**: Notify proposal followers when it gets answered. [\#2508](https://github.com/decidim/decidim/pull/2508)
- **decidim-proposals**: Add private notes by admins to proposal [\#2490](https://github.com/decidim/decidim/pull/2490)
- **decidim-core:** Extends public profile with personal URL and about text. Receive notifications when a profile is updated. [\2494](https://github.com/decidim/decidim/pull/2494)
- **decidim-core:** Improve Newsletter adding unsubscribe link, see on website, UTM GET codes [\2359](https://github.com/decidim/decidim/pull/2359)
- **decidim-verifications**: Added action authorizers for authorization handlers. [\#2438](https://github.com/decidim/decidim/pull/2438)
- **decidim-accountability**: Add feature to link projects with results [\#2467](https://github.com/decidim/decidim/pull/2467)
- **decidim-proposals**: Withdrawing of proposals [\#2289](https://github.com/decidim/decidim/issues/2289).
- **decidim-proposals**: Improve proposals admin panel usability (sorting). [\#2419](https://github.com/decidim/decidim/pull/2419)
- **decidim-proposals**: Users and user_groups can now endorse proposals. [\#2287](https://github.com/decidim/decidim/pull/2287)
- **decidim-core**: Follow users and get notifications about their actions [\#2401](https://github.com/decidim/decidim/pull/2401) and [\#2452](https://github.com/decidim/decidim/pull/2452).
- **decidim-core**: Add unique nicknames for participants. [\#2360](https://github.com/decidim/decidim/pull/2360)
- **decidim-admin**: Let admins officialize certain users from the admin dashboard and specify custom officialization text for them. [\#2405](https://github.com/decidim/decidim/pull/2405)
- **decidim-core**: Public profile page for participants, including name, nickname, follow button, avatar and officialization badge & text. [\#2391](https://github.com/decidim/decidim/pull/2391), [\#2360](https://github.com/decidim/decidim/pull/2360), [\#2401](https://github.com/decidim/decidim/pull/2401) and [\#2405](https://github.com/decidim/decidim/pull/2405).
- **decidim-core**: Add a way for space manifests to publicize how to retrieve public spaces for a given organization [\#2384](https://github.com/decidim/decidim/pull/2384)
- **decidim-participatory_processes**: Add missing translations for processes [\#2380](https://github.com/decidim/decidim/pull/2380)
- **decidim-verifications**: Let developers specify for how long authorizations are valid. After this space of time passes, authorizations expire and users need to re-authorize [\#2311](https://github.com/decidim/decidim/pull/2311)
- **decidim-assemblies**: Add user roles for assemblies. [\2463](https://github.com/decidim/decidim/pull/2463)
- **decidim**: Scopes picker that allows hierarchical browsing scope to select them ([\#2330](https://github.com/decidim/decidim/pull/2330)).
  This picker was used to replace all Select2 based scope selectors. Any module using the Select2 scope selector should replace this:
  ```erb
   <%= form.scopes_select :scope_id, prompt: t("decidim.scopes.global"), remote_path: decidim.scopes_search_path %>
  ```
  with this:
  ```erb
  <%= scopes_picker_field form, :scope_id %>
  ```
  or this, for filter scopes picker:
  ```erb
  <%= scopes_picker_filter form, :scope_id %>
  ```
- **decidim-debates**: New Debates component available for all spaces [\#2506](https://github.com/decidim/decidim/pull/2506)

**Changed**:

- **decidim-comments**: Changed the counters to count all comments from all levels instead of only the top-level ones [\#2551](https://github.com/decidim/decidim/pull/2551)
- **decidim-core**: [Breaking change] Changes the participatory space's contracts introducing `context`. This was done to fix a bug caused by dynamically extending some controllers. [\#2465](https://github.com/decidim/decidim/pull/2465)
- **decidim-core**: Removed horizontal scroll from process navigation bar. [\#2495](https://github.com/decidim/decidim/pull/2495)
- **decidim-core**: Fixes the documentation regarding gems, libraries, plugins and modules. We should always use module, and use decidim-module-<engine_name> nomenclature for repositories naming [\#2481](https://github.com/decidim/decidim/pull/2481).
- **decidim-core**: Users have notifications enabled by default unless they explicitly uncheck it during registration. [\#2517](https://github.com/decidim/decidim/pull/2517)
- **decidim-core**: Decidim now runs on Ruby 2.5.0 by default, although 2.3+ is expected to work well. [\#2550](https://github.com/decidim/decidim/pull/2550)
- **decidim-core**: translated_attribute helper changes its default behaviour. Previously it was following these steps:
  1. Return the current user locale translation if available.
  2. Fallback to organization default locale in case the user locale translation is not available.
  3. Otherwise return blank.
- **decidim-core**: Forced order in conversations (newest on top) and conversation messages (oldest on top). [\#2520](https://github.com/decidim/decidim/pull/2520)
- **decidim-dev**: Decidim now uses Rails' system tests instead of feature tests [\#2516](https://github.com/decidim/decidim/pull/2516)
  1. Move your tests from `spec/features/` to `spec/system/`
  2. Change `type: :feature` to `type: :system`


  Now it follows these steps:

  1. Return the current user locale translation if available.
  2. Fallback to organization default locale in case the user locale translation is not available.
  3. Fallback to the first available translation in case there was no user nor default organization locale translations.
  4. Otherwise return blank.

**Fixed**:

- **decidim-accountability**: Calculate progress average considering all items [\#2638](https://github.com/decidim/decidim/pull/2638)
- **decidim-proposals**: Fix test redirect. [\#2633](https://github.com/decidim/decidim/pull/2633)
- **decidim-core**: Don't allow conversations between the same user. [\#2630](https://github.com/decidim/decidim/pull/2630)
- **decidim-core**: Remove Sendgrid and Heroku references. [\#2634](https://github.com/decidim/decidim/pull/2634)
- **decidim-core**: Notify admins when no valid authorization handlers are available to create managed users. [\#2631](https://github.com/decidim/decidim/pull/2631)
- **decidim-core**: Fix user re-invite. [\#2626](https://github.com/decidim/decidim/pull/2626)
- **decidim-core**: Allow underscores at CTA button path. [\#2625](https://github.com/decidim/decidim/pull/2625)
- **decidim-core**: Fix editing features in assemblies. [\#2524](https://github.com/decidim/decidim/pull/2524)
- **decidim-core**: Fix the texts of 'New Message' email notifications. [\#2588](https://github.com/decidim/decidim/pull/2588)
- **decidim-admin**: Properly save features weight on creation [\#2499](https://github.com/decidim/decidim/pull/2499)
- **decidim-core**: Fix after login redirect. [\#2321](https://github.com/decidim/decidim/pull/2321) [\#2504](https://github.com/decidim/decidim/pull/2504)
  With links or buttons that needs the user to be authorized or signed in you can now add a `data-redirect-url` attribute to redirect the user after they've signed in so they don't lose context.
- **decidim-core**: Prevent many conversation with the same participants at the UI level. [\#2376](https://github.com/decidim/decidim/pull/2376)
- **decidim-core**: Order conversation messages by creation. [\#2520](https://github.com/decidim/decidim/pull/2520)
- **decidim-admin**: Admins no longer being able to impersonate a second time. [\#2372](https://github.com/decidim/decidim/pull/2372)
- **decidim-admin**: User impersonation should only use authorization handlers and not authorization workflows. [\#2363](https://github.com/decidim/decidim/pull/2363)
- **decidim-budgets**: Prevent double-click form submissions [\#2379](https://github.com/decidim/decidim/pull/2379)
- **decidim-core**: Impossible to access conversation page from mobile devices. [\#2364](https://github.com/decidim/decidim/pull/2364)
- **decidim-core**: Update home page stat categories [\#2221](https://github.com/decidim/decidim/pull/2221)
- **decidim-core**: Prevent double-click form submissions [\#2379](https://github.com/decidim/decidim/pull/2379)
- **decidim-core**: Clean conversations textarea after sending a private message [\#2379](https://github.com/decidim/decidim/pull/2379)
- **decidim-meetings**: Prevent double-click form submissions [\#2379](https://github.com/decidim/decidim/pull/2379)
- **decidim-participatory_processes**: Fix the processes filter [\#2552](https://github.com/decidim/decidim/pull/2552)
- **decidim-proposals**: Do not allow attachments on proposals edition [\#2221](https://github.com/decidim/decidim/pull/2221)
- **decidim-proposals**: Prevent double-click form submissions [\#2379](https://github.com/decidim/decidim/pull/2379)
- **decidim-proposals**: Fix missing icon on proposal reply.
- **decidim-proposals**: Fix missing icon on proposal admin index.
- **decidim-surveys**: Prevent double-click form submissions [\#2379](https://github.com/decidim/decidim/pull/2379)
- **decidim-surveys**: Updated icon for surveys feature [\#2433](https://github.com/decidim/decidim/pull/2433)
- **decidim-verifications**: Fixed a migration that broke feature permissions. If you already upgraded to `0.8.2` or less, please follow the instructions on the PR [\#2373](https://github.com/decidim/decidim/pull/2373)
- **decidim-accountability**: Fix children results count [\#2483](https://github.com/decidim/decidim/pull/2483)
- **decidim-accountability**: Keeps the current scope in the breadcumb links [\#2488](https://github.com/decidim/decidim/pull/2488)
- **decidim-accountability**: Top level search searches on all results (not only the first level) [\#2545](https://github.com/decidim/decidim/pull/2545)
- **decidim-admin**: Visual bug in quilljs editor misleading admins into introducing blank lines to separate paragraphs. [\#2565](https://github.com/decidim/decidim/pull/2565).
- **decidim-admin**: Properly highlight the Settings admin menu item when visiting the scope types section. [\#2642](https://github.com/decidim/decidim/pull/2642)

**Removed**:

- **decidim**: Select2 JS library and scope selector based on Select2.
- **dedicim-accountability**: Removed the Global scope navigation option ([\#2486](https://github.com/decidim/decidim/pull/2486))

## [v0.8.0](https://github.com/decidim/decidim/tree/v0.8.0) (2017-12-4)
[Full Changelog](https://github.com/decidim/decidim/compare/v0.7.0...v0.8.0)
[Migration guide](https://github.com/decidim/decidim/blob/master/docs/migrate_to_0.8.0.md)

**Added**:

- **decidim-accountability**: Add result tracing and version diffing [\#2206](https://github.com/decidim/decidim/pull/2206)
- **decidim-assemblies**: Show promoted assemblies in the homepage [\#2162](https://github.com/decidim/decidim/pull/2162)
- **decidim-core**: Add support for extending the user profile menu. [\#2193](https://github.com/decidim/decidim/pull/2193)
- **decidim-core**: Add view hooks so external engines can extend the homepage and other sections with their own code [\#2114](https://github.com/decidim/decidim/pull/2114)
- **decidim-core**: Add the ability to register Global Engines that sit at the root of the project. [\#2194](https://github.com/decidim/decidim/pull/2194)
- **decidim-core**: Private one to one conversations [\#2186](https://github.com/decidim/decidim/pull/2186)
- **decidim-proposals**: Admins can set a minute window after the creation of a proposal in which the proposal can be edited by its author. Once the window has passed, it cannot be edited. [\#2171](https://github.com/decidim/decidim/pull/2171)
- **decidim-verifications**: Support for deferred verification methods that require several steps in order to be granted. [\#2024](https://github.com/decidim/decidim/pull/2024)
- **decidim-assemblies**: Assemblies now have a reference [\#2557](https://github.com/decidim/decidim/pull/2557)
- **decidim-core**: Let participatory spaces have reference [\#2557](https://github.com/decidim/decidim/pull/2557)
- **decidim-meetings**: Add simple formatting to debates fields to improve readability [\#2670](https://github.com/decidim/decidim/issues/2670)
- **decidim-meetings**: Notify participatory space followers when a meeting is created. [\#2646](https://github.com/decidim/decidim/pull/2646)
- **decidim-participatory_processes**: Processes now have a reference [\#2557](https://github.com/decidim/decidim/pull/2557)
- **decidim-proposals**: Notify participatory space followers when a proposal is created. [\#2646](https://github.com/decidim/decidim/pull/2646)
- **decidim-proposals**: Copy proposals to another component [\#2619](https://github.com/decidim/decidim/issues/2619).

- **decidim-participatory_processes**: Ensure only active processes are shown in the highlighted processes section in the homepage[\#2682](https://github.com/decidim/decidim/pull/2682)

**Changed**:

- **decidim-core**: General improvements on documentation [\#2656](https://github.com/decidim/decidim/pull/2656).
- **decidim-core**: `FeatureReferenceHelper#feature_reference` has been moved to `ResourceReferenceHelper#resource_reference` to clarify its use. [\#2557](https://github.com/decidim/decidim/pull/2557)
- **decidim-core**: `Decidim.resource_reference_generator` has been moved to `Decidim.reference_generator` to clarify its use. [\#2557](https://github.com/decidim/decidim/pull/2557)

**Fixed**:

- **decidim-participatory_processes**: Fix find a process by its ID.[\#2672](https://github.com/decidim/decidim/pull/2672)
- **decidim-assemblies**: Fix find an assembly by its ID.[\#2672](https://github.com/decidim/decidim/pull/2672)
- **decidim-core**: Fix notification mailer when a resource doesn't have an organization. [\#2661](https://github.com/decidim/decidim/pull/2661)
- **decidim-comments**: Fix comment notifications listing. [\#2652](https://github.com/decidim/decidim/pull/2652)
- **decidim-participatory_processes**: Fix editing a process after an error.[\#2653](https://github.com/decidim/decidim/pull/2653)
- **decidim-assemblies**: Fix editing a process after an error.[\#2653](https://github.com/decidim/decidim/pull/2653)

Please check [0.9-stable](https://github.com/decidim/decidim/blob/0.9-stable/CHANGELOG.md) for previous changes.
