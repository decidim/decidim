# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/0.13-stable)

**Fixed**:

## [0.13.1](https://github.com/decidim/decidim/tree/v0.13.1)

**Fixed**:

- **decidim-surveys**: Order survey answer options by date and time. [#3869](https://github.com/decidim/decidim/pull/3869)

- **decidim-core**: Fix newsletterable not being able to use `Time.zone.parse` when eager-loding the dependencies [#3830](https://github.com/decidim/decidim/pull/3847)

## [0.13.0](https://github.com/decidim/decidim/tree/v0.13.0)

**Upgrade notes: avatars**:

As per [\#3716](https://github.com/decidim/decidim/pull/3716), you'll need to
re-create the existing avatars versions. Connect to your server and run this on
your terminal:

```console
bin/rails c
```

And then copy and paste this piece of code:

```ruby
Decidim::User.find_each do |user|
  user.avatar.recreate_versions! if user.avatar?
end
```

**Added**:

- **decidim-core**: GDPR: Add Right of data portability. [\#3489](https://github.com/decidim/decidim/pull/3489)
- **decidim-core**: GDPR: Opt-in for all the users with newsletters [\#3492](https://github.com/decidim/decidim/issues/3492)
- **decidim-initiatives**: Notify the followers when an initiative's signatures end date has been extended [\#3621](https://github.com/decidim/decidim/pull/3621)
- **decidim-core**: Add a new avatar size so that it is displayed properly on the profile page [\#3716](https://github.com/decidim/decidim/pull/3716)

**Changed**:

- **decidim-verifications**: Added a current component reference to the action authorizer. Custom ActionAuthorizer classes should receive it in a third argument of the initializer method, as `DefaultActionAuthorizer` does. [\#3708](https://github.com/decidim/decidim/pull/3708)
- **decidim-core**: Introduce coauthorable concern and coauthorship model. [\#3310](https://github.com/decidim/decidim/pull/3310)
- **decidim-core**: New user profile design [\#3415](https://github.com/decidim/decidim/pull/3290)
- **decidim-core**: Force user_group.name uniqueness in user_group test factory. [\#3290](https://github.com/decidim/decidim/pull/3290)
- **decidim-admin**: Admins no longer need to introduce raw json to define options for an authorization workflow. [\#3300](https://github.com/decidim/decidim/pull/3300)
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
- **decidim-participatory_processes**: Make process moderators receive notifications about flagged content [\#3605](https://github.com/decidim/decidim/pull/3605)
- **decidim-meetings**: Do not let users join a meeting from the Search page, as the button fails [\#3612](https://github.com/decidim/decidim/pull/3612)
- **decidim-core**: Scope nicknames in organizations, so they don't have to be unique in a multi-tenant setup [\#3671](https://github.com/decidim/decidim/pull/3671)

**Fixed**:

- **decidim-core**: Search results should be paginated so that server does not hang when search term is too wide. [\#3605](https://github.com/decidim/decidim/pull/3605)
- **decidim-assemblies**: Fix private assemblies showing more than once for private users. [\#3638](https://github.com/decidim/decidim/pull/3638)
- **decidim-proposals**: Do not index non published Proposals. [\#3618](https://github.com/decidim/decidim/pull/3618)
- **decidim-proposals**: Fix link to endorsements behaviour, now it does not link when there are no endorsements. [\#3531](https://github.com/decidim/decidim/pull/3531)
- **decidim-meetings**: Fix meetings M card cell so that it works outside the component [\#3612](https://github.com/decidim/decidim/pull/3612)
- **decidim-proposals**: Fix proposals M card cell so that it works outside the component [\#3612](https://github.com/decidim/decidim/pull/3612)
- **decidim-core**: Adds a missing migration to properly rename features to components [\#3657](https://github.com/decidim/decidim/pull/3657)
- **decidim-blogs**: Use custom sanitizer in views instead of the default one [\#3655](https://github.com/decidim/decidim/pull/3655)
- **decidim-core**: Use custom sanitizer in views instead of the default one [\#3655](https://github.com/decidim/decidim/pull/3655)
- **decidim-initiatives**: Use custom sanitizer in views instead of the default one [\#3655](https://github.com/decidim/decidim/pull/3655)
- **decidim-sortitions**: Use custom sanitizer in views instead of the default one [\#3655](https://github.com/decidim/decidim/pull/3655)
- **decidim-assemblies**: Let space users access the admin area from the public one [\#3666](https://github.com/decidim/decidim/pull/3666)
- **decidim-participatory_processes**: Let space users access the admin area from the public one [\#3666](https://github.com/decidim/decidim/pull/3666)
- **decidim-core**: Fix comments count failing in AuthorCell [\#3668](https://github.com/decidim/decidim/pull/3668)
- **decidim-proposals**: Fix proposal date to published_at in: card_m, details, admin and exporter [\#3649](https://github.com/decidim/decidim/pull/3649)
- **decidim-assemblies**: Let assembly admins access all content [\#3706](https://github.com/decidim/decidim/pull/3706)
- **decidim-admin**: Let user managers access the public space [\#3720](https://github.com/decidim/decidim/pull/3720)
- **decidim-generators**: Generated application not including bootsnap.
- **decidim-generators**: Generated application not including optional gems.
- **decidim-core**: Fix invitations form newsletter optin [\#3789](https://github.com/decidim/decidim/issues/3789)
- **decidim-core**: Fix newsletter opt-in migration [\#4198](https://github.com/decidim/decidim/pull/4219)

**Removed**:

## Previous versions

Please check [0.12-stable](https://github.com/decidim/decidim/blob/0.12-stable/CHANGELOG.md) for previous changes.
