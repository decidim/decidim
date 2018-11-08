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

- **decidim-conferences**: Add conference registration types. [\#4408](https://github.com/decidim/decidim/pull/4408)
- **decidim-forms**: Create a new gem to hold reusable surveys logic [\#3877](https://github.com/decidim/decidim/pull/3877)
- **decidim-verifications**: Add SMS verification workflow [\#4429](https://github.com/decidim/decidim/pull/4429)
- **decidim-proposals**: Split & merge proposals to the same component [\#4415](https://github.com/decidim/decidim/pull/4415)
- **decidim-core**: Adds the ability to send a welcome notification to new users [#4432](https://github.com/decidim/decidim/pull/4432)
- **decidim-meetings**: Add a meetings calendar at organization and component levels [\#4376](https://github.com/decidim/decidim/pull/4376)

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
