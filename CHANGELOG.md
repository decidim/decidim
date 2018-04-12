# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

**Upgrade notes**:

This version has breaking changes, `Decidim::Feature` has been renamed to `Decidim::Component`,
and also everything related to it (controllers, views, etc.). If you have customised some
controller or added a new module you need to rename `feature` to `component`.

**Added**:

- **decidim-assemblies**: Adding news fields into assembly in terms of database [\#2942](https://github.com/decidim/decidim/pull/2942)
- **decidim-proposals**: Add configuration for set the number of proposals to be highlighted [\#3175](https://github.com/decidim/decidim/pull/3175)
- **decidim-meetings**: Add new fields to meetings registrations [\#3123](https://github.com/decidim/decidim/pull/3123)
- **decidim-admin**: Decidim as OAuth provider [\#3057](https://github.com/decidim/decidim/pull/3057)
- **decidim-core**: Decidim as OAuth provider [\#3057](https://github.com/decidim/decidim/pull/3057)
- **decidim-consultations**: Decidim Consultations Gem has been  integrated into the  main  repository. [\#3106](https://github.com/decidim/decidim/pull/3106)
- **decidim-debates**: Fix debates times. [\#3071](https://github.com/decidim/decidim/pull/3071)
- **decidim-sortitions**: Decidim Sortitions Gem has been  integrated into the  main  repository. [\#3077](https://github.com/decidim/decidim/pull/3077)
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

**Changed**:

- **decidim-admin**: Moved the following reusable javascript components from `decidim-surveys` component [\#3194](https://github.com/decidim/decidim/pull/3194)
  - Nested resources (auto_buttons_by_position.component.js.es6, auto_label_by_position.component.js.es6, dynamic_fields.component.js.es6)
  - Dependent inputs (field_dependent_inputs.component.js.es6)
- **decidim-surveys**: Moved the following reusable javascript components to `decidim-admin` component [\#3194](https://github.com/decidim/decidim/pull/3194)
  - Nested resources (auto_buttons_by_position.component.js.es6, auto_label_by_position.component.js.es6, dynamic_fields.component.js.es6)
  - Dependent inputs (field_dependent_inputs.component.js.es6)
- **decidim-participatory_processes**: Render documents in first place (before view hooks). [\#2977](https://github.com/decidim/decidim/pull/2977)
- **decidim-verifications**: If you're using a custom authorization handler template, make sure it does not include the button. Decidim takes care of that for you so including it will from no now cause duplicated buttons in the form. [\#3211](https://github.com/decidim/decidim/pull/3211)

**Fixed**:

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

Please check [0.10-stable](https://github.com/decidim/decidim/blob/0.10-stable/CHANGELOG.md) for previous changes.
