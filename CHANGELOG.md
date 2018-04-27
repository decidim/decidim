# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

**Upgrade notes**:

This version has breaking changes, `Decidim::Feature` has been renamed to `Decidim::Component`,
and also everything related to it (controllers, views, etc.). If you have customised some
controller or added a new module you need to rename `feature` to `component`.

With the addition of the new step "Complete" to the proposal creation wizard,
administrators should keep in mind updating the help texts for each step.

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

**Added**:

- **decidim-meetings**: Add Minutes entity to manage Minutes. [\#3213](https://github.com/decidim/decidim/pull/3213)

**Changed**:

- **decidim-core**: Force user_group.name uniqueness in user_group test factory. (https://github.com/decidim/decidim/pull/3290)
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
- **decidim-admin**: Admins no longer need to introduce raw json to define options for an authorization workflow. [\#3300](https://github.com/decidim/decidim/pull/3300)

**Fixed**:

- **decidim-accountability**: Fixes linking proposals to results for accountability on creation time. [\#3167](https://github.com/decidim/decidim/pull/3262)
- **decidim-proposals**: Fixes clicking on "see all" should remove the ellipsis sign. [\#2894](https://github.com/decidim/decidim/pull/3238)

**Removed**:

Please check [0.11-stable](https://github.com/decidim/decidim/blob/0.11-stable/CHANGELOG.md) for previous changes.
