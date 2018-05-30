# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

**Upgrade notes**:

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

**Added**:

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

**Changed**:

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
- **decidim-comments**: Let comments have paragraphs to increase readability [\#3538](https://github.com/decidim/decidim/pull/3538)

**Fixed**:

- **decidim-assembly**: Fix Non private users can participate to a private, transparent assembly [\#3438](https://github.com/decidim/decidim/pull/3438)
- **decidim-proposals**: Fixes artificial margin between proposal "header" and list of endorsements. [\#2893](https://github.com/decidim/decidim/pull/2893)
- **decidim-proposals**: Use translations for hardcoded text. [\#3464](https://github.com/decidim/decidim/pull/3464)
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

**Removed**:

Please check [0.11-stable](https://github.com/decidim/decidim/blob/0.11-stable/CHANGELOG.md) for previous changes.
