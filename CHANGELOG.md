# Change Log


## 0.12.2 - OSP specific changes:

**Added**:

- **decidim-proposals** Lists are imported as a single proposal. [\#4801](https://github.com/decidim/decidim/pull/4801)
- **decidim-proposals**: Add Participatory Text support for links in Markdown. [\#4801](https://github.com/decidim/decidim/pull/4801)
- **decidim-proposals**: Add Participatory Text support for images in Markdown. [\#4801](https://github.com/decidim/decidim/pull/4801)

**Changed**:

- **decidim-proposals** Allow to change participatory texts title without uploading file. [\#4801](https://github.com/decidim/decidim/pull/4801)

**Fixed**:

- **decidim-proposals**: Fix attachments not being inherited from collaborative draft when published as proposal. [\#4815](https://github.com/decidim/decidim/pull/4815)
- **decidim-proposals**: Fix participatory texts error uploading files with accents and special characters. [\#4801](https://github.com/decidim/decidim/pull/4801)
- **decidim-proposals** Public view of Participatory Text is now preserving new lines. [\#4801](https://github.com/decidim/decidim/pull/4801)
- **decidim-core**: Fix action authorizer with blank permissions [\#4746](https://github.com/decidim/decidim/pull/4746)
- **decidim-assemblies**: Fix assemblies filter by type [\#4777](https://github.com/decidim/decidim/pull/4777)

## [0.16.0](https://github.com/decidim/decidim/tree/v0.16.0)

**Upgrade notes**:

- **decidim-budgets**: Re-introduce vote on budget by number of project. This feature has not been fully tested. See [\#265](https://github.com/OpenSourcePolitics/decidim/pull/265)
- **Banner uploader**: banner uploader has been changed in [\#150](https://github.com/OpenSourcePolitics/decidim/pull/150)
you should update existing image if you don't want to reupload them.
use the following command in your rails console : `Decidim::ParticipatoryProcess.find_each { |process| process.banner_image.recreate_versions! if process.banner_image? }`
- **Avater uploader**: Avater uploader has been changed in [\#147](https://github.com/OpenSourcePolitics/decidim/pull/147)
you should update existing image if you don't want to reupload them.
use the following command in your rails console : `Decidim::User.find_each { |user| user.avatar.recreate_versions! if user.avatar? }`

**Added**:

- **decidim-admin**: Add pagination to private user list. [\#345](https://github.com/OpenSourcePolitics/decidim/pull/345)
- **decidim-budgets**: Re-introduce vote on budget by number of project.[\#330](https://github.com/OpenSourcePolitics/decidim/pull/330)
- **decidim-debates**: Allow debates to be reported [\#199](https://github.com/OpenSourcePolitics/decidim/pull/199)
- **decidim-proposals**: Allow proposals location to be changed on a map [\#296](https://github.com/OpenSourcePolitics/decidim/pull/296)
- **decidim-participatory_processes**: Ability to order processes in the back-office [#189](https://github.com/OpenSourcePolitics/decidim/pull/189)
- **decidim-debates**: add export feature to debates [#270](https://github.com/OpenSourcePolitics/decidim/pull/270)
- **decidim-debates**: Allow debates to be reported [#199](https://github.com/OpenSourcePolitics/decidim/pull/199)
- **decidim-core**: Banner uploader has been changed in [\#150](https://github.com/OpenSourcePolitics/decidim/pull/150)
- **decidim-core**: Avater uploader has been changed in [\#147](https://github.com/OpenSourcePolitics/decidim/pull/147)
- **decidim-core**: Now have a quality setting which can be used by adding `process quality:%%` where %% is  your desired percentage of quality
- **decidim-core** : Add an initializer otion to skip first login authorization [\#176](https://github.com/OpenSourcePolitics/decidim/pull/176)
- **decidim-admin**: Add link to user profile and link to conversation from admin space. [\#208](https://github.com/OpenSourcePolitics/decidim/pull/208)
- **decidim-core**: Add a config accessor for admin upload attachment
[\#258](https://github.com/OpenSourcePolitics/decidim/issues/258)


**Changed**:

- ~~**decidim-proposals**: Remove caps first validator. Format title and body without any intervention from the user [\#259](https://github.com/OpenSourcePolitics/decidim/pull/259)~~
- **decidim-participatory_processes**: Make process moderators receive notifications about flagged content [\#228](https://github.com/OpenSourcePolitics/decidim/pull/228)
- **decidim-participatory_processes**: Add customised action button text regarding to the steps [\#257](https://github.com/OpenSourcePolitics/decidim/issues/257)
 - **decidim-participatory_processes**: Make process moderators receive notifications about flagged content [\#228](https://github.com/OpenSourcePolitics/decidim/pull/228)

**Fixed**:

- **decidim-core**: Fix comments count when a comment has been moderated [\#349](https://github.com/OpenSourcePolitics/decidim/pull/349)
- **decidim-participatory_processes**: Fix participatory processes pagination[\#351](https://github.com/OpenSourcePolitics/decidim/pull/351)
- **decidim-core**: Fix newsletter notification modal [\#342](https://github.com/OpenSourcePolitics/decidim/pull/342)
- **decidim-proposals**: Fix responsive car preview for proposals[\#325](https://github.com/OpenSourcePolitics/decidim/pull/325)
- **decidim-budgets**: Add hyphens to budget card. [\#305](https://github.com/OpenSourcePolitics/decidim/pull/305)
- **decidim-admin**: Fix issue when updating a navbar link. [\#310](https://github.com/OpenSourcePolitics/decidim/pull/310)
- **decidim-surveys**: Fix validation issue on survey sortable question [\#314](https://github.com/OpenSourcePolitics/decidim/pull/314)
- **decidim-surveys**: Fix issue when copying. [\#308](https://github.com/decidim/decidim/pull/308)
- **decidim-proposals**: Proposal creation and update fixes: [\#3744](https://github.com/decidim/decidim/pull/3744)
  - Fix `CookieOverflow` in wizard steps
  - Fix `proposal_length` validation on create_step
  - Fix ability to update proposal attachment
  - Fix `has_address` checked and `address` on invalid form
  - Fix ability to update the proposal's `author/user_group`
- **decidim-admin**: Add email validation to ManagedUserPromotionForm. [\#295](https://github.com/OpenSourcePolitics/decidim/pull/295)
- **decidim-budgets**: Fix display of budgets when votes count is activated. [\#268](https://github.com/OpenSourcePolitics/decidim/pull/268)
- **decidim-accountability**: Fix accountability progress to be between 0 and 100 if provided. [\#3952](https://github.com/decidim/decidim/pull/3952)
- **decidim-participatory_processes**: Fix hastag display on participatory processes. [\#200](https://github.com/OpenSourcePolitics/decidim/pull/200)
- **decidim-core**: Fix test consistency [#222](https://github.com/OpenSourcePolitics/decidim/pull/222)
- **decidim-core**: Add shinier signature. [#186](https://github.com/OpenSourcePolitics/decidim/pull/186)

**Backported**:

**decidim-proposals**: Fix collaborative draft attachment when attachments are enabled after collaborative draft creation [\#503](https://github.com/OpenSourcePolitics/decidim/pull/503)
- **decidim-core**: Don't send emails to deleted users [\#364](https://github.com/OpenSourcePolitics/decidim/pull/364)
- **decidim-core**: Fix notifications sending when there's no component. [\#348](https://github.com/opensourcepolitics/decidim/pull/348)
- **decidim-surveys**: Allow deleting surveys components when there are no answers [#211](https://github.com/OpenSourcePolitics/decidim/pull/211)
- **decidim-proposals**: Hide withdrawn proposals from index [\#4012](https://github.com/decidim/decidim/pull/4012)
- **decidim-proposals**: Hide withdrawn proposals from index [\#4012](https://github.com/decidim/decidim/pull/4012)
- **decidim-core**: Allows users with admin access to preview unpublished components [\#209](https://github.com/OpenSourcePolitics/decidim/pull/209)
- **decidim-core**: Fix proposal mentioned notification. [\#4281](https://github.com/decidim/decidim/pull/4281)

## [Unreleased](https://github.com/decidim/decidim/tree/0.11-stable)
## [Unreleased](https://github.com/decidim/decidim/tree/0.15-stable)

**Fixed**:

- **decidim-meetings**: Fix meetings form when only one locale is available [\#4625](https://github.com/decidim/decidim/pull/4625)
- **decidim-core**: Update Ransack to make it work with Rails 5.2.2 [\#4683](https://github.com/decidim/decidim/pull/4683)
- **decidim-core**: Remove `current_feature` [\#4680](https://github.com/decidim/decidim/pull/4680)
- **decidim-meetings**: Filter meeting by end time instead of start time [\#4703](https://github.com/decidim/decidim/pull/4703)

## [0.15.1](https://github.com/decidim/decidim/tree/v0.15.1)

**Fixed**:

- **decidim-meetings**: Change title to description in meetings admin form. [\#4484](https://github.com/decidim/decidim/pull/4484)
- **decidim-meetings**: Fix title and description fields in admin form. [\#4547](https://github.com/decidim/decidim/pull/4547)
- **decidim-proposals**: Fix vote-rerendering on a proposal's page [\#4558](https://github.com/decidim/decidim/pull/4558)
- **decidim-admin**: Fix image updating in content blocks [\#4561](https://github.com/decidim/decidim/pull/4561)
- **decidim-core**: Fix tabs with inputs with invalid characters [\#4561](https://github.com/decidim/decidim/pull/4561)

## [0.15.0](https://github.com/decidim/decidim/tree/v0.15.0)

**Added**:

- **decidim-proposals**: Added a button to reset all participatory text drafts. [\#4817](https://github.com/decidim/decidim/pull/4817)
- **decidim-proposals**: In participatory texts it is better to render Article cards open by default. [\#4817](https://github.com/decidim/decidim/pull/4817)
- **decidim-proposals**: Allow to persist participatory text drafts before publishing. [\#4817](https://github.com/decidim/decidim/pull/4817)
- **decidim-proposals** Lists are imported as a single proposal. [\#4801](https://github.com/decidim/decidim/pull/4801)
- **decidim-proposals**: Add Participatory Text support for links in Markdown. [\#4801](https://github.com/decidim/decidim/pull/4801)
- **decidim-proposals**: Add Participatory Text support for images in Markdown. [\#4801](https://github.com/decidim/decidim/pull/4801)

**Changed**:

- **decidim-proposals** Allow to change participatory texts title without uploading file. [\#4801](https://github.com/decidim/decidim/pull/4801)

**Fixed**:

- **decidim-assemblies**: Fix parent assemblies children_count counter (add migration) [\#4855](https://github.com/decidim/decidim/pull/4855/)
- **decidim-assemblies**: Fix parent assemblies children_count counter [\#4847](https://github.com/decidim/decidim/pull/4847/)
- **decidim-proposals**: Fix Proposals Last Activity feed. [\#4836](https://github.com/decidim/decidim/pull/4836)
- **decidim-proposals**: Fix attachments not being inherited from collaborative draft when published as proposal. [\#4815](https://github.com/decidim/decidim/pull/4815)
- **decidim-proposals**: Fix participatory texts error uploading files with accents and special characters. [\#4801](https://github.com/decidim/decidim/pull/4801)
- **decidim-proposals** Public view of Participatory Text is now preserving new lines. [\#4801](https://github.com/decidim/decidim/pull/4801)
- **decidim-core**: Fix action authorizer with blank permissions [\#4746](https://github.com/decidim/decidim/pull/4746)
- **decidim-assemblies**: Fix assemblies filter by type [\#4777](https://github.com/decidim/decidim/pull/4777)
- **decidim-initiatives**: Better admin initiative search [\#4845](https://github.com/decidim/decidim/pull/4845)
- **decidim-meetings**: Order meetings at admin [\#4844](https://github.com/decidim/decidim/pull/4844)
- **decidim-proposals** Fix proposals search indexes [\#4857](https://github.com/decidim/decidim/pull/4857)
- **decidim-proposals** Remove etiquette validation from proposals admin [\#4856](https://github.com/decidim/decidim/pull/4856)
- **decidim-proposals** Fix recent proposals order [\#4854](https://github.com/decidim/decidim/pull/4854)
- **decidim-core**: Fix user activities list [\#4853](https://github.com/decidim/decidim/pull/4853)
- **decidim-comments** Fix author display in comments [\#4851](https://github.com/decidim/decidim/pull/4851)
- **decidim-debates** Allow HTML content at debates page [\#4850](https://github.com/decidim/decidim/pull/4850)
- **decidim-proposals**: Fix proposal activity cell rendering. [\#4848](https://github.com/decidim/decidim/pull/4848)
- **decidim-forms**: Fix free text fields exporting. [\#4846](https://github.com/decidim/decidim/pull/4846)
- **decidim-debates** Fix debates card and ordering [\#4879](https://github.com/decidim/decidim/pull/4879)
- **decidim-proposals** Don't count withdrawn proposals when publishing one [\#4875](https://github.com/decidim/decidim/pull/4875)
- **decidim-core**: Fix process filters [\#4872](https://github.com/decidim/decidim/pull/4872)


## [0.16.0](https://github.com/decidim/decidim/tree/v0.16.0)

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
- **Metrics**: See [metrics docs](/docs/metrics.md)

- **Newsletter OptIn migration**: *Only for upgrades from 0.13 version* With the 0.13 version, User's field `newsletter_notifications_at` could had not been correctly filled for subscribed users with `ChangeNewsletterNotificationTypeValue` migration. To solve it, and in case you have an updated list of old subscribed users, you could execute the following command in Rails console.

```ruby
Decidim::User.where(**search for old subscribed users**).update(newsletter_notifications_at: Time.zone.parse("2018-05-24 00:00 +02:00"))
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
- **Metrics**: See [metrics docs](/docs/advanced/metrics.md)
- **Surveys / Forms**: *Only for upgrades from 0.15 or earlier versions*

The logic from `decidim-surveys` has been extracted to `decidim-forms`, so you need to migrate the data to the new database tables:

```ruby
bundle exec rake decidim_surveys:migrate_data_to_decidim_forms
```

Once you are sure that the data is migrated, you can create a migration in your app to remove the old `decidim_surveys` tables:

````ruby
class RemoveDecidimSurveysTablesAfterMigrateToDecidimForms < ActiveRecord::Migration[5.2]
  def up
    # Drop tables
    drop_table :decidim_surveys_survey_answers
    drop_table :decidim_surveys_survey_answer_choices
    drop_table :decidim_surveys_survey_answer_options
    drop_table :decidim_surveys_survey_questions

    # Drop columns from surveys table
    remove_column :decidim_surveys_surveys, :title
    remove_column :decidim_surveys_surveys, :description
    remove_column :decidim_surveys_surveys, :tos
    remove_column :decidim_surveys_surveys, :published_at
  end
end
````

- **Core**:

Default help content will be created on new organizations. For existing organizations, though,
you'll have to populate it yourself.

Fortunately enough, this is an easy thing to do. Just open an IRB session in your environment
and execute:

```ruby
Decidim::Organization.find_each do |organization|
  Decidim::System::PopulateHelp.call(organization)
end
```

- **Searchable resources**

As per #4537, if you have a custom module with a resource that uses the `Decidim::Searchable`
concern, you'll need to make the resource searchable from its manifest, otherwise it won't
appear under the global search results:

```ruby
Decidim.register_resource(:my_resource) do |resource|
  resource.searchable = true
  # ...
end
```

In order to generate Open Data exports you should add this to your crontab or recurring jobs manager:

```ruby
  bundle exec rake decidim:open_data:export
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
- **decidim-conferences**: Apply new design for Conferences [#4194](https://github.com/decidim/decidim/pull/4194)
- **decidim-conferences**: Added Conferences as a Participatory Space. This module is a configurator and generator of Conference pages, understood as a collection of Meeting. [\#3781](https://github.com/decidim/decidim/pull/3781)
- **decidim-meetings**: Apply hashtags to meetings [\#4080](https://github.com/decidim/decidim/pull/4080)
- **decidim-assemblies**: Add organizational chart to assemblies home. [\#4045](https://github.com/decidim/decidim/pull/4045)
- **decidim-core**: Adds the *followers* badge. [\#4089](https://github.com/decidim/decidim/pull/4089)
- **decidim-debates**: Adds the *commented debates* badge. [\#4089](https://github.com/decidim/decidim/pull/4089)
- **decidim-meetings**: Add upcoming events content block and page. [\#3987](https://github.com/decidim/decidim/pull/3987)
- **decidim-generators**: Enable one more bootsnap optimization in test apps when coverage tracking is not enabled [\#4098](https://github.com/decidim/decidim/pull/4098)
- **decidim-assemblies**: Set max number of results in highlighted assemblies content block (4, 8 or 12) [\#4125](https://github.com/decidim/decidim/pull/4125)
- **decidim-initiatives**: Initiative printable form now includes the initiative type. [\#3938](https://github.com/decidim/decidim/pull/3938)
- **decidim-initiatives**: Set max number of results in highlighted initiatives content block (4, 8 or 12) [\#4127](https://github.com/decidim/decidim/pull/4127)
- **decidim-participatory_processes**: Set max number of results in highlighted processes content block (4, 8 or 12) [\#4124](https://github.com/decidim/decidim/pull/4124)
- **decidim-core**: Add an HTML content block [\#4134](https://github.com/decidim/decidim/pull/4134)
- **decidim-consultations**: Add a "Highlighted consultations" content block [\#4137](https://github.com/decidim/decidim/pull/4137)
- **decidim-admin**: Adds a link to the admin navigation so users can easily access the public page. [\#4126](https://github.com/decidim/decidim/pull/4126)
- **decidim-dev**: Configuration tweaks to make spec support files directly requirable from end applications and components. [\#4151](https://github.com/decidim/decidim/pull/4151)
- **decidim-generators**: Allow final applications to configure DB port through an env variable. [\#4154](https://github.com/decidim/decidim/pull/4154)
- **decidim-proposals**: Let admins edit official proposals from the admin. They have the same restrictions as normal users form the public area [\#4150](https://github.com/decidim/decidim/pull/4150)
- **decidim-meetings**: Add the "Attended meetings" badge [\#4160](https://github.com/decidim/decidim/pull/4160)
- **decidim-core**: Added metrics visualization for Users and Proposals (all, accepted and votes) [\#3603](https://github.com/decidim/decidim/pull/3603)
- **decidim-participatory_processes**: Add a Call to Action button to process steps[\#4184](https://github.com/decidim/decidim/pull/4184)
- **decidim-core**: Show user groups profiles [\#4196](https://github.com/decidim/decidim/pull/4196)
- **decidim-core**: Show user groups on users profiles [\#4236](https://github.com/decidim/decidim/pull/4236)
- **decidim-core**: Add roles to user group memberships [\#4260](https://github.com/decidim/decidim/pull/4260)
- **decidim-core**: Add a badge info page listing all the badges and how to get them. [\#4245](https://github.com/decidim/decidim/pull/4245)
- **decidim-core**: Show members on user groups profiles [\#4252](https://github.com/decidim/decidim/pull/4252)
- **decidim-core**: Badges can now be disabled per organization. [\#4249](https://github.com/decidim/decidim/pull/4249)
- **decidim-core**: Adds a "Continuity" badge. [\#4257](https://github.com/decidim/decidim/pull/4257)
- **decidim-core**: Add activity feed content block and page. [\#4130](https://github.com/decidim/decidim/pull/4130)
- **decidim-core**: Allow user to sign-in without confirming their email. [\#4269](https://github.com/decidim/decidim/pull/4269)

**Changed**:

- **decidim-assemblies**: For consistency with DB, `ceased_date` and `designation_date` columns now use date attributes in forms, instead of datetime ones. [\#3724](https://github.com/decidim/decidim/pull/3724)
- **decidim-assemblies**: Don't show child assemblies in assemblies general homepage. [\#4239](https://github.com/decidim/decidim/pull/4239)
- **decidim-core**: Allow users to enter datetime fields manually. [\#3724](https://github.com/decidim/decidim/pull/3724)
- **decidim-core**: Allow users to enter date fields manually. [\#3724](https://github.com/decidim/decidim/pull/3724)
- **decidim-core**: Merge Users and UserGroups DB tables [\#4196](https://github.com/decidim/decidim/pull/4196)
- **decidim-core**: Move user group creation to user profile [\#4256](https://github.com/decidim/decidim/pull/4256)

**Fixed**:

- **decidim-conferences**: Add the new design of Uploaded Attachments to a Conference, and add the MediaLinks entity. [\#4285](https://github.com/decidim/decidim/pull/4285)
- **decidim-proposals**: When Participatory Texts are published, the admin has the chance to update the contents of each Proposal. [#4326](https://github.com/decidim/decidim/pull/4326)
- **decidim-conferences**: Add the relationship with other spaces. Each Conference-page should potentially be related to participatory processes, consultations and assemblies. [\#4339](https://github.com/decidim/decidim/pull/4339)
- **decidim-conferences**: Apply new design for Conference Program [#4271](https://github.com/decidim/decidim/pull/4271)
- **decidim-proposals**: Administration panel related implementation of Participatory Texts. [#4229](https://github.com/decidim/decidim/pull/4229)
- **decidim-conferences**: Add Partners to Conference. [\#4251](https://github.com/decidim/decidim/pull/4251)
- **decidim-conferences**: Apply new design for Conferences [#4194](https://github.com/decidim/decidim/pull/4194)
- **decidim-conferences**: Added Conferences as a Participatory Space. This module is a configurator and generator of Conference pages, understood as a collection of Meeting. [\#3781](https://github.com/decidim/decidim/pull/3781)
- **decidim-meetings**: Apply hashtags to meetings [\#4080](https://github.com/decidim/decidim/pull/4080)
- **decidim-assemblies**: Add organizational chart to assemblies home. [\#4045](https://github.com/decidim/decidim/pull/4045)
- **decidim-core**: Adds the *followers* badge. [\#4089](https://github.com/decidim/decidim/pull/4089)
- **decidim-debates**: Adds the *commented debates* badge. [\#4089](https://github.com/decidim/decidim/pull/4089)
- **decidim-meetings**: Add upcoming events content block and page. [\#3987](https://github.com/decidim/decidim/pull/3987)
- **decidim-generators**: Enable one more bootsnap optimization in test apps when coverage tracking is not enabled [\#4098](https://github.com/decidim/decidim/pull/4098)
- **decidim-assemblies**: Set max number of results in highlighted assemblies content block (4, 8 or 12) [\#4125](https://github.com/decidim/decidim/pull/4125)
- **decidim-initiatives**: Initiative printable form now includes the initiative type. [\#3938](https://github.com/decidim/decidim/pull/3938)
- **decidim-initiatives**: Set max number of results in highlighted initiatives content block (4, 8 or 12) [\#4127](https://github.com/decidim/decidim/pull/4127)
- **decidim-participatory_processes**: Set max number of results in highlighted processes content block (4, 8 or 12) [\#4124](https://github.com/decidim/decidim/pull/4124)
- **decidim-core**: Add an HTML content block [\#4134](https://github.com/decidim/decidim/pull/4134)
- **decidim-consultations**: Add a "Highlighted consultations" content block [\#4137](https://github.com/decidim/decidim/pull/4137)
- **decidim-admin**: Adds a link to the admin navigation so users can easily access the public page. [\#4126](https://github.com/decidim/decidim/pull/4126)
- **decidim-dev**: Configuration tweaks to make spec support files directly requirable from end applications and components. [\#4151](https://github.com/decidim/decidim/pull/4151)
- **decidim-generators**: Allow final applications to configure DB port through an env variable. [\#4154](https://github.com/decidim/decidim/pull/4154)
- **decidim-proposals**: Let admins edit official proposals from the admin. They have the same restrictions as normal users form the public area [\#4150](https://github.com/decidim/decidim/pull/4150)
- **decidim-meetings**: Add the "Attended meetings" badge [\#4160](https://github.com/decidim/decidim/pull/4160)
- **decidim-core**: Added metrics visualization for Users and Proposals (all, accepted and votes) [\#3603](https://github.com/decidim/decidim/pull/3603)
- **decidim-participatory_processes**: Add a Call to Action button to process steps[\#4184](https://github.com/decidim/decidim/pull/4184)
- **decidim-core**: Show user groups profiles [\#4196](https://github.com/decidim/decidim/pull/4196)
- **decidim-core**: Show user groups on users profiles [\#4236](https://github.com/decidim/decidim/pull/4236)
- **decidim-core**: Add roles to user group memberships [\#4260](https://github.com/decidim/decidim/pull/4260)
- **decidim-core**: Add a badge info page listing all the badges and how to get them. [\#4245](https://github.com/decidim/decidim/pull/4245)
- **decidim-core**: Show members on user groups profiles [\#4252](https://github.com/decidim/decidim/pull/4252)
- **decidim-core**: Badges can now be disabled per organization. [\#4249](https://github.com/decidim/decidim/pull/4249)
- **decidim-core**: Adds a "Continuity" badge. [\#4257](https://github.com/decidim/decidim/pull/4257)
- **decidim-core**: Add activity feed content block and page. [\#4130](https://github.com/decidim/decidim/pull/4130)
- **decidim-core**: Allow user to sign-in without confirming their email. [\#4269](https://github.com/decidim/decidim/pull/4269)
- **decidim-core**: Fix proposal mentioned notification. [\#4281](https://github.com/decidim/decidim/pull/4281)
- **decidim-core**: Added metrics visualization for Assemblies, ParticipatoryProcesses, Results (Accountability), Comments, and Meetings [\#36042283](https://github.com/decidim/decidim/pull/4228)
- **decidim-core**: Let admins and creators edit the user group profile [\#4283](https://github.com/decidim/decidim/pull/4283)
- **decidim-core**: User groups can also have badges. [\#4310](https://github.com/decidim/decidim/pull/4310)
- **decidim-proposals**: Merge and split proposals [\#4360](https://github.com/decidim/decidim/pull/4360)
- **decidim-assemblies**: Add feature filter assemblies by type [\#4659](https://github.com/decidim/decidim/pull/4659/)
- **decidim-meetings**: Add notification to conferences and meetings registrations [\#4636](https://github.com/decidim/decidim/pull/4636/)
- **decidim-proposals**: Add amend button and amendments counter to participatory text proposals [\#4598](https://github.com/decidim/decidim/pull/4598/)
- **decidim-proposals**: Add filter by type functionality to Amendments on proposals. [\#4567](https://github.com/decidim/decidim/pull/4567/)
- **decidim-proposals**: Add version control functionality to Amendments on proposals. [\#4567](https://github.com/decidim/decidim/pull/4567/)
- **decidim-core**: Add reject/promote amendments functionalities to the Amendment feature. [\#3986](https://github.com/decidim/decidim/pull/3986/)
- **decidim-proposals**: Automatic and suggested hashtags. [\#4585](https://github.com/decidim/decidim/pull/4585/)
- **decidim-core**: Add version control functionality into Amendment feature. [\#4567](https://github.com/decidim/decidim/pull/4567/)
- **decidim-core**: Add reject/promote amendments functionalities into Amendment feature. [\#3986](https://github.com/decidim/decidim/pull/3986/)
- **decidim-core**: Add polymorphic Amendment feature that can be activated in the proposal component with these working functionalities: create/withdraw/accept amendments. [\#3985](https://github.com/decidim/decidim/pull/3985/)
- **decidim-meetings**: Add registration form answers when exporting meeting registrations.[\#4589](https://github.com/decidim/decidim/pull/4589)
- **decidim-core**: Trigger an ActiveSupport::Notification after registering via OmniAuth. [\#4565](https://github.com/decidim/decidim/pull/4565)
- **decidim-proposals**: Specific public view rendering of participatory texts. [\#4316](https://github.com/decidim/decidim/pull/4316)
- **decidim-proposals**: Admin can create proposals from the admin panel, with a meeting as an author.[\#4382](https://github.com/decidim/decidim/pull/4382)
- **decidim-conferences**: Add diplomas functionallity in an automated way for those users that has their registration confirmed. [\#4443](https://github.com/decidim/decidim/pull/4443)
- **decidim-proposals**: Add support to import .odt participatory text files. [\#4386](https://github.com/decidim/decidim/pull/4386)
- **decidim-conferences**: Add conference registration types. [\#4408](https://github.com/decidim/decidim/pull/4408)
- **decidim-core**: Added `users_registration_mode` to allow disable users registration or login [\#4428](https://github.com/decidim/decidim/pull/4428)
- **decidim-forms**: Create a new gem to hold reusable surveys logic [\#3877](https://github.com/decidim/decidim/pull/3877)
- **decidim-meetings**: Allow admins to activate a registration form to be answered by the user when they joins for the meeting [\#4419](https://github.com/decidim/decidim/pull/4419)
- **decidim-verifications**: Add SMS verification workflow [\#4429](https://github.com/decidim/decidim/pull/4429)
- **decidim-proposals**: Split & merge proposals to the same component [\#4415](https://github.com/decidim/decidim/pull/4415)
- **decidim-core**: Adds the ability to send a welcome notification to new users [#4432](https://github.com/decidim/decidim/pull/4432)
- **decidim-core**: Shows the first unread message in a conversation in the notification email [#4463](https://github.com/decidim/decidim/pull/4463)
- **decidim-meetings**: Add a meetings calendar at organization and component levels [\#4376](https://github.com/decidim/decidim/pull/4376)
- **decidim-proposals**: Add user groups and meetings options on Origin filters [\#4462](https://github.com/decidim/decidim/pull/4462)
- **decidim-accountability**: Notify followers of the proposals linked in a result that the result progress has been updated [\#4466](https://github.com/decidim/decidim/pull/4466)
- **decidim-admin**: Adds the ability to specify contextual help to participatory spaces [\#4470](https://github.com/decidim/decidim/pull/4470)
- **decidim-core**: Show minicard with a little bit of profile data when hovering on user and user group names [\#4472](https://github.com/decidim/decidim/pull/4472)
- **decidim-core**: Added more metric calculations. It involves several adding in related modules: proposals, participatory_processes, debates, etc... [\#4372](https://github.com/decidim/decidim/pull/4372)
- **decidim-core**: Let users find search results by writing prefixes of a word instead of whole words [\#4492](https://github.com/decidim/decidim/pull/4492)
- **decidim-core**: Add Etherpad integration [\#4493](https://github.com/decidim/decidim/pull/4493)
- **decidim-meetings**: Add Etherpad integration [\#4493](https://github.com/decidim/decidim/pull/4493)
- **decidim-core**: Adds default pages and contextual help when creating organizations [\#4541](https://github.com/decidim/decidim/pull/4541)
- **decidim-core**: Adds a user activity tab on the public profile. [\#4570](https://github.com/decidim/decidim/pull/4570)
- **decidim-core**: Adds a user timeline tab on the public profile. [\#4574](https://github.com/decidim/decidim/pull/4574)
- **decidim-core**: Open Data export [\#4578](https://github.com/decidim/decidim/pull/4578)
- **decidim-meetings**: Export meetings [\#4597](https://github.com/decidim/decidim/pull/4597)
- **decidim-core**: User groups can now confirm their email [\#4603](https://github.com/decidim/decidim/pull/4603)
- **decidim-core**: Admins can verify batches of user groups that have the email confirmed by uploading a CSV file [\#4613](https://github.com/decidim/decidim/pull/4613)
- **decidim-core**: Let users select their interests (scopes). They will see relevant activity in the Timeline tab in their profile [\#4621](https://github.com/decidim/decidim/pull/4621)
- **decidim-initiatives**: Add `Decidim::HasReference` concern to initiatives model, display reference in front and id in admin [\#4665](https://github.com/decidim/decidim/pull/4665)
- **decidim-core**: Let users choose what kind of notifications they want to erceive [\#4663](https://github.com/decidim/decidim/pull/4663)
- **decidim-core**: User groups can now be disabled per organization. [\#4681](https://github.com/decidim/decidim/pull/4681/)

**Changed**:

- **decidim-core**: Show hashtags with original case [\#4554](https://github.com/decidim/decidim/pull/4554)
- **decidim-conferences**: Remove right sidebar completely from the frontend [\#4480](https://github.com/decidim/decidim/pull/4480)
- **decidim-core**: Allow to configure OmniAuth provider icons [\#4440](https://github.com/decidim/decidim/pull/4440)
- **decidim-surveys**: Extract surveys logic to decidim-forms [\#3877](https://github.com/decidim/decidim/pull/3877)
- **decidim-core**: Improve static pages layout and make them groupable by topic. [\#4338](https://github.com/decidim/decidim/pull/4338)
- **decidim-core**: Improve user groups form [\#4458](https://github.com/decidim/decidim/pull/4458)
- **decidim-surveys**: Extract surveys logic to decidim-forms [\#3877](https://github.com/decidim/decidim/pull/3877)
- **decidim-core**: Move Omniauth login buttons to before the signup/sign in forms to improve usability [\#4457](https://github.com/decidim/decidim/pull/4457)
- **decidim-core**: Improved metrics core classes to handle ParticipatoryProcess' statistics show up [\#4372](https://github.com/decidim/decidim/pull/4372)
- **decidim-accountability**: Show one highlighted resources block per component in process page [\#4456](https://github.com/decidim/decidim/pull/4456)
- **decidim-meetings**: Show one highlighted resources block per component in process page [\#4456](https://github.com/decidim/decidim/pull/4456)
- **decidim-proposals**: Show one highlighted resources block per component in process page [\#4456](https://github.com/decidim/decidim/pull/4456)
- **decidim-admin**: Rename "Officializations" section to "Participants" [\#4510](https://github.com/decidim/decidim/pull/4510)
- **decidim-core**: Improve search results layout. Now results appear grouped by type [\#4537](https://github.com/decidim/decidim/pull/4537)
- **decidim-core**: Improve propoals serialization [\#4593](https://github.com/decidim/decidim/pull/4593)
- **decidim-verifications**: The ID documents verification now supports online and offline verification modes [\#4573](https://github.com/decidim/decidim/pull/4573)
- **decidim-core**: "Follows" section in user profiles now show every resource they follow [\#4616](https://github.com/decidim/decidim/pull/4616)
- **decidim-core**: Remove `current_feature` method [\#4624](https://github.com/decidim/decidim/pull/4624)
- **decidim-participatory-processes**: Disable deleting participatory processes [\#4640](https://github.com/decidim/decidim/pull/4640)
- **decidim-assemblies**: Disable deleting assemblies [\#4640](https://github.com/decidim/decidim/pull/4640)
- **decidim-conferences**: Disable deleting conferences [\#4640](https://github.com/decidim/decidim/pull/4640)
- **decidim-consultations**: Disable deleting consultations[\#4640](https://github.com/decidim/decidim/pull/4640)

**Fixed**:

- **decidim-assemblies**: Add parent when duplicating child assembly. [\#4371](https://github.com/decidim/decidim/pull/4371)
- **decidim-assemblies**: Add paginate on admin site assembly members. [\#4369](https://github.com/decidim/decidim/pull/4369)
- **decidim-admin**: Adds traceability when creating and deleting Participatory Space private user [\#4332](https://github.com/decidim/decidim/pull/4332)
- **decidim-proposals**: Rework URL_REGEX regular expression so that it is more restrictive for general URIs causing problems with Scandinavian locales. [\4290](https://github.com/decidim/decidim/pull/4290)
- **decidim-accountability**: Fix inclusion of ApplicationHelper in results controller. [\#4272](https://github.com/decidim/decidim/pull/4272)
- **decidim-admin**: Add email validation to ManagedUserPromotionForm. [\#4225](https://github.com/decidim/decidim/pull/4225)
- **decidim-surveys**: Fix issue when copying. [\#4274](https://github.com/decidim/decidim/pull/4274)
- **decidim-proposals**: Fix uncatched exception when trying to retrieve a Proposal from an invalid url match. [\4157](https://github.com/decidim/decidim/pull/4157)
- **decidim-core**: Fix data portability proposal images, modify command to create directory if not exists, and fix surveys ansewers whem exporting data portability. [\#4223](https://github.com/decidim/decidim/pull/4223)
- **decidim-debates**: When a Searchable accesses its indexed resources it must scope by resource_type and organization_id. [\4079](https://github.com/decidim/decidim/pull/4079)
- **decidim-debates**: Fix create debates as a normal user in a private space [\4108](https://github.com/decidim/decidim/pull/4108)
- **decidim-admin**: English locale now uses a consistent date format (UK style everywhere). [\#3724](https://github.com/decidim/decidim/pull/3724)
- **decidim**: Fix crashes when sending incorrectly formatted dates to forms with date fields. [\#3724](https://github.com/decidim/decidim/pull/3724)
- **decidim-proposals**: Fix hashtags on title when showing proposals related. [\#4081](https://github.com/decidim/decidim/pull/4081)
- **decidim-core**: Fix hero content block migration [\#4061](https://github.com/decidim/decidim/pull/4061)
- **decidim-core**: Fix default content block creation migration [\#4084](https://github.com/decidim/decidim/pull/4084)
- **decidim-generators**: Bootsnap warnings when generating test applications [\#4098](https://github.com/decidim/decidim/pull/4098)
- **decidim-admin**: Don't list deleted users at officialized list. [\#4139](https://github.com/decidim/decidim/pull/4139)
- **decidim-participayory_processes**: Copy categories and subcategories to the new process. [\#4143](https://github.com/decidim/decidim/pull/4143)
- **decidim-participayory_processes**: Fix Internet Explorer 11 related issues in process filtering. [\#4166](https://github.com/decidim/decidim/pull/4166)
- **decidim-core**: Fix newsletter opt-in migration [\#4198](https://github.com/decidim/decidim/pull/4198)
- **decidim-core**: Hide weird flash message [\#4235](https://github.com/decidim/decidim/pull/4235)
- **decidim-core**: Fix newsletter subscription checkbox always being unchecked [\#4238](https://github.com/decidim/decidim/pull/4238)
- **decidim-core**: Thread safe locale switching [\#4237](https://github.com/decidim/decidim/pull/4237)
- **decidim-core**: Don't crash when showing the edit link for a component that does not have an admin engine [\#4318](https://github.com/decidim/decidim/pull/4318)
- **decidim-core**: Update conversations on each new message, so conversations list always shows the most recently active one on top [\#4329](https://github.com/decidim/decidim/pull/4329)
- **decidim-core**: Don't send emails to deleted users [\#4324](https://github.com/decidim/decidim/pull/4324)
- **decidim-core**: Fix newsletter opt-in migration [\#4198](https://github.com/decidim/decidim/pull/4198)
- **decidim-core**: Hide weird flash message [\#4235](https://github.com/decidim/decidim/pull/4235)
- **decidim-core**: Fix newsletter subscription checkbox always being unchecked [\#4238](https://github.com/decidim/decidim/pull/4238)
- **decidim-core**: Don't error when the meeting registrations are updated with invalid data [\#4319](https://github.com/decidim/decidim/pull/4319)
- **decidim-core**: Thread safe locale switching [\#4237](https://github.com/decidim/decidim/pull/4237)
- **decidim-core**: Don't crash when given wrong format at pages [\#4314](https://github.com/decidim/decidim/pull/4314)
- **decidim-initiatives**: Fix initiative search with multiple types [\#4322](https://github.com/decidim/decidim/pull/4322)
- **decidim-debates**: Fix debate search with categories [\#4313](https://github.com/decidim/decidim/pull/4313)
- **decidim-core**: Fix events for polymorphic authors [\#4387](https://github.com/decidim/decidim/pull/4387)

**Removed**:

- **decidim-core**: Remove invite friends by email. [\#4434](https://github.com/decidim/decidim/pull/4434)
- **decidim-core**: Place `CurrentOrganization` middleware before `WardenManager`. [\#4721](https://github.com/decidim/decidim/pull/4721)
- **decidim-meetings**: Fix meetings form when only one locale is available [\#4623](https://github.com/decidim/decidim/pull/4623)
- **decidim-participatory_processes**: Fix admin cannot access public view of private processes by default [\#4591](https://github.com/decidim/decidim/pull/4591)
- **decidim-proposals** Index admin-created proposals. [\#4601](https://github.com/decidim/decidim/pull/4601)
- **decidim-proposals** Fix proposals created from collaborative drafts inherited attributes [\#4605](https://github.com/decidim/decidim/pull/4605)
- **decidim-meetings**: Fix meeting registration form with no questions show as already answered [\#4594](https://github.com/decidim/decidim/pull/4594)
- **decidim-proposals** Keep proposal new values for title and body when editing and receiving an error message [\#4592](https://github.com/decidim/decidim/pull/4592)
- **decidim-proposals** Don't show `undefined` option when there is no hashtag to autocomplete after \# [\#4590](https://github.com/decidim/decidim/pull/4590)
- **decidim-conferences**: Make price optional, and remove weird margin top on program view [\#4564](https://github.com/decidim/decidim/pull/4564)
- **decidim-meetings**: Fix title and description fields in admin form. [\#4535](https://github.com/decidim/decidim/pull/4535)
- **decidim-meetings**: Change title to description in meetings admin form [\#4483](https://github.com/decidim/decidim/pull/4483)
- **decidim-meetings**: Use the correct cell to render a meeting organizer [\#4501](https://github.com/decidim/decidim/pull/4501)
- **decidim-core**: Hashtags with unicode characters are now parsed correctly [\#4473](https://github.com/decidim/decidim/pull/4473)
- **decidim-conferences**: Fix some translations of conferences [\#4481](https://github.com/decidim/decidim/pull/4481)
- **decidim-conferences**: Check participatory spaces manifest exists when relating conferences to other spaces [\#4446](https://github.com/decidim/decidim/pull/4446)
- **decidim-proposals**: Allow admins to edit proposals even if creation is not enabled [\#4390](https://github.com/decidim/decidim/pull/4390)
- **decidim-core**: Fix events for polymorphic authors [\#4387](https://github.com/decidim/decidim/pull/4387)
- **decidim-meetings**: Fix order of upcoming meetings [\#4398](https://github.com/decidim/decidim/pull/4398)
- **decidim-core**: Ignore deleted users follows [\#4401](https://github.com/decidim/decidim/pull/4401)
- **decidim-comments**: Fix comment activity cell when commentable is a comment [\#4413](https://github.com/decidim/decidim/pull/4413)
- **decidim-core**: Corrected users metric calculations with scoping [\#4416](https://github.com/decidim/decidim/pull/4416)
- **decidim-comments**: Corrected comments metric calculations in loop [\#4416](https://github.com/decidim/decidim/pull/4416)
- **decidim-core**: Set `organization.tos_version` when creating `terms-and-conditions` DefaultPage [#3911](https://github.com/decidim/decidim/pull/3911)
- **decidim-proposals**: Fix title display [\#4431](https://github.com/decidim/decidim/pull/4431)
- **decidim-meetings**: Fix title display [\#4431](https://github.com/decidim/decidim/pull/4431)
- **decidim-proposals**: Ensure proposals search returns unique results [\#4460](https://github.com/decidim/decidim/pull/4460)
- **decidim-core**: Improve how to copy URLs to share [\#4507](https://github.com/decidim/decidim/pull/4507)
- **decidim-admin**: Hide the unavailable verification methods[\#4529](https://github.com/decidim/decidim/pull/4529)
- **decidim-participatory_processes**: Fix process steps CTA path on public area [\#4499](https://github.com/decidim/decidim/pull/4499)
- **decidim-participatory_processes**: Don't filter highlighted processes by state [\#4502](https://github.com/decidim/decidim/pull/4502)
- **decidim-participatory_processes**: Don't show grouped processes in the process list[\#4503](https://github.com/decidim/decidim/pull/4503)
- **decidim-core**: Fix notification settings form [\#4528](https://github.com/decidim/decidim/pull/4528)
- **decidim-proposals**: Fix vote-rerendering on a proposal's page [#4557](https://github.com/decidim/decidim/pull/4557)
- **decidim-core**: Fix tabs with inputs with invalid characters [\#4552](https://github.com/decidim/decidim/pull/4552)
- **decidim-admin**: Fix image updating in content blocks [\#4549](https://github.com/decidim/decidim/pull/4549)
- **decidim-proposals**: Fix address toggle in the add proposal form [\#4587](https://github.com/decidim/decidim/pull/4587)
- **decidim-comments**: Correctly render comments activity with mentions [\#4612](https://github.com/decidim/decidim/pull/4612)
- **decidim-meetings**: Add the participatory space to the meeting directory listing [\#4620](https://github.com/decidim/decidim/pull/4620)
- **decidim-core**: Fix nickname generation [\#4615](https://github.com/decidim/decidim/pull/4615)
- **decidim-initiatives**: Don't eager load polymorphic relations [\#4614](https://github.com/decidim/decidim/pull/4614)
- **decidim-initiatives**: Fix searching for initiatives with by type [\#4626](https://github.com/decidim/decidim/pull/4626)
- **decidim-admin**: Add missing locales for organization errors [\#4633](https://github.com/decidim/decidim/pull/4633)
- **decidim-core**: Don't crash when a log is in an unavailable locale [\#4632](https://github.com/decidim/decidim/pull/4632)
- **decidim-core**: Fix newsletter rendering when locale content is missing [\#4629](https://github.com/decidim/decidim/pull/4629)
- **decidim-initiatives**: Provide a fallback when an initative scope is missing [\#4634](https://github.com/decidim/decidim/pull/4634)
- **decidim-accountability**: Return a 404 when a result doesn't exist. [\#4630](https://github.com/decidim/decidim/pull/4630)
- **decidim-budgets**: Use bigint instead of int for projects [\#4628](https://github.com/decidim/decidim/pull/4628)
- **decidim-comments**: Fix GraphQL comments schema [\#4638](https://github.com/decidim/decidim/pull/4638)
- **decidim-core**: Better handling setting process step position [\#4638](https://github.com/decidim/decidim/pull/4638)
- **decidim-core**: Comment authors won't be notified about their own comments [\#4643](https://github.com/decidim/decidim/pull/4643)
- **decidim-core**: Don't crash on registration [\#4637](https://github.com/decidim/decidim/pull/4637)
- **decidim-debates**: Don't crash on settings change [\#4642](https://github.com/decidim/decidim/pull/4642)
- **decidim-proposals**: Don't crash on settings change [\#4642](https://github.com/decidim/decidim/pull/4642)
- **decidim-surveys**: Don't crash on settings change [\#4642](https://github.com/decidim/decidim/pull/4642)
- **decidim-core**: Update Ransack to work with Rails 5.2.2 [\#4682](https://github.com/decidim/decidim/pull/4682)
- **decidim-core**: Fix background-size on home page [\#4678](https://github.com/decidim/decidim/pull/4678)
- **decidim-meetings**: Filter meeting by end time instead of start time [\#4701](https://github.com/decidim/decidim/pull/4701)
- **decidim-core**: MetricResolver filtering corrected comparison between symbol and string [\#4736](https://github.com/decidim/decidim/pull/4736)

**Removed**:

- **decidim-core**: Remove invite friends by email. [\#4430](https://github.com/decidim/decidim/pull/4430)

## Previous versions

Please check [0.15-stable](https://github.com/decidim/decidim/blob/0.15-stable/CHANGELOG.md) for previous changes.
