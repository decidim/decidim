# Change Log

## Unreleased

**Added**:

**Changed**:

**Fixed**:

## [0.10-pre](https://github.com/decidim/decidim/tree/0.10-stable)

**Note**: As per [\#2983](https://github.com/decidim/decidim/pull/2983), if you've been using `0.10.pre` version of Decidim for a while you'll need to fix some values in the database. In order to fix them,  run this script in your Rails console:

```ruby
Decidim::Notification.where(event_class: "Decidim::Proposals::ProposalEndorsedEvent").find_each{|ev| ev.extra = { endorser_id: ev.extra.dig("endorser", "id") }; ev.save! }
- **decidim-core**: Fixes missing translations for step activated event [\#2928](https://github.com/decidim/decidim/pull/2928)
- **decidim-admin**: Fix officializations showing all users in the system instead of only the organization ones [\#2912](https://github.com/decidim/decidim/pull/2912)

## [v0.9.3](https://github.com/decidim/decidim/tree/v0.9.3) (2018-2-27)

**Added**:

**decidim-core**: Add context to content parsers [\#2751](https://github.com/decidim/decidim/pull/2751)

**Changed**:

**Fixed**:
* **decidim-proposals**: Fix wrong message when creating a proposal private note [\#2796](https://github.com/decidim/decidim/pull/2796)
* **decidim-core**: Fix AuthorEvent when author is missing [\#2777](https://github.com/decidim/decidim/pull/2777)
* **decidim-core**: Fix DefaultActionAuthorizer when options is nil [\#2753](https://github.com/decidim/decidim/pull/2753)
* **decidim-core**: Fix mention parsing to only search users in current organization. [\2711](https://github.com/decidim/decidim/pull/2711)
* **decidim-system**: Disable recover password for System admins. [\#2752](https://github.com/decidim/decidim/pull/2752)
* **decidim-core**: Don't render notifications if the resource has been deleted. [\#2746](https://github.com/decidim/decidim/pull/2746)
* **decidim-core**: Don't try to send notification emails to deleted users. [\#2743](https://github.com/decidim/decidim/pull/2743)
* **decidim-core**: Fix categories select when missing translations. [\#2742](https://github.com/decidim/decidim/pull/2742)
* **decidim-core**: Fix mention parsing to only search users in current organization. [\2711](https://github.com/decidim/decidim/pull/2711)
- **decidim-core**: Fix user invitations by generating their nickname. [\#2783](https://github.com/decidim/decidim/pull/2789)

## [v0.9.2](https://github.com/decidim/decidim/tree/v0.9.2) (2018-2-9)

**Fixed**:

* **decidim-core**: Fix notifications list when the resource is a User. [\#2692](https://github.com/decidim/decidim/pull/2692)
* **decidim-core**: Fix mention rendering when there's more than one mention. [\#2691](https://github.com/decidim/decidim/pull/2691)

## [v0.9.1](https://github.com/decidim/decidim/tree/v0.9.1) (2018-2-8)

**Added**:

**Changed**:

**Fixed**:

* **decidim-participatory_processes**: Fix find a process by its ID.[\#2672](https://github.com/decidim/decidim/pull/2672)
* **decidim-assemblies**: Fix find an assembly by its ID.[\#2672](https://github.com/decidim/decidim/pull/2672)
* **decidim-core**: Fix notification mailer when a resource doesn't have an organization. [\#2661](https://github.com/decidim/decidim/pull/2661)
* **decidim-comments**: Fix comment notifications listing. [\#2652](https://github.com/decidim/decidim/pull/2652)
* **decidim-participatory_processes**: Fix editing a process after an error.[\#2653](https://github.com/decidim/decidim/pull/2653)
* **decidim-assemblies**: Fix editing a process after an error.[\#2653](https://github.com/decidim/decidim/pull/2653)
* **decidim-participatory_processes**: Ensure only active processes are shown in the highlighted processes section in the homepage[\#2682](https://github.com/decidim/decidim/pull/2682)

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

**Changed**:

- **decidim-core**: Send a deep copy of view context to view hooks [\#2817](https://github.com/decidim/decidim/issues/2817)
- **decidim-core**: General improvements on documentation [\#2656](https://github.com/decidim/decidim/pull/2656).
- **decidim-core**: `FeatureReferenceHelper#feature_reference` has been moved to `ResourceReferenceHelper#resource_reference` to clarify its use. [\#2557](https://github.com/decidim/decidim/pull/2557)
- **decidim-core**: `Decidim.resource_reference_generator` has been moved to `Decidim.reference_generator` to clarify its use. [\#2557](https://github.com/decidim/decidim/pull/2557)
- **decidim-system**: Default pages content are now wrapped in `<p>` HTML tags [\#2754](https://github.com/decidim/decidim/pull/2754)
- **decidim-core**: The module to be included by components in order to add scopes to the component is now called `ScopableFeature` (instead of `HasScope`) [\#2895](https://github.com/decidim/decidim/pull/2895)
- **decidim-core**: The `scopes_enabled?` helper method has been removed. Call `#scopes_enabled?` directly on the scopable resource instead [\#2895](https://github.com/decidim/decidim/pull/2895)
- **decidim-core**: The `scopes` association has been removed from the `Feature` model. If you need to grab all organization scopes, use the equivalent method on the current organization or the current participatory space [\#2895](https://github.com/decidim/decidim/pull/2895)

**Fixed**:

**decidim-debates**: Fix debates times. [\#3078](https://github.com/decidim/decidim/pull/3078)
- **decidim-proposals**: Fix treshold absolute view and rename the field maximum_votes_per_proposal to threshold_per_proposal. [\#3017](https://github.com/decidim/decidim/pull/3017)
- **decidim-core**: FIX Mispelling in available_locales initializer: pr-BR should be pt-BR. [\#2883](https://github.com/decidim/decidim/pull/2883)
- **decidim-admin**: FIX Area and AreaType command specs [\#2859](https://github.com/decidim/decidim/pull/2859)
- **decidim-proposals**: Fix wrong message when creating a proposal private note [\#2769](https://github.com/decidim/decidim/pull/2769)
- **decidim-core**: Fix AuthorEvent when author is missing [\#2777](https://github.com/decidim/decidim/pull/2777)
- **decidim-system**: Disable recover password for System admins. [\#2752](https://github.com/decidim/decidim/pull/2752)
- **decidim-core**: Fix DefaultActionAuthorizer when options is nil [\#2753](https://github.com/decidim/decidim/pull/2753)
- **decidim-core**: Don't render notifications if the resource has been deleted. [\#2746](https://github.com/decidim/decidim/pull/2746)
- **decidim-core**: Fix categories select when missing translations. [\#2742](https://github.com/decidim/decidim/pull/2742)
- **decidim-core**: Don't try to send notification emails to deleted users. [\#2743](https://github.com/decidim/decidim/pull/2743)
- **decidim-core**: Fix notifications list when the resource is a User. [\#2687](https://github.com/decidim/decidim/pull/2687)
- **decidim-core**: Fix mention rendering when there's more than one mention. [\2690](https://github.com/decidim/decidim/pull/2690)
- **decidim-core**: Fix mention parsing to only search users in current organization. [\2710](https://github.com/decidim/decidim/pull/2710)
- **decidim-participatory_processes**: Fix find a process by its ID.[\#2672](https://github.com/decidim/decidim/pull/2672)
- **decidim-assemblies**: Fix find an assembly by its ID.[\#2672](https://github.com/decidim/decidim/pull/2672)
- **decidim-core**: Fix notification mailer when a resource doesn't have an organization. [\#2661](https://github.com/decidim/decidim/pull/2661)
- **decidim-comments**: Fix comment notifications listing. [\#2652](https://github.com/decidim/decidim/pull/2652)
- **decidim-participatory_processes**: Fix editing a process after an error.[\#2653](https://github.com/decidim/decidim/pull/2653)
- **decidim-assemblies**: Fix editing a process after an error.[\#2653](https://github.com/decidim/decidim/pull/2653)
- **decidim-core**: Fix missing i18n strings for "Feature published" events. [\#2729](https://github.com/decidim/decidim/pull/2729)
- **decidim-core**: Fix user invitations by generating their nickname. [\#2783](https://github.com/decidim/decidim/pull/2783)
- **decidim-core**: Fix authorization modals not reopening [\#2811](https://github.com/decidim/decidim/pull/2811)
- **decidim-core**: Fix ugly white stripe under flash message on pages with a picture as main background (such as the homepage) [\#2818](https://github.com/decidim/decidim/pull/2818)
- **decidim-admin**: Fix a bug that lost the scope hierarchy when updating, making the updated scope top-level [\#2853](https://github.com/decidim/decidim/pull/2853)
- **decidim-proposals**: Fix proposals scope not displayed on process group highlighted proposals cards in some cases. [\#2894](https://github.com/decidim/decidim/pull/2894)
- **decidim-admin**: Fix officializations showing all users in the system instead of only the orgsanization ones [\#2912](https://github.com/decidim/decidim/pull/2912)
- **decidim-accountability**: Fix parent results progress [\#2954](https://github.com/decidim/decidim/pull/2954)
- **decidim-core**: Fix `Decidim::UserPresenter#nickname` [\#2958](https://github.com/decidim/decidim/pull/2958)
- **decidim-verifications**: Only show authorizations from current organization [\#2959](https://github.com/decidim/decidim/pull/2959)
- **decidim-proposals**: Fix proposal endorsed event [\#2970](https://github.com/decidim/decidim/pull/2970)
- **decidim-comments**: Fix mentions not working properly. [\#2972](https://github.com/decidim/decidim/pull/2972)
- **decidim-proposals**: Fix proposal endorsed event  generation [\#2983](https://github.com/decidim/decidim/pull/2983)
- **decidim-core**: foundation-rails 6.4.3 support [\#2995](https://github.com/decidim/decidim/pull/2995)

Please check [0.9-stable](https://github.com/decidim/decidim/blob/0.9-stable/CHANGELOG.md) for previous changes.
