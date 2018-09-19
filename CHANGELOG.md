# Change Log


## 0.12.2 - OSP specific changes:

**Upgrade notes**:

- **Banner uploader**: banner uploader has been changed in [\#150](https://github.com/OpenSourcePolitics/decidim/pull/150)
you should update existing image if you don't want to reupload them.
use the following command in your rails console : `Decidim::ParticipatoryProcess.find_each { |process| process.banner_image.recreate_versions! if process.banner_image? }`
- **Avater uploader**: Avater uploader has been changed in [\#147](https://github.com/OpenSourcePolitics/decidim/pull/147)
you should update existing image if you don't want to reupload them.
use the following command in your rails console : `Decidim::User.find_each { |user| user.avatar.recreate_versions! if user.avatar? }`

**Added**:

- **decidim-debates**: Allow debates to be reported [#199](https://github.com/OpenSourcePolitics/decidim/pull/199)
- **decidim-core**: Banner uploader has been changed in [\#150](https://github.com/OpenSourcePolitics/decidim/pull/150)
- **decidim-core**: Avater uploader has been changed in [\#147](https://github.com/OpenSourcePolitics/decidim/pull/147)
- **decidim-core**: Now have a quality setting which can be used by adding `process quality:%%` where %% is  your desired percentage of quality
- **decidim-core** : Add an initializer otion to skip first login authorization [\#176](https://github.com/OpenSourcePolitics/decidim/pull/176)
- **decidim-admin**: Add link to user profile and link to conversation from admin space. [\#208](https://github.com/OpenSourcePolitics/decidim/pull/208)


**Changed**:

- **decidim-proposals**: Remove caps first validator. Format title and body without any intervention from the user [\#259](https://github.com/OpenSourcePolitics/decidim/pull/259)
 - **decidim-participatory_processes**: Make process moderators receive notifications about flagged content [\#228](https://github.com/OpenSourcePolitics/decidim/pull/228)

**Fixed**:

- **decidim-accountability**: Fix accountability progress to be between 0 and 100 if provided. [\#3952](https://github.com/decidim/decidim/pull/3952)
- **decidim-participatory_processes**: Fix hastag display on participatory processes. [\#200](https://github.com/OpenSourcePolitics/decidim/pull/200)
- **decidim-core**: Fix test consistency [#222](https://github.com/OpenSourcePolitics/decidim/pull/222)
- **decidim-core**: Add shinier signature. [#186](https://github.com/OpenSourcePolitics/decidim/pull/186)

**Backported**:

- **decidim-surveys**: Allow deleting surveys components when there are no answers [#211](https://github.com/OpenSourcePolitics/decidim/pull/211)
- **decidim-proposals**: Hide withdrawn proposals from index [\#4012](https://github.com/decidim/decidim/pull/4012)
- **decidim-proposals**: Hide withdrawn proposals from index [\#4012](https://github.com/decidim/decidim/pull/4012)
- **decidim-core**: Allows users with admin access to preview unpublished components [\#209](https://github.com/OpenSourcePolitics/decidim/pull/209)

## [Unreleased](https://github.com/decidim/decidim/tree/0.11-stable)

**Upgrade notes**:

This version has breaking changes, `Decidim::Feature` has been renamed to `Decidim::Component`,
and also everything related to it (controllers, views, etc.). If you have customised some
controller or added a new module you need to rename `feature` to `component`.
## [Unreleased](https://github.com/decidim/decidim/tree/0.12-stable)

**Fixed**:

## [0.12.1-pre](https://github.com/decidim/decidim/tree/v0.12.1)

**Fixed**:

## [0.11.0.pre](https://github.com/decidim/decidim/tree/v0.11.0)
## [0.12.0-pre](https://github.com/decidim/decidim/tree/v0.12.0-pre)
## [Unreleased](https://github.com/decidim/decidim/tree/0.12-stable)

**Fixed**:

## [0.12.2](https://github.com/decidim/decidim/tree/v0.12.2)

**Fixed**:

- **decidim-assemblies**: Let space admins access other spaces [\#3772](https://github.com/decidim/decidim/pull/3772)
- **decidim-participatory_processes**: Let space admins access other spaces [\#3772](https://github.com/decidim/decidim/pull/3772)

## [0.12.1](https://github.com/decidim/decidim/tree/v0.12.1)

**Fixed**:

- **decidim-core**: Add readonly attribute to date_fields so that the user is forced to use the datepicker. [#3705](https://github.com/decidim/decidim/pull/3705)
- **decidim-assemblies**: Let space users access the admin area from the public one [\#3683](https://github.com/decidim/decidim/pull/3683)
- **decidim-participatory_processes**: Let space users access the admin area from the public one [\#3683](https://github.com/decidim/decidim/pull/3683)
- **decidim-assemblies**: Let assembly admins access all content [\#3706](https://github.com/decidim/decidim/pull/3706)
- **decidim-admin**: Let user managers access the public space [\#3723](https://github.com/decidim/decidim/pull/3723)

## [0.12.0](https://github.com/decidim/decidim/tree/v0.12.0)

**Upgrade notes (authorizations)**:

Authorizations workflows now use a settings manifest to define their options.
That means site admins will no longer need to introduce raw json to define
authorization options. If you were previously using an authorization workflow
with options, you'll need to update the workflow manifest to define them. As an
example, if you were filtering an authorization only to users in the 08001
postal code via an authorization option (by introducing `{ "postal_code" :
"08001" }` in the options field of a participatory space action permissions),
you'll need to define it in the workflow manifest as:

```ruby
Decidim::Verifications.register_workflow(:my_handler) do |workflow|
  # ... stuff ...

  workflow.options do |options|
    options.attribute :postal_code, type: :string, required: false
  end
end
```

If you have some custom modules from which you are registering a resource, you
will need to tweak how those resources are being registered as per #3416. You
must now set a resource name:

```ruby
  # inside decidim-my-module/lib/decidim/my-module/component.rb
  component.register_resource(:my_resource) do |resource|
    resource.model_class_name = "Decidim::MyComponent::MyResource"
  end
```

**Upgrade notes (search)**:

In order for the currently existing resources to be indexed, you'll have to
manually trigger a reindex. Since only `proposals` and `meetings` are currently
indexed, you can do that executing:

```ruby
Decidim::Meetings::Meeting.find_each(&:add_to_index_as_search_resource)
Decidim::Proposals::Proposal.find_each(&:add_to_index_as_search_resource)
```

**Upgrade notes (TOS)**:

Due to a bug that got fixed on this release, some organizations might not
have a TOS page, which some migrations rely on. Please execute this code on
production before upgrading so the pages get created correctly and the migrations
don't fail.

```ruby
Decidim::Organization.find_each { |organization| Decidim::System::CreateDefaultPages.call(organization) }
```

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
- **decidim-budgets**: Setting to control the number of projects per page to be listed [\#3239](https://github.com/decidim/decidim/pull/3239)
- **decidim-admin**: Regular users can now be impersonated [\#3226](https://github.com/decidim/decidim/pull/3226)
- **decidim-admin**: All available authorization handlers can always be chosen for impersonation even after the first impersonation [\#3226](https://github.com/decidim/decidim/pull/3226)
- **decidim-generators**: New gem where all of decidim generators live, both to generate final application and decidim components (plugins).
- **decidim-meetings**: Add WYSIWYG editor for meeting closing notes [\#3265](https://github.com/decidim/decidim/pull/3265)
- **decidim-meetings**: Add formatting of the list of organizations attending to a meeting [\#3265](https://github.com/decidim/decidim/pull/3265)
- **decidim-core**: Order components by both weight and manifest_name so the order is kept [\#3264](https://github.com/decidim/decidim/pull/3264)
- **decidim-meetings**: Add a meetings API. [\#3255](https://github.com/decidim/decidim/pull/3255)
- **decidim-proposals**: Add "complete" step to the proposal creation wizard [\#3274](https://github.com/decidim/decidim/pull/3274)
**decidim-core**: Add readonly attribute to date_fields so that the user is forced to use the datepicker. [#3705](https://github.com/decidim/decidim/pull/3705)
- **decidim-core**: Added a global search engine for Proposals and Meetings. [\#3559](https://github.com/decidim/decidim/pull/3559)
- **decidim-meetings**: Add Agenda and Agenda Item entities to manage meeting agenda. [\#3305](https://github.com/decidim/decidim/pull/3305)
- **decidim-docs**: Add documentation for developers getting started. [\#3297](https://github.com/decidim/decidim/pull/3297)
- **decidim-assemblies**: Add members to assemblies. [\#3008](https://github.com/decidim/decidim/pull/3008)
- **decidim-assemblies**: An assembly member can be related to an existing user. [\#3302](https://github.com/decidim/decidim/pull/3302)
- **decidim-assemblies**: Show the assemblies that a user belongs in their profile. [\#3410](https://github.com/decidim/decidim/pull/3410)
- **decidim-core**: Added the user_profile_bottom view hook to the public profiel page. [\#3410](https://github.com/decidim/decidim/pull/3410)
- **decidim-meetings**: Add organizer to meeting and meeting types [\#3136](https://github.com/decidim/decidim/pull/3136)
- **decidim-meetings**: Add Minutes entity to manage Minutes. [\#3213](https://github.com/decidim/decidim/pull/3213)
- **decidim-initiatives**: Notify initiatives milestones [\#3341](https://github.com/decidim/decidim/pull/3341)
- **decidim-admin**: Links to participatory space index & show pages from the admin dashboard. [\#3325](https://github.com/decidim/decidim/pull/3325)
- **decidim-admin**: Add autocomplete field with customizable url to fetch results. [\#3301](https://github.com/decidim/decidim/pull/3301)
- **decidim-admin**: Add endpoint to query organization users in json format. [\#3381](https://github.com/decidim/decidim/pull/3381)
- **decidim-core**: Adds fingerprinting capabilities to resources. [\#3351](https://github.com/decidim/decidim/pull/3351)
- **decidim-core**: Add user profile card [\#3444](https://github.com/decidim/decidim/pull/3444)
- **decidim-budgets**: Add project card [\#3454](https://github.com/decidim/decidim/pull/3454)
- **decidim-core**: GDPR: Unbundled consent on user registration [\#3483](https://github.com/decidim/decidim/pull/3483)
- **decidim-core**: GDPR: Right to be Forgotten  [\#3315](https://github.com/decidim/decidim/issues/3315)
- **decidim-core**: GDPR: Newsletter checkbox unchecked by default [\3316](https://github.com/decidim/decidim/issues/3316)
- **decidim-consultations**: Add consultation card [\#3487](https://github.com/decidim/decidim/pull/3487)
- **decidim-blogs**: Add blog post card [\#3487](https://github.com/decidim/decidim/pull/3487)
- **decidim-core**: GDPR: Track TOS page version in Organization [\#3491](https://github.com/decidim/decidim/pull/3491)
- **decidim-core**: GDPR: User must review TOS when updated [\#3494](https://github.com/decidim/decidim/pull/3494)
- **decidim-core**: Requests are throttled to prevent DoS attacks [\#3588](https://github.com/decidim/decidim/pull/3588)

**Changed**:

- **decidim-core**: New user profile design [\#3415](https://github.com/decidim/decidim/pull/3290)
- **decidim-core**: Force user_group.name uniqueness in user_group test factory. [\#3290](https://github.com/decidim/decidim/pull/3290)
- **decidim-admin**: Admins no longer need to introduce raw json to define options for an authorization workflow. [\#3300](https://github.com/decidim/decidim/pull/3300)
- **decidim-proposals**: Extract partials in Proposals into helper methors so that they can be reused in collaborative draft. [\#3238](https://github.com/decidim/decidim/pull/3238)

**Changed**:

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
- **decidim-proposals**: Drop support for abilities in favor of the new Permissions system [\#3029](https://github.com/decidim/decidim/pull/3029)
- **decidim-accountability**: Drop support for abilities in favor of the new Permissions system [\#3029](https://github.com/decidim/decidim/pull/3029)
- **decidim-budgets**: Drop support for abilities in favor of the new Permissions system [\#3029](https://github.com/decidim/decidim/pull/3029)
- **decidim-pages**: Drop support for abilities in favor of the new Permissions system [\#3029](https://github.com/decidim/decidim/pull/3029)
- **decidim-debates**: Drop support for abilities in favor of the new Permissions system [\#3029](https://github.com/decidim/decidim/pull/3029)
- **decidim-comments**: Drop support for abilities in favor of the new Permissions system [\#3029](https://github.com/decidim/decidim/pull/3029)
- **decidim-surveys**: Drop support for abilities in favor of the new Permissions system [\#3029](https://github.com/decidim/decidim/pull/3029)
- **decidim-meetings**: Drop support for abilities in favor of the new Permissions system [\#3029](https://github.com/decidim/decidim/pull/3029)
- **decidim-sortitions**: Drop support for abilities in favor of the new Permissions system [\#3029](https://github.com/decidim/decidim/pull/3029)
- **decidim-meetings**: Update card layout [\#3338](https://github.com/decidim/decidim/pull/3338)
- **decidim-proposals**: Update card layout [\#3338](https://github.com/decidim/decidim/pull/3338)
- **decidim-debates**: Update card layout [\#3371](https://github.com/decidim/decidim/pull/3371)
- **decidim-participatory_processes**: Update card layout for processes [\#3382](https://github.com/decidim/decidim/pull/3382)
- **decidim-participatory_processes**: Update card layout for process groups [\#3395](https://github.com/decidim/decidim/pull/3395)
- **decidim-assemblies**: Update card layout for assemblies and assembly members [\#3405](https://github.com/decidim/decidim/pull/3405)
- **decidim-sortitions**: Update card layout [\#3405](https://github.com/decidim/decidim/pull/3405)
- **decidim**: Changes on how to register resources. Resources from a component now they need a specific reference to the component manifest, and all resources need a name. [\#3416](https://github.com/decidim/decidim/pull/3416)
- **decidim-consultations**: Improve overall navigation [\#3524](https://github.com/decidim/decidim/pull/3524)
- **decidim-comments**: Let comments have paragraphs to increase readability [\#3538](https://github.com/decidim/decidim/pull/3538)
- **decidim-core**: Sessions expire in one week by default. [\#3586](https://github.com/decidim/decidim/pull/3586)

**Fixed**:

- **decidim-accountability**: Fixes linking proposals to results for accountability on creation time. [\#3167](https://github.com/decidim/decidim/pull/3262)
- **decidim-proposals**: Fixes clicking on "see all" should remove the ellipsis sign. [\#2894](https://github.com/decidim/decidim/pull/3238)
- **decidim-proposals**: Ignore already imported proposals when importing them [\#3257](https://github.com/decidim/decidim/pull/3257)
- **decidim-proposals**: Fixes clicking on "see all" should remove the ellipsis sign. [\#3238](https://github.com/decidim/decidim/pull/3238)
- **decidim-core**: Add missing locales in Freanch fot the datepicker [\#3260](https://github.com/decidim/decidim/pull/3260)
- **decidim-proposals**: Fixes clicking on "see all" should remove the ellipsis sign. \#2894](https://github.com/decidim/decidim/pull/3238)
- **decidim-proposals**: Restore creation date in proposal detail page. [\#3249](https://github.com/decidim/decidim/pull/3249)
- **decidim-proposals**: Fix threshold_per_proposal method positive? for nil:NilClass when threshold is null or not defined. [\#3185](https://github.com/decidim/decidim/pull/3185)
- **decidim-proposals**: Make sure threshold per proposal has the right value in existing components [\#3235](https://github.com/decidim/decidim/pull/3235)

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
- **decidim-admin**: Dropdown menus appearance on hover [\#3241](https://github.com/decidim/decidim/pull/3241)
- **decidim-admin**: Ability to select leaf categories from Admin change-category bulk action [\#3243](https://github.com/decidim/decidim/pull/3243)
- **decidim-admin**: Highlighted banner image is not required if already present in the organization [\#3244](https://github.com/decidim/decidim/pull/3244)
- **decidim-proposals**: Keep the user group (if set) as default value of author field on forms [\#3247](https://github.com/decidim/decidim/pull/3247)
- **decidim-meetings**: Enforce permissions when managing meeting minutes. [\#3560](https://github.com/decidim/decidim/pull/3560)
- **decidim-assembly**: Fix Non private users can participate to a private, transparent assembly [\#3438](https://github.com/decidim/decidim/pull/3438)
- **decidim-proposals**: Fixes artificial margin between proposal "header" and list of endorsements. [\#2893](https://github.com/decidim/decidim/pull/2893)
- **decidim-proposals**: Use translations for hardcoded text. [\#3464](https://github.com/decidim/decidim/pull/3464)
- **decidim-core**: Don't send notifications to users without access to the space. [\#3542](https://github.com/decidim/decidim/pull/3542)
- **decidim-core**: Include datepicker locales in front pages too. [\#3448](https://github.com/decidim/decidim/pull/3448)
- **decidim-core**: Uses current organization scopes in scopes picker. [\#3386](https://github.com/decidim/decidim/pull/3386)
- **decidim-blog**: Add `params[:id]` when editing/deleting a post from admin site [\#3329](https://github.com/decidim/decidim/pull/3329)
- **decidim-admin**: Fixes the validation uniqueness name of area, scoped with organization and area_type [\#3336](https://github.com/decidim/decidim/pull/3336) https://github.com/decidim/decidim/pull/3336
- **decidim-core**: Fix `Resourceable` concern to only find linked resources from published components. [\#3433](https://github.com/decidim/decidim/pull/3433)
- **decidim-accountability**: Fixes linking proposals to results for accountability on creation time. [\#3167](https://github.com/decidim/decidim/pull/3262)
- **decidim-proposals**: Fixes clicking on "see all" should remove the ellipsis sign. [\#2894](https://github.com/decidim/decidim/pull/3238)
- **decidim-participatory_processes**: Remove duplicated space title on page meta tags [\#3278](https://github.com/decidim/decidim/pull/3278)
- **decidim-assemblies**: Remove duplicated space title on page meta tags [\#3278](https://github.com/decidim/decidim/pull/3278)
- **decidim-core**: Add validation to nickname's length. [\#3342](https://github.com/decidim/decidim/pull/3342)
- **decidim-core**: Deactivate notifications bell when marking all as read [\#3509](https://github.com/decidim/decidim/pull/3509)
- **decidim-surveys**: Fix a N+1 in surveys [\#3497](https://github.com/decidim/decidim/pull/3497)
- **decidim-initiatives**: Fix user signing of initiatives [\#3513](https://github.com/decidim/decidim/pull/3513)
- **decidim-core**: Make admin link on user menu stop disappearing [\#3508](https://github.com/decidim/decidim/pull/3508)
- **decidim-core**: Sort static pages by title [\#3479](https://github.com/decidim/decidim/pull/3479)
- **decidim-core**: Data picker form inputs having no bottom margin. [\#3463](https://github.com/decidim/decidim/pull/3463)
- **decidim-core**: Make signup forms show the password confirmation field as required[\#3521](https://github.com/decidim/decidim/pull/3521)
- **decidim-core**: Fix default page creation so they get scoped to the actual organization [\#3526](https://github.com/decidim/decidim/pull/3526)
- **decidim-consultations**: Do not allow votes on upcoming consultations [\#3529](https://github.com/decidim/decidim/pull/3529)
- **decidim-surveys**: Fix answer exporter for single/multi-choice questions [\#3535](https://github.com/decidim/decidim/pull/3535)
- **decidim-core**: Do not allow users to follow themselves [\#3536](https://github.com/decidim/decidim/pull/3536)
- **decidim-system**: Fix new organization admin not being invited properly [\#3543](https://github.com/decidim/decidim/pull/3543)
- **decidim-consultations**: Use app CSS variables [\#3541](https://github.com/decidim/decidim/pull/3541)
- **decidim-proposals**: Hide supports on linked proposals if theya re supposed to be hidden [\#3544](https://github.com/decidim/decidim/pull/3544)
- **decidim-core**: Fix confirmation emails resending for multitenant systems [\#3546](https://github.com/decidim/decidim/pull/3546)
- **decidim-proposals**: Warn the user the attachment is lost when the form is errored [\#3553](https://github.com/decidim/decidim/pull/3553)
- **decidim-core**: Consistent casing of error messages [\#3565](https://github.com/decidim/decidim/pull/3565)
- **decidim-comments**: Fix comments stats so it appears in the homepage again [\#3570](https://github.com/decidim/decidim/pull/3570)
- **decidim-comments**: Fix comment creation events raising errors when being delivered [\#3580](https://github.com/decidim/decidim/pull/3580)
- **decidim-participatory_processes**: Make process moderators receive notifications about flagged content [\#3605](https://github.com/decidim/decidim/pull/3605)
- **decidim-meetings**: Do not let users join a meeting from the Search page, as the button fails [\#3612](https://github.com/decidim/decidim/pull/3612)

**Fixed**:

- **decidim-assemblies**: Fix private assemblies showing more than once for private users. [\#3638](https://github.com/decidim/decidim/pull/3638)
- **decidim-proposals**: Do not index non published Proposals. [\#3618](https://github.com/decidim/decidim/pull/3618)
- **decidim-proposals**: Fix link to endorsements behaviour, now it does not link when there are no endorsements. [\#3531](https://github.com/decidim/decidim/pull/3531)
- **decidim-meetings**: Fix meetings M card cell so that it works outside the component [\#3612](https://github.com/decidim/decidim/pull/3612)
- **decidim-proposals**: Fix proposals M card cell so that it works outside the component [\#3612](https://github.com/decidim/decidim/pull/3612)
- **decidim-core**: Adds a missing migration to properly rename features to components [\#3658](https://github.com/decidim/decidim/pull/3658)
- **decidim-core**: Search results should be paginated so that server does not hang when search term is too wide. [\#3658](https://github.com/decidim/decidim/pull/3658)
- **decidim-blogs**: Use custom sanitizer in views instead of the default one [\#3659](https://github.com/decidim/decidim/pull/3659)
- **decidim-core**: Use custom sanitizer in views instead of the default one [\#3659](https://github.com/decidim/decidim/pull/3659)
- **decidim-initiatives**: Use custom sanitizer in views instead of the default one [\#3659](https://github.com/decidim/decidim/pull/3659)
- **decidim-sortitions**: Use custom sanitizer in views instead of the default one [\#3659](https://github.com/decidim/decidim/pull/3659)
- **decidim-assemblies**: Let space users access the admin area from the public one [\#3666](https://github.com/decidim/decidim/pull/3683)
- **decidim-assemblies**: Let space admins access other spaces [\#3772](https://github.com/decidim/decidim/pull/3772)
- **decidim-participatory_processes**: Let space admins access other spaces [\#3772](https://github.com/decidim/decidim/pull/3772)

**Removed**:

Please check [0.11-stable](https://github.com/decidim/decidim/blob/0.11-stable/CHANGELOG.md) for previous changes.
