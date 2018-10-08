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

- **decidim-forms**: Create a new gem to hold reusable surveys logic [\#3877](https://github.com/decidim/decidim/pull/3877)

**Changed**:

- **decidim-surveys**: Extract surveys logic to decidim-forms [\#3877](https://github.com/decidim/decidim/pull/3877)
- **decidim-core**: Improve static pages layout and make them groupable by topic. [\#4338](https://github.com/decidim/decidim/pull/4338)

**Fixed**:

- **decidim-proposals**: Allow admins to edit proposals even if creation is not enabled [\#4390](https://github.com/decidim/decidim/pull/4390)
- **decidim-core**: Fix events for polymorphic authors [\#4387](https://github.com/decidim/decidim/pull/4387)
- **decidim-meetings**: Fix order of upcoming meetings [\#4398](https://github.com/decidim/decidim/pull/4398)
- **decidim-core**: Ignore deleted users follows [\#4401](https://github.com/decidim/decidim/pull/4401)
- **decidim-comments**: Fix comment activity cell when commentable is a comment [\#4413](https://github.com/decidim/decidim/pull/4413)
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
- **decidim-proposals**: Fix hashtags on title when showing proposals related. [\4081](https://github.com/decidim/decidim/pull/4081)
- **decidim-core**: Fix hero content block migration [\#4061](https://github.com/decidim/decidim/pull/4061)
- **decidim-core**: Fix default content block creation migration [\#4084](https://github.com/decidim/decidim/pull/4084)
- **decidim-generators**: Bootsnap warnings when generating test applications [\#4098](https://github.com/decidim/decidim/pull/4098)
- **decidim-admin**: Don't list deleted users at officialized list. [\#4139](https://github.com/decidim/decidim/pull/4139)
- **decidim-participayory_processes**: Copy categories and subcategories to the new process. [\#4143](https://github.com/decidim/decidim/pull/4143)
- **decidim-participayory_processes**: Fix Internet Explorer 11 related issues in process filtering. [\#4166](https://github.com/decidim/decidim/pull/4166)
- **decidim-core**: Don't crash when showing the edit link for a component that does not have an admin engine [\#4318](https://github.com/decidim/decidim/pull/4318)
- **decidim-core**: Update conversations on each new message, so conversations list always shows the most recently active one on top [\#4329](https://github.com/decidim/decidim/pull/4329)
- **decidim-core**: Fix newsletter opt-in migration [\#4198](https://github.com/decidim/decidim/pull/4198)
- **decidim-core**: Hide weird flash message [\#4235](https://github.com/decidim/decidim/pull/4235)
- **decidim-core**: Fix newsletter subscription checkbox always being unchecked [\#4238](https://github.com/decidim/decidim/pull/4238)
- **decidim-core**: Don't error when the meeting registrations are updated with invalid data [\#4319](https://github.com/decidim/decidim/pull/4319)
- **decidim-core**: Thread safe locale switching [\#4237](https://github.com/decidim/decidim/pull/4237)
- **decidim-core**: Don't crash when given wrong format at pages [\#4314](https://github.com/decidim/decidim/pull/4314)
- **decidim-initiatives**: Fix initiative search with multiple types [\#4322](https://github.com/decidim/decidim/pull/4322)
- **decidim-debates**: Fix debate search with categories [\4313](https://github.com/decidim/decidim/pull/4313)
- **decidim-proposals**: Fix Endorse button broken if endorse action is authorized. [\#3875](https://github.com/decidim/decidim/pull/3875)
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
- **decidim-admin**: Paginate private users. [\#3871](https://github.com/decidim/decidim/pull/3871)
- **decidim-surveys**: Order survey answer options by date and time. [#3867](https://github.com/decidim/decidim/pull/3867)
- **decidim-core**: Set `organization.tos_version` when creating `terms-and-conditions` DefaultPage [#3911](https://github.com/decidim/decidim/pull/3911)

**Removed**:

## Previous versions

Please check [0.15-stable](https://github.com/decidim/decidim/blob/0.15-stable/CHANGELOG.md) for previous changes.
