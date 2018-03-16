# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

**Upgrade notes**:

This version has breaking changes, `Decidim::Feature` has been renamed to `Decidim::Component`,
and also everything related to it (controllers, views, etc.). If you have customised some
controller or added a new module you need to rename `feature` to `component`.

**Added**:

- **decidim-assemblies**: Adding news fields into assembly in terms of database [\#2942](https://github.com/decidim/decidim/pull/2942)
- **decidim**: Added private_space and participatory space private users. [\#2618](https://github.com/decidim/decidim/pull/2618)
- **decidim-core**: Add ParticipatorySpaceResourceable between Assemblies and ParticipatoryProcesses [\#2851](https://github.com/decidim/decidim/pull/2851)
- **decidim**: Rename features to components [\#2913](https://github.com/decidim/decidim/pull/2913)
- **decidim-admin**: Log actions on areas [\#2944](https://github.com/decidim/decidim/pull/2944)
- **decidim-budgets**: Log actions on projects [\#2949](https://github.com/decidim/decidim/pull/2949)
- **decidim-meetings**: Log meeting registration exports [\#2922](https://github.com/decidim/decidim/pull/2922)
- **decidim-accountability**: Log results deletion [\#2923](https://github.com/decidim/decidim/pull/2923)
- **decidim-surveys**: Allow reordering questions via "Up" & "Down" buttons [\#3005](https://github.com/decidim/decidim/pull/3005)
- **decidim-comments**: Add more notification types when a comment is created [\#3004](https://github.com/decidim/decidim/pull/3004)

**Changed**:

- **decidim-participatory_processes**: Render documents in first place (before view hooks). [\#2977](https://github.com/decidim/decidim/pull/2977)

**Fixed**:

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

Please check [0.10-stable](https://github.com/decidim/decidim/blob/0.10-stable/CHANGELOG.md) for previous changes.
