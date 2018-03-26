# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

**Upgrade notes**:

This version has breaking changes, `Decidim::Feature` has been renamed to `Decidim::Component`,
and also everything related to it (controllers, views, etc.). If you have customised some
controller or added a new module you need to rename `feature` to `component`.

**Added**:

- **decidim-debates**: Fix debates times. [\#3071](https://github.com/decidim/decidim/pull/3071)
- **decidim-sortitions**: Decidim Sortitions Gem has been  integrated into the  main  repository. [\#3077](https://github.com/decidim/decidim/pull/3077)
- **decidim-meetings**: Allows admins to duplicate or copy face-to-face meetings. [\#3051](https://github.com/decidim/decidim/pull/3051)
- **decidim**: Added private_space and participatory space private users. [\#2618](https://github.com/decidim/decidim/pull/2618)
- **decidim-core**: Add ParticipatorySpaceResourceable between Assemblies and ParticipatoryProcesses [\#2851](https://github.com/decidim/decidim/pull/2851)
- **decidim**: Rename features to components [\#2913](https://github.com/decidim/decidim/pull/2913)
- **decidim-admin**: Log actions on areas [\#2944](https://github.com/decidim/decidim/pull/2944)
- **decidim-budgets**: Log actions on projects [\#2949](https://github.com/decidim/decidim/pull/2949)
- **decidim-meetings**: Log meeting registration exports [\#2922](https://github.com/decidim/decidim/pull/2922)
- **decidim-accountability**: Log results deletion [\#2923](https://github.com/decidim/decidim/pull/2923)
- **decidim-surveys**: Allow reordering questions via "Up" & "Down" buttons [\#3005](https://github.com/decidim/decidim/pull/3005)
- **decidim-comments**: Add more notification types when a comment is created [\#3004](https://github.com/decidim/decidim/pull/3004)
- **decidim-debates**: Show debates stats in homepage and space pages [\#3016](https://github.com/decidim/decidim/pull/3016)
- **decidim-core**: [\#3022](https://github.com/decidim/decidim/pull/3022)
  + Introduce `ViewModel` and `Cells` to make it possible to add cards to resources.
  + Add `CardHelper` with `card_for` that returns a card given an instance of a the Component attribute `card` from the ComponentManifest.
  + Add `AuthorBoxCell` and `ProfileCell`; Remove `shared/author_reference` partials.
- **decidim**: Add documentation for `ViewModel` and `CardCells` `docs/advanced/view_models_aka_cells.md` [\#3022](https://github.com/decidim/decidim/pull/3022)
- **decidim-dev**: Add `rspec-cells` for testing `Cells` [\#3022](https://github.com/decidim/decidim/pull/3022)
- **decidim-meetings**: [\#3022](https://github.com/decidim/decidim/pull/3022)
  + Introduce `ViewModel` and `Cells`. Add `MeetingCell` with two variations: `MeetingMCell` and `MeetingListItemCell`.
  + Add the `card` attribute to the component's manifest `shared/author_reference` partials.
- **decidim-surveys**: Add rich text description to questions [\#3066](https://github.com/decidim/decidim/pull/3066).
- **decidim-proposals**: Add discard draft button in wizard [\#3064](https://github.com/decidim/decidim/pull/3064)

**Changed**:

- **decidim-participatory_processes**: Render documents in first place (before view hooks). [\#2977](https://github.com/decidim/decidim/pull/2977)

**Fixed**:

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

Please check [0.10-stable](https://github.com/decidim/decidim/blob/0.10-stable/CHANGELOG.md) for previous changes.
