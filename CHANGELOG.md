# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

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

## [0.16.0](https://github.com/decidim/decidim/tree/v0.16.0)

**Upgrade notes**:

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
- **decidim-initiatives**: Add setting in `Decidim::InitiativesType` to restrict online signatures [\#4668](https://github.com/decidim/decidim/pull/4668)
- **decidim-initiatives**: Extend authorizations to resources not related with components and define initiatives vote authorizations on initiatives types [\#4747](https://github.com/decidim/decidim/pull/4747)
- **decidim-initiatives**: Add setting in `Decidim::InitiativesType` to set minimum commitee members before sending initiative to technical evaluation [\#4688](https://github.com/decidim/decidim/pull/4688)
- **decidim-initiatives**: Add option to initiative types to collect personal data on signature and make related changes in front [\#4690](https://github.com/decidim/decidim/pull/4690)
- **decidim-initiatives**: Implement a mechanism to store encrytped personal data of users on votes and decrypt it exporting to PDF [\#4716](https://github.com/decidim/decidim/pull/4716)
- **decidim-initiatives**: Add setting to initiatives types to enable a step to allow initiative signature after passing SMS verification mechanism [\#4792](https://github.com/decidim/decidim/pull/4792)
- **decidim-initiatives**: Allow integration of services to add timestamps and sign PDFs, define example services and use in application generator [\#4805](https://github.com/decidim/decidim/pull/4805)
- **decidim-initiatives**: Add setting to initiatives types to verify document number provided on votes and avoid duplicated votes with the same document [\#4794](https://github.com/decidim/decidim/pull/4794)
- **decidim-initiatives**: Add validation using metadata of authorization for handler defined to validate document mumber [\#4838](https://github.com/decidim/decidim/pull/4838)
- **decidim-initiatives**: Better admin initiative search [\#4845](https://github.com/decidim/decidim/pull/4845)

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
- **decidim-proposals**: Fix Proposals Last Activity feed [\#4828](https://github.com/decidim/decidim/pull/4828)
- **decidim-proposals**: Fix attachments not being inherited from collaborative draft when published as proposal. [\#4811](https://github.com/decidim/decidim/pull/4811)
- **decidim-core**: Add set_locale method to prevent users be redirected to unexpected locale[#4809](https://github.com/decidim/decidim/pull/4809)
- **decidim-core**: Fix inconsistent dataviz [\#4787](https://github.com/decidim/decidim/pull/4787)
- **decidim-proposals**: Fix participatory texts error uploading files with accents and special characters. [\#4788](https://github.com/decidim/decidim/pull/4788)
- **decidim-meetings**: Fix form when duplicating meetings [\#4750](https://github.com/decidim/decidim/pull/4750)
- **decidim-proposals**: Fix admin proposals manager: show proposal state [\#4789](https://github.com/decidim/decidim/pull/4789/)
- **decidim-core**: Fix DataPortabilityExportJob: private method 'file' called when Carrierwave Storage fog enable [#4337](https://github.com/decidim/decidim/pull/4337)
- **decidim-proposals** Public view of Participatory Text is now preserving new lines. [\#4782](https://github.com/decidim/decidim/pull/4782)
- **decidim-assemblies**: Fix assemblies filter by type [\#4778](https://github.com/decidim/decidim/pull/4778)
- **decidim-conferences**: Fix error when visiting a Conference event[\#4776](https://github.com/decidim/decidim/pull/4776)
- **decidim-proposals** Fix unhideable reported collaborative drafts and mail jobs [\#4706](https://github.com/decidim/decidim/pull/4706)
- **decidim-assemblies**: Fix parent assemblies children_count counter [\#4718](https://github.com/decidim/decidim/pull/4718/)
- **decidim-core**: Place `CurrentOrganization` middleware before `WardenManager`. [\#4708](https://github.com/decidim/decidim/pull/4708)
- **decidim-core**: Fix form builder upload field multiple errors display [\#4715](https://github.com/decidim/decidim/pull/4715)
- **decidim-core**: MetricResolver filtering corrected comparison between symbol and string [\#4733](https://github.com/decidim/decidim/pull/4733)
- **decidim-core**: Ignore blank permission options in action authorizer [\#4744](https://github.com/decidim/decidim/pull/4744)
- **decidim-proposals** Lock proposals on voting to avoid race conditions to vote over the limit [\#4763](https://github.com/decidim/decidim/pull/4763)
- **decidim-initiatives** Add missing dependency for wicked_pdf to initiatives module [\#4813](https://github.com/decidim/decidim/pull/4813)
- **decidim-participatory_processes**: Shows the short description on processes when displaying a single one on the homepage. [\#4824](https://github.com/decidim/decidim/pull/4824)
- **decidim-core** Fix redirect to static map view after login. [\#4830](https://github.com/decidim/decidim/pull/4830)
- **decidim-proposals**: Add missing translation key for "Address". [\#4835](https://github.com/decidim/decidim/pull/4835)
- **decidim-proposals**: Fix proposal activity cell rendering. [\#4848](https://github.com/decidim/decidim/pull/4848)

**Removed**:

- **decidim-core**: Remove invite friends by email. [\#4430](https://github.com/decidim/decidim/pull/4430)

## Previous versions

Please check [0.15-stable](https://github.com/decidim/decidim/blob/0.15-stable/CHANGELOG.md) for previous changes.
