# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

**Upgrade notes**:

- In order for the currently existing Users to be indexed, you'll have to manually trigger a reindex. You can do that executing:

  ```ruby
  Decidim::User.find_each(&:add_to_index_as_search_resource)
  ```

- If you have an external module that defines rake tasks and more than one
  engine, you probably want to add `paths["lib/tasks"] = nil` to all engines but
  the main one, otherwise the tasks you define are probably running multiple
  times unintentionally. Check
  [\#3890](https://github.com/decidim/decidim/pull/3890) for more details.

- Image compression settings :
  The quality settings can be set in Decidim initializer with
  `Decidim.config.image_uploader_quality = 60`
  The quality setting is set to 80 by default because change is imperceptible.
  My own test show that a quality between 60 and 80 is optimal.
  You can use this feature with already uploded images,
  it only affect newly uploaded file.
  If you want to apply new settings to previouysly uploaded images :
  - open `rails console`
  - Type the following :

  ```ruby

  YourModel.find_each { |x| x.image.recreate_versions! if x.image? }

  ```

  Where YourModel is the name of your model (eg. Decidim::User) and
  image is the name of your uploader (eg. avatar).
  As Decidim doesn't keep original file on upload, a file cannot be
  restored to original quality without re-uploading.
  Be careful when playing with this feature on production.
  Check [\#3984](https://github.com/decidim/decidim/pull/3984) for more details.

- **Badges**: Badges are introduced in the `0.14` as a way to add gamification and
  increase the amount of user interaction. In order to generate the scores of all
  the badges, please run an IRB session via `rails console` and execute:

  ```ruby
  Decidim::Gamification.reset_badges
  ```

- **Metrics**: See [metrics docs](/docs/metrics.md)

**Added**:

- **decidim-admin**:Add link to user profile and link to conversation from admin space. [\#3995](https://github.com/decidim/decidim/pull/3995)
- **decidim-core**:Add compression settings to image uploader [\#3984](https://github.com/decidim/decidim/pull/3984)
- **decidim-budgets**: Import accepted proposals to projects. [\#3873](https://github.com/decidim/decidim/pull/3873)
- **decidim-proposals**: Results from searches should show the participatory space where they belong to if any. [\#3897](https://github.com/decidim/decidim/pull/3897)
- **decidim-docs**: Add proposal lifecycle diagram to docs. [\#3811](https://github.com/decidim/decidim/pull/3811)
- **decidim-budgets**: Added vote project authorization action [\#3804](https://github.com/decidim/decidim/pull/3804)
- **decidim-meetings**: Added join meeting authorization action [\#3804](https://github.com/decidim/decidim/pull/3804)
- **decidim-proposals**: Added vote and endorse proposal authorization actions [\#3804](https://github.com/decidim/decidim/pull/3804)
- **decidim-core**: Support for actions authorizations at resource level [\#3804](https://github.com/decidim/decidim/pull/3804)
- **decidim-meetings**: Allow users to accept or reject invitations to meetings, and allow admins to see their status. [\#3632](https://github.com/decidim/decidim/pull/3632)
- **decidim-meetings**: Allow admins to invite existing users to meetings. [\#3831](https://github.com/decidim/decidim/pull/3831)
- **decidim-meetings**: Generate a registration code and give it to users when they join to the meeting. [\#3805](https://github.com/decidim/decidim/pull/3805)
- **decidim-meetings**: Allow admins to validate meeting registration codes and notify the user. [\#3833](https://github.com/decidim/decidim/pull/3833)
- **decidim-core**: Make Users Searchable. [\#3796](https://github.com/decidim/decidim/pull/3796)
- **decidim-participatory_processes**: Highlight the correct menu item when visiting a process group page [\#3737](https://github.com/decidim/decidim/pull/3737)
- **decidim-core**: Added metrics visualization for Users and Proposals (all, accepted and votes) [\#3603](https://github.com/decidim/decidim/pull/3603)
- **decidim-proposals**: Add Collaborative drafts: [\#3109](https://github.com/decidim/decidim/pull/3109)
  - Admin can en/disable this feature from the component configuration
  - Filtrable list of Collaborative drafts in public views
  - Collaborative drafts are: traceable, commentable, coauthorable, reportable
  - Publish collaborative draft as Proposal
- **decidim-participatory_processes**: Display a big card when there's just one process at the homepage [\#3970](https://github.com/decidim/decidim/pull/3970)
- **decidim-core**: Adds support for earning badges. [\#3975](https://github.com/decidim/decidim/pull/3975)
- **decidim-proposals**: Adds the *proposal* badge. [\#3975](https://github.com/decidim/decidim/pull/3975)
- **decidim-proposals**: Adds the *proposal supports* badge. [\#4033](https://github.com/decidim/decidim/pull/4033)
- **decidim-proposals**: Adds the *accepted proposals* badge. [\#4033](https://github.com/decidim/decidim/pull/4033)
- **decidim-core**: Adds the *invitations* badge. [\#4033](https://github.com/decidim/decidim/pull/4033)
- **decidim-initiatives**: Adds the *published initiatives* badge. [\#4033](https://github.com/decidim/decidim/pull/4033)
- **decidim-core**: Add link to admin edit from public pages. [\#3978](https://github.com/decidim/decidim/pull/3978)

**Added**:

- **decidim-conferences**: Added Conferences as a Participatory Space. This module is a configurator and generator of Conference pages, understood as a collection of Meeting. [\#3781](https://github.com/decidim/decidim/pull/3781)
- **decidim-meetings**: Apply hashtags to meetings [\#4080](https://github.com/decidim/decidim/pull/4080)
- **decidim-assemblies**: Add organizational chart to assemblies home. [\#4045](https://github.com/decidim/decidim/pull/4045)
- **decidim-core**: Adds the *followers* badge. [\#4089](https://github.com/decidim/decidim/pull/4089)
- **decidim-debates**: Adds the *commented debates* badge. [\#4089](https://github.com/decidim/decidim/pull/4089)
- **decidim-meetings**: Add upcoming events content block and page. [\#3987](https://github.com/decidim/decidim/pull/3987)
- **decidim-generators**: Enable one more bootsnap optimization in test apps when coverage tracking is not enabled [\#4098](https://github.com/decidim/decidim/pull/4098)
- **decidim-initiatives**: Initiative printable form now includes the initiative type. [\#3938](https://github.com/decidim/decidim/pull/3938)

**Changed**:

- **decidim-assemblies**: For consistency with DB, `ceased_date` and `designation_date` columns now use date attributes in forms, instead of datetime ones. [\#3724](https://github.com/decidim/decidim/pull/3724)
- **decidim-core**: Allow users to enter datetime fields manually. [\#3724](https://github.com/decidim/decidim/pull/3724)
- **decidim-core**: Allow users to enter date fields manually. [\#3724](https://github.com/decidim/decidim/pull/3724)

**Fixed**:

- **decidim-debates**: Fix create debates as a normal user in a private space [\4108](https://github.com/decidim/decidim/pull/4108)
- **decidim-admin**: English locale now uses a consistent date format (UK style everywhere). [\#3724](https://github.com/decidim/decidim/pull/3724)
- **decidim**: Fix crashes when sending incorrectly formatted dates to forms with date fields. [\#3724](https://github.com/decidim/decidim/pull/3724)
- **decidim-proposals**: Fix hashtags on title when showing proposals related. [\4081](https://github.com/decidim/decidim/pull/4081)
- **decidim-core**: Fix hero content block migration [\#4061](https://github.com/decidim/decidim/pull/4061)
- **decidim-core**: Fix default content block creation migration [\#4084](https://github.com/decidim/decidim/pull/4084)
- **decidim-generators**: Bootsnap warnings when generating test applications [\#4098](https://github.com/decidim/decidim/pull/4098)

**Removed**:

## Previous versions

Please check [0.14-stable](https://github.com/decidim/decidim/blob/0.14-stable/CHANGELOG.md) for previous changes.
