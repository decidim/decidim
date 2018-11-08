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

- **decidim-proposals**: Add support to import .odt participatory text files. [\#4386](https://github.com/decidim/decidim/pull/4386)
- **decidim-proposals**: Admin can create proposals from the admin panel, with a meeting as an author.[\#4382](https://github.com/decidim/decidim/pull/4382)
- **decidim-conferences**: Add conference registration types. [\#4408](https://github.com/decidim/decidim/pull/4408)
- **decidim-forms**: Create a new gem to hold reusable surveys logic [\#3877](https://github.com/decidim/decidim/pull/3877)
- **decidim-meetings**: Allow admins to activate a registration form to be answered by the user when they joins for the meeting [\#4419](https://github.com/decidim/decidim/pull/4419)
- **decidim-verifications**: Add SMS verification workflow [\#4429](https://github.com/decidim/decidim/pull/4429)
- **decidim-proposals**: Split & merge proposals to the same component [\#4415](https://github.com/decidim/decidim/pull/4415)
- **decidim-core**: Adds the ability to send a welcome notification to new users [#4432](https://github.com/decidim/decidim/pull/4432)
- **decidim-meetings**: Add a meetings calendar at organization and component levels [\#4376](https://github.com/decidim/decidim/pull/4376)
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

**Changed**:

- **decidim-core**: Improve static pages layout and make them groupable by topic. [\#4338](https://github.com/decidim/decidim/pull/4338)
- **decidim-surveys**: Extract surveys logic to decidim-forms [\#3877](https://github.com/decidim/decidim/pull/3877)

**Fixed**:

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

**Removed**:

- **decidim-core**: Remove invite friends by email. [\#4430](https://github.com/decidim/decidim/pull/4430)

## Previous versions

Please check [0.15-stable](https://github.com/decidim/decidim/blob/0.15-stable/CHANGELOG.md) for previous changes.
