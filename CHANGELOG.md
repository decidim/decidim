# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

**Upgrade notes (search)**:

In order for the currently existing Users to be indexed, you'll have to manually trigger a reindex. You can do that executing:

```ruby
Decidim::User.find_each(&:add_to_index_as_search_resource)
```

**Added**:

- **decidim-docs**: Add proposal lifecycle diagram to docs. [\#3811](https://github.com/decidim/decidim/pull/3811)
- **decidim-budgets**: Added vote project authorization action [\#3804](https://github.com/decidim/decidim/pull/3804)
- **decidim-meetings**: Added join meeting authorization action [\#3804](https://github.com/decidim/decidim/pull/3804)
- **decidim-proposals**: Added vote and endorse proposal authorization actions [\#3804](https://github.com/decidim/decidim/pull/3804)
- **decidim-core**: Support for actions authorizations at resource level [\#3804](https://github.com/decidim/decidim/pull/3804)
- **decidim-meetings**: Allow users to accept or reject invitations to meetings, and allow admins to see their status. [\#3632](https://github.com/decidim/decidim/pull/3632)
- **decidim-meetings**: Allow admins to invite existing users to meetings. [\#3831](https://github.com/decidim/decidim/pull/3831)
- **decidim-meetings**: Generate a registration code and give it to users when they join to the meeting. [\#3805](https://github.com/decidim/decidim/pull/3805)
- **decidim-core**: Make Users Searchable. [\#3796](https://github.com/decidim/decidim/pull/3796)
- **decidim-participatory_processes**: Highlight the correct menu item when visiting a process group page [\#3737](https://github.com/decidim/decidim/pull/3737)

**Changed**:

- **decidim-core**: Allow users to enter date fields manually. [\#3724](https://github.com/decidim/decidim/pull/3724)
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
- **decidim-participatory_processes**: Improve usability of filters on processes index page [\#3728](https://github.com/decidim/decidim/pull/3728)
- **decidim-meetings**: The invite attendee form has been moved to the top of the new invites list. [\#3826](https://github.com/decidim/decidim/pull/3826)
- **decidim-core**: Load authorization modals content with AJAX requests. [\#3753](https://github.com/decidim/decidim/pull/3753)
- **decidim-core**: Updated the `CollapsibleList` cell to be able to show any number of elements from 1 to 12 [\#3810](https://github.com/decidim/decidim/pull/3810)

**Fixed**:

- **decidim-proposals**: Refactor searchable proposal test to avoid flakes. [\#3825](https://github.com/decidim/decidim/pull/3825)
- **decidim-proposals**: Proposal seeds iterate over a sample of users to add coauthorships. [\#3796](https://github.com/decidim/decidim/pull/3796)
- **decidim-core**: Make proposal m-card render its authorship again. [\#3727](https://github.com/decidim/decidim/pull/3727)
- **decidim-generators**: Generated application not including bootsnap.
- **decidim-generators**: Generated application not including optional gems.
- **decidim-core**: Fix follow within search results. [\#3745](https://github.com/decidim/decidim/pull/3745)
- **decidim-proposals**: An author should always follow their proposal. [\#3791](https://github.com/decidim/decidim/pull/3791)
- **decidim-core**: Fix notifications sending when there's no component. [\#3792](https://github.com/decidim/decidim/pull/3792)
- **decidim-proposals**: Use the same proposals collection for the map. [\#3793](https://github.com/decidim/decidim/pull/3793)
- **decidim-core**: Fix followable type for Decidim::Accountability::Result. [\#3798](https://github.com/decidim/decidim/pull/3798)
- **decidim-accountability**: Fix accountability diff renderer when a locale is missing. [\#3797](https://github.com/decidim/decidim/pull/3797)
- **decidim-core**: Don't crash when a nickname has a dot. [\#3793](https://github.com/decidim/decidim/pull/3793)
- **decidim-core**: Don't crash when a page doesn't exist. [\#3799](https://github.com/decidim/decidim/pull/3799)

**Removed**:

## Previous versions

Please check [0.13-stable](https://github.com/decidim/decidim/blob/0.13-stable/CHANGELOG.md) for previous changes.
