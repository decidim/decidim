# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/0.11-stable)

**Added**:

**Changed**:

**Fixed**:

## [0.11.2](https://github.com/decidim/decidim/tree/v0.11.2)

**Added**:

**Changed**:

**Fixed**:

- **decidim-generators**: Dummy applications not being correctly generated for external plugins. [\#3470](https://github.com/decidim/decidim/pull/3470)
- **decidim-generators**: Dummy applications not being correctly generated for final applications. [\#3527](https://github.com/decidim/decidim/pull/3527)
- **decidim-core**: Data picker form inputs having no bottom margin. [\#3463](https://github.com/decidim/decidim/pull/3463)
- **decidim-core**: Adds a missing migration to properly rename features to components [\#3656](https://github.com/decidim/decidim/pull/3656)

## [0.11.1](https://github.com/decidim/decidim/tree/v0.11.1)

**Upgrade notes**:

This version has breaking changes, `Decidim::Feature` has been renamed to `Decidim::Component`,
and also everything related to it (controllers, views, etc.). If you have customised some
controller or added a new module you need to rename `feature` to `component`.

With the addition of the new step "Complete" to the proposal creation wizard,
administrators should keep in mind updating the help texts for each step.

**Added**:

- **decidim-initiatives**: Decidim Initiatives Gem has been integrated into the main repository. [\#3125](https://github.com/decidim/decidim/pull/3125)
- **decidim-blogs**: Decidim Blogs gem has been integrated into the main repository. [\#3221](https://github.com/decidim/decidim/pull/3221)
- **decidim-meetings** Add services offered in the meeting. [\#3150](https://github.com/decidim/decidim/pull/3150)
- **decidim-assemblies**: Adding news fields into assembly in terms of database [\#2942](https://github.com/decidim/decidim/pull/2942)
- **decidim-proposals**: Add configuration for set the number of proposals to be highlighted [\#3175](https://github.com/decidim/decidim/pull/3175)
- **decidim-meetings**: Add new fields to meetings registrations [\#3123](https://github.com/decidim/decidim/pull/3123)
- **decidim-admin**: Decidim as OAuth provider [\#3057](https://github.com/decidim/decidim/pull/3057)
- **decidim-core**: Decidim as OAuth provider [\#3057](https://github.com/decidim/decidim/pull/3057)
- **decidim-consultations**: Decidim Consultations Gem has been  integrated into the  main  repository. [\#3106](https://github.com/decidim/decidim/pull/3106)
- **decidim-debates**: Fix debates times. [\#3071](https://github.com/decidim/decidim/pull/3071)
- **decidim-sortitions**: Decidim Sortitions Gem has been integrated into the main repository. [\#3077](https://github.com/decidim/decidim/pull/3077)
- **decidim-meetings**: Allows admins to duplicate or copy face-to-face meetings. [\#3051](https://github.com/decidim/decidim/pull/3051)
- **decidim**: Added private_space and participatory space private users. [\#2618](https://github.com/decidim/decidim/pull/2618)
- **decidim-core**: Add ParticipatorySpaceResourceable between Assemblies and ParticipatoryProcesses [\#2851](https://github.com/decidim/decidim/pull/2851)
- **decidim-assemblies**: Allow an assembly to have children [\#2938](https://github.com/decidim/decidim/pull/2938)
- **decidim**: Rename features to components [\#2913](https://github.com/decidim/decidim/pull/2913)
- **decidim-admin**: Log actions on areas [\#2944](https://github.com/decidim/decidim/pull/2944)
- **decidim-budgets**: Log actions on projects [\#2949](https://github.com/decidim/decidim/pull/2949)
- **decidim-meetings**: Log meeting registration exports [\#2922](https://github.com/decidim/decidim/pull/2922)
- **decidim-accountability**: Log results deletion [\#2923](https://github.com/decidim/decidim/pull/2923)
- **decidim-surveys**: Allow reordering questions via "Up" & "Down" buttons [\#3005](https://github.com/decidim/decidim/pull/3005)
- **decidim-comments**: Add more notification types when a comment is created [\#3004](https://github.com/decidim/decidim/pull/3004)
- **decidim-debates**: Show debates stats in homepage and space pages [\#3016](https://github.com/decidim/decidim/pull/3016)
- **decidim-core**: [\#3022](https://github.com/decidim/decidim/pull/3022)
  - Introduce `ViewModel` and `Cells` to make it possible to add cards to resources.
  - Add `CardHelper` with `card_for` that returns a card given an instance of a the Component attribute `card` from the ComponentManifest.
  - Add `AuthorBoxCell` and `ProfileCell`; Remove `shared/author_reference` partials.
- **decidim**: Add documentation for `ViewModel` and `CardCells` `docs/advanced/view_models_aka_cells.md` [\#3022](https://github.com/decidim/decidim/pull/3022)
- **decidim-dev**: Add `rspec-cells` for testing `Cells` [\#3022](https://github.com/decidim/decidim/pull/3022)
- **decidim-meetings**: [\#3022](https://github.com/decidim/decidim/pull/3022)
  - Introduce `ViewModel` and `Cells`. Add `MeetingCell` with two variations: `MeetingMCell` and `MeetingListItemCell`.
  - Add the `card` attribute to the component's manifest `shared/author_reference` partials.
- **decidim-surveys**: Add rich text description to questions [\#3066](https://github.com/decidim/decidim/pull/3066).
- **decidim-proposals**: Add discard draft button in wizard [\#3064](https://github.com/decidim/decidim/pull/3064)
- **decidim-surveys**: Allow multiple choice questions to specify a maximum number of options to be checked [\#3091](https://github.com/decidim/decidim/pull/3091)
- **decidim-surveys**: Client side survey errors are now displayed [\#3133](https://github.com/decidim/decidim/pull/3133)
- **decidim-surveys**: Allow multiple choice questions to have "free text options" where the user can customize the selected answer [\#3134](https://github.com/decidim/decidim/pull/3134)
- **decidim-surveys**: New question type to sort different options [\#3148](https://github.com/decidim/decidim/pull/3148)
- **decidim-budgets**: Setting to control the number of projects per page to be listed [\#3239](https://github.com/decidim/decidim/pull/3239)
- **decidim-admin**: Regular users can now be impersonated [\#3226](https://github.com/decidim/decidim/pull/3226)
- **decidim-admin**: All available authorization handlers can always be chosen for impersonation even after the first impersonation [\#3226](https://github.com/decidim/decidim/pull/3226)
- **decidim-generators**: New gem where all of decidim generators live, both to generate final application and decidim components (plugins).
- **decidim-meetings**: Add WYSIWYG editor for meeting closing notes [\#3265](https://github.com/decidim/decidim/pull/3265)
- **decidim-meetings**: Add formatting of the list of organizations attending to a meeting [\#3265](https://github.com/decidim/decidim/pull/3265)
- **decidim-core**: Order components by both weight and manifest_name so the order is kept [\#3264](https://github.com/decidim/decidim/pull/3264)
- **decidim-meetings**: Add a meetings API. [\#3255](https://github.com/decidim/decidim/pull/3255)
- **decidim-proposals**: Add "complete" step to the proposal creation wizard [\#3274](https://github.com/decidim/decidim/pull/3274)

**Changed**:

- **decidim-proposals**: Extract partials in Proposals into helper methors so that they can be reused in collaborative draft. [\#3238](https://github.com/decidim/decidim/pull/3238)
- **decidim-admin**: Moved the following reusable javascript components from `decidim-surveys` component [\#3194](https://github.com/decidim/decidim/pull/3194)
  - Nested resources (auto_buttons_by_position.component.js.es6, auto_label_by_position.component.js.es6, dynamic_fields.component.js.es6)
  - Dependent inputs (field_dependent_inputs.component.js.es6)
- **decidim-surveys**: Moved the following reusable javascript components to `decidim-admin` component [\#3194](https://github.com/decidim/decidim/pull/3194)
  - Nested resources (auto_buttons_by_position.component.js.es6, auto_label_by_position.component.js.es6, dynamic_fields.component.js.es6)
  - Dependent inputs (field_dependent_inputs.component.js.es6)
- **decidim-participatory_processes**: Render documents in first place (before view hooks). [\#2977](https://github.com/decidim/decidim/pull/2977)
- **decidim-verifications**: If you're using a custom authorization handler template, make sure it does not include the button. Decidim takes care of that for you so including it will from no now cause duplicated buttons in the form. [\#3211](https://github.com/decidim/decidim/pull/3211)
- **decidim-accountability**: Include children information in main column [\#3217](https://github.com/decidim/decidim/pull/3217)
- **decidim-core**: Open attachments in new tab [\#3245](https://github.com/decidim/decidim/pull/3245)
- **decidim-core**: Open space hashtags in new tab [\#3246](https://github.com/decidim/decidim/pull/3246)
- **decidim-proposals**: Withdrawn proposals are excluded from count limit and stats. [\#3275](https://github.com/decidim/decidim/pull/3238)

**Fixed**:

- **decidim-core**: Fixes the linked_resources_for method to only show the resources that has the component published. [\#3430](https://github.com/decidim/decidim/pull/3430)
- **decidim-accountability**: Fixes linking proposals to results for accountability on creation time. [\#3167](https://github.com/decidim/decidim/pull/3262)
- **decidim-proposals**: Fixes clicking on "see all" should remove the ellipsis sign. [\#2894](https://github.com/decidim/decidim/pull/3238)
- **decidim-proposals**: Ignore already imported proposals when importing them [\#3257](https://github.com/decidim/decidim/pull/3257)
- **decidim-proposals**: Fixes clicking on "see all" should remove the ellipsis sign. [\#3238](https://github.com/decidim/decidim/pull/3238)
- **decidim-core**: Add missing locales in Freanch fot the datepicker [\#3260](https://github.com/decidim/decidim/pull/3260)
- **decidim-proposals**: Fixes clicking on "see all" should remove the ellipsis sign. \#2894](https://github.com/decidim/decidim/pull/3238)
- **decidim-proposals**: Restore creation date in proposal detail page. [\#3249](https://github.com/decidim/decidim/pull/3249)
- **decidim-proposals**: Fix threshold_per_proposal method positive? for nil:NilClass when threshold is null or not defined. [\#3185](https://github.com/decidim/decidim/pull/3185)
- **decidim-proposals**: Make sure threshold per proposal has the right value in existing components [\#3235](https://github.com/decidim/decidim/pull/3235)
- **decidim-proposals**: Fix when I create a proposal I see the draft proposal from someone else! [\#3170](https://github.com/decidim/decidim/pull/3083)
- **decidim-proposals**: Fix view hooks returning proposals that should not be shown [\#3175](https://github.com/decidim/decidim/pull/3175)
- **decidim-debates**: Fix debates times. [\#3071](https://github.com/decidim/decidim/pull/3071)
- **decidim-proposals**: Fix Feedback needed after Endorsing when user has no user_groups [\#2968](https://github.com/decidim/decidim/pull/2998)
- **decidim-proposals**: Fix threshold absolute view and rename the field maximum_votes_per_proposal to threshold_per_proposal. [\#2994](https://github.com/decidim/decidim/pull/2994)
- **decidim-proposals**: Fix proposal endorsed event [\#2970](https://github.com/decidim/decidim/pull/2970)
- **decidim-accountability**: Fix parent results progress [\#2954](https://github.com/decidim/decidim/pull/2954)
- **decidim-core**: Fix `Decidim::UserPresenter#nickname` [\#2958](https://github.com/decidim/decidim/pull/2958)
- **decidim-verifications**: Only show authorizations from current organization [\#2959](https://github.com/decidim/decidim/pull/2959)
- **decidim-comments**: Fix mentions not working properly.  [\#2947](https://github.com/decidim/decidim/pull/2947)
- **decidim-proposals**: Fix proposal endorsed event  generation [\#2983](https://github.com/decidim/decidim/pull/2983)
- **decidim-core**: foundation-rails 6.4.3 support [\#2995](https://github.com/decidim/decidim/pull/2995)
- **decidim-surveys**: Fix errored questions being re-rendered with disabled inputs [\#3014](https://github.com/decidim/decidim/pull/3014)
- **decidim-surveys**: Fix errored questions rendering answer options as empty fields [\#3014](https://github.com/decidim/decidim/pull/3014)
- **decidim-surveys**: Fix translated fields of freshly created questions not working after form errors [\#3026](https://github.com/decidim/decidim/pull/3026)
- **decidim-surveys**: Fix question form errors not being displayed [\#3046](https://github.com/decidim/decidim/pull/3046)
- **decidim-admin**: Require organization's `reference_prefix` at the form level [\#3056](https://github.com/decidim/decidim/pull/3056)
- **decidim-core**: Only require caps on the first line with `EtiquetteValidator` [\#3072](https://github.com/decidim/decidim/pull/3072)
- **decidim-proposals**: Fix notification sent when proposal draft was created, now sent on publish. [\#3065](https://github.com/decidim/decidim/pull/3065)
- **decidim-surveys**: Multiple choice questions without answer options can no longer be created [\#3087](https://github.com/decidim/decidim/pull/3087)
- **decidim-surveys**: Multiple choice questions with empty answer options can no longer be created [\#3087](https://github.com/decidim/decidim/pull/3087)
- **decidim-surveys**: Preserve deleted status of questions accross submission failures [\#3089](https://github.com/decidim/decidim/pull/3089)
- **decidim-surveys**: Question type selector not disabled when survey has already been answered [\#3133](https://github.com/decidim/decidim/pull/3133)
- **decidim-surveys**: Max choices selector not disabled when survey has already been answered [\#3133](https://github.com/decidim/decidim/pull/3133)
- **decidim-surveys**: Translated fields not disabled when survey has already been answered [\#3133](https://github.com/decidim/decidim/pull/3133)
- **decidim-admin**: Default managed user form displaying two buttons [\#3211](https://github.com/decidim/decidim/pull/3211)
- **decidim-admin**: Dropdown menus appearance on hover [\#3241](https://github.com/decidim/decidim/pull/3241)
- **decidim-admin**: Ability to select leaf categories from Admin change-category bulk action [\#3243](https://github.com/decidim/decidim/pull/3243)
- **decidim-admin**: Highlighted banner image is not required if already present in the organization [\#3244](https://github.com/decidim/decidim/pull/3244)
- **decidim-proposals**: Keep the user group (if set) as default value of author field on forms [\#3247](https://github.com/decidim/decidim/pull/3247)
- **decidim**: Fix the dependency of `high_voltage` to `v3.0.0` [\#3383](https://github.com/decidim/decidim/pull/3383)
- **decidim-blog**: Add `params[:id]` when editing/deleting a post from admin site [\#3360](https://github.com/decidim/decidim/pull/3360)
- **decidim-admin**: Fixes the validation uniqueness name of area, scoped with organization and area_type [\#3350](https://github.com/decidim/decidim/pull/3350)
- **decidim-surveys**: Fix a N+1 in surveys [\#333493](https://github.com/decidim/decidim/pull/3493)
- **decidim-core**: Search results should be paginated so that server does not hang when search term is too wide. [\#3605](https://github.com/decidim/decidim/pull/3605)
- **decidim-assemblies**: Fix private assemblies showing more than once for private users. [\#3638](https://github.com/decidim/decidim/pull/3638)
- **decidim-proposals**: Do not index non published Proposals. [\#3618](https://github.com/decidim/decidim/pull/3618)
- **decidim-proposals**: Fix link to endorsements behaviour, now it does not link when there are no endorsements. [\#3531](https://github.com/decidim/decidim/pull/3531)
- **decidim-meetings**: Fix meetings M card cell so that it works outside the component [\#3612](https://github.com/decidim/decidim/pull/3612)
- **decidim-proposals**: Fix proposals M card cell so that it works outside the component [\#3612](https://github.com/decidim/decidim/pull/3612)
- **decidim-blogs**: Use custom sanitizer in views instead of the default one [\#3655](https://github.com/decidim/decidim/pull/3655)
- **decidim-core**: Use custom sanitizer in views instead of the default one [\#3655](https://github.com/decidim/decidim/pull/3655)
- **decidim-initiatives**: Use custom sanitizer in views instead of the default one [\#3655](https://github.com/decidim/decidim/pull/3655)
- **decidim-sortitions**: Use custom sanitizer in views instead of the default one [\#3655](https://github.com/decidim/decidim/pull/3655)
- **decidim-core**: Fix nicknames migration [\#4936](https://github.com/decidim/decidim/pull/4936)

**Removed**:

- **decidim**: Decidim executable has been moved to the `decidim-generators` gem.

Please check [0.10-stable](https://github.com/decidim/decidim/blob/0.10-stable/CHANGELOG.md) for previous changes.
