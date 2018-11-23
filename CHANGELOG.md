# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

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

**Added**:

- **decidim-proposals**: Specific public view rendering of participatory texts. [\#4316](https://github.com/decidim/decidim/pull/4316)
- **decidim-proposals**: Admin can create proposals from the admin panel, with a meeting as an author.[\#4382](https://github.com/decidim/decidim/pull/4382)
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

**Changed**:

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

**Fixed**:

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

**Removed**:

- **decidim-core**: Remove invite friends by email. [\#4430](https://github.com/decidim/decidim/pull/4430)

## Previous versions

Please check [0.15-stable](https://github.com/decidim/decidim/blob/0.15-stable/CHANGELOG.md) for previous changes.
