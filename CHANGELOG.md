# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

**Upgrade notes**:

This version has breaking changes, `Decidim::Feature` has been renamed to `Decidim::Component`,
and also everything related to it (controllers, views, etc.). If you have customised some
controller or added a new module you need to rename `feature` to `component`.

**Added**:

- **decidim-proposals**: Parses Proposal urls or ids in comments and rewrite them in comments as links to show Proposal. [\#2288](https://github.com/decidim/decidim/pull/2863)
- **decidim-accountability**: Proposal selection from accountability with autoComplete [\#2348](https://github.com/decidim/decidim/pull/2584)
- **decidim-assemblies**: Make admins auto follow assemblies [\#2855](https://github.com/decidim/decidim/pull/2855)
- **decidim-participatory_processes**: Make admins auto follow participatory processes [\#2855](https://github.com/decidim/decidim/pull/2855)
- **decidim-accountability**: Proposal followers are notified when a proposal is included in a result [\#2836](https://github.com/decidim/decidim/pull/2836)
- **decidim-core**: Space followers are notified when a step changes its dates [\#2833](https://github.com/decidim/decidim/pull/2833)
- **decidim-proposals**: Space followers are notified when the proposal can be created, endorsed or voted [\#2794](https://github.com/decidim/decidim/pull/2794)
- **decidim-debates**: Space followers are notified when the debate creation is enabled or disabled [\#2794](https://github.com/decidim/decidim/pull/2794)
- **decidim-surveys**: Space followers are notified when a survey is opened or closed [\#2794](https://github.com/decidim/decidim/pull/2794)
- **decidim-core**: Broadcast feature settings changes [\#2794](https://github.com/decidim/decidim/pull/2794)
- **decidim-assemblies**: Add a select field for assign an area to assemblies [\#2750](https://github.com/decidim/decidim/pull/2750)
- **decidim-core**: Add Area and AreaType to Core [\#2750](https://github.com/decidim/decidim/pull/2750)
- **decidim-proposals**: Proposals can accumulate more votes than the maximum [\#2693](https://github.com/decidim/decidim/pull/2693)
- **decidim-proposals**: Added a wizard for the creation of proposals in the public site [\#2697](https://github.com/decidim/decidim/pull/2697).
- **decidim-assemblies**: Assemblies now have a reference [\#2557](https://github.com/decidim/decidim/pull/2557)
- **decidim-core**: Let participatory spaces have reference [\#2557](https://github.com/decidim/decidim/pull/2557)
- **decidim-meetings**: Add simple formatting to debates fields to improve readability [\#2670](https://github.com/decidim/decidim/issues/2670)
- **decidim-meetings**: Notify participatory space followers when a meeting is created. [\#2646](https://github.com/decidim/decidim/pull/2646)
- **decidim-participatory_processes**: Processes now have a reference [\#2557](https://github.com/decidim/decidim/pull/2557)
- **decidim-proposals**: Endorsement to proposals: apply new design. [\#2728](https://github.com/decidim/decidim/pull/2733)
- **decidim-proposals**: Notify participatory space followers when a proposal is created. [\#2646](https://github.com/decidim/decidim/pull/2646)
- **decidim-proposals**: Copy proposals to another component [\#2619](https://github.com/decidim/decidim/issues/2619).
- **decidim-proposals**: Users and user_groups can now endorse proposals. [\#2287](https://github.com/decidim/decidim/pull/2287)
- **decidim-proposals**: Add configurable proposal body length. [\#2639](https://github.com/decidim/decidim/pull/2639)
- **decidim-participatory_processes**: Ensure only active processes are shown in the highlighted processes section in the homepage[\#2682](https://github.com/decidim/decidim/pull/2682)
- **decidim-core**: Add collections to group attachments [\#2394](https://github.com/decidim/decidim/pull/2394).
- **decidim-admin**: Adds a log of all admin actions, only visible by organization admins [\#2604](https://github.com/decidim/decidim/pull/2604)
- **decidim-core**: Add some examples on documentation to AuthorizationHandler [\#2758](https://github.com/decidim/decidim/pull/2758).
- **decidim-accountability**: Show random results in process and process group home [\#2824](https://github.com/decidim/decidim/issues/2824)
- **decidim-meetings**: Show past/upcoming meetings in process and process group home [\#2713](https://github.com/decidim/decidim/issues/2713)
- **decidim-proposals**: Show random proposals in process and process group home [\#2817](https://github.com/decidim/decidim/issues/2817)
- **decidim-participatory_processes**: Render `decidim:participatory_space_highlighted_elements` and `participatory_processes:process_group_highlighted_elements` view hooks in process and process group home respectively [\#2713](https://github.com/decidim/decidim/issues/2713)
- **decidim-core**: Make static pages traceable [\#2754](https://github.com/decidim/decidim/pull/2754)
- **decidim-admin**: Log all actions on static pages [\#2754](https://github.com/decidim/decidim/pull/2754)
- **decidim-admin**: Log all actions on newsletters [\#2763](https://github.com/decidim/decidim/pull/2763)
- **decidim-admin**: Log user groups verifications and rejections [\#2778](https://github.com/decidim/decidim/pull/2778)
- **decidim-admin**: Log admin users invites and deletions [\#2776](https://github.com/decidim/decidim/pull/2776)
- **decidim-admin**: Log all changes on organization settings [\#2771](https://github.com/decidim/decidim/pull/2771)
- **decidim-admin**: Log user (un)officializations [\#2782](https://github.com/decidim/decidim/pull/2782)
- **decidim-participatory_processes**: Log process creation and (un)publications [\#2786](https://github.com/decidim/decidim/pull/2786)
- **decidim-admin**: Log feature creation and deletion [\#2792](https://github.com/decidim/decidim/pull/2792)
- **decidim-core**: Document async jobs configuration for end applications [\#2640](https://github.com/decidim/decidim/issues/2640)
- **decidim-admin**: Multiple proposals can be recategorized from the proposal index  [\#2585](https://github.com/decidim/decidim/pull/2585#issuecomment-366902187)
- **decidim-participatory_processes**: Log process users invites (Creation, update and deletion) [\#2793](https://github.com/decidim/decidim/pull/2793)
- **decidim-admin**: Log actions on moderations [\#2803](https://github.com/decidim/decidim/pull/2803)
- **decidim-core**: Enable a "permission_update" hook to be run upon feature permissions update [\#2809](https://github.com/decidim/decidim/pull/2809)
- **decidim-participatory_processes**: Adds a basic API including steps and components. [\#2787](https://github.com/decidim/decidim/pull/2787)
- **decidim-core**: Adds a statistics API to `Organization` and `ParticipatorySpace`. [\#2843](https://github.com/decidim/decidim/pull/2843)
- **decidim-proposals**: Log proposal answers [\#2848](https://github.com/decidim/decidim/pull/2848)
- **decidim-accountability**: Adds flag to control if the visualization of progress is visible [\#2847](https://github.com/decidim/decidim/pull/2847)
- **decidim-proposals**: Adds a basic API that lists proposals. [\#2788](https://github.com/decidim/decidim/pull/2788)
- **decidim-participatory_processes**: Log process updates[\#2860](https://github.com/decidim/decidim/pull/2860)
- **decidim-admin**: Log actions on scopes [\#2854](https://github.com/decidim/decidim/pull/2854)
- **decidim-core**: `scopes_picker_field` can now receive options such as `label: false` [\#2867](https://github.com/decidim/decidim/pull/2847)
- **decidim-core**: `theDataPicker.activate("#my_data_picker_element")` can now be used to bind dinamically created inputs to a data picker [\#2867](https://github.com/decidim/decidim/pull/2847)
- **decidim-assemblies**: Log assembly creation, update and (un)publication [\#2858](https://github.com/decidim/decidim/pull/2858)
- **decidim-assemblies**: Log assembly user role creation, update and deletion [\#2874](https://github.com/decidim/decidim/pull/2874)
- **decidim-participatory_processes**: Log actions on process steps [\#2876](https://github.com/decidim/decidim/pull/2876)
- **decidim-admin**: Log feature (un)publication[\#2884](https://github.com/decidim/decidim/pull/2884)
- **decidim-pages**: Log page updates [\#2886](https://github.com/decidim/decidim/pull/2886)
- **decidim-debates**: Log debates creation and updates [\#2903](https://github.com/decidim/decidim/pull/2903)
- **decidim-core**: Add missing `scopes_picker_tag` and `scopes_picker_field_tag` form helpers [\#2880](https://github.com/decidim/decidim/pull/2880)
- **decidim-proposals**: Log official proposals creation [\#2905](https://github.com/decidim/decidim/pull/2905)
- **decidim-proposals**: Log proposal private notes [\#2907](https://github.com/decidim/decidim/pull/2907)
- **decidim-meetings**: Log actions on meetings [\#2911](https://github.com/decidim/decidim/pull/2911)
- **decidim-debates**: Adds announcements to debates [\#2806](https://github.com/decidim/decidim/pull/2806)
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

- **decidim-proposals**: Fix treshold absolute view and rename the field maximum_votes_per_proposal to treshold_per_proposal. [\#2994](https://github.com/decidim/decidim/pull/2994)
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
