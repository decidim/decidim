# Change Log

## [0.14.1](https://github.com/decidim/decidim/tree/v0.14.1)

**Upgrade notes**:

- In order for the currently existing Users to be indexed, you'll have to manually trigger a reindex. You can do that executing:

  ```ruby
  Decidim::User.find_each(&:add_to_index_as_search_resource)
  ```

- If you have an external module that defines rake tasks and more than one
  engine, you probably want to add `paths["lib/tasks"] = nil` to all engines but
  the main one, otherwise the tasks you define are probably running multiple
  times unintentionally. Check
  [\#3892](https://github.com/decidim/decidim/pull/3892) for more details.

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

- If you tried to upgrade to `0.14.0` from a previous version, the process might
  have failed during the database migration. If you rolled back the changes and
  have your installation at `v0.13.x` then you can upgrade to `v0.14.1` safely,
  otherwise you'll need to locate a migration called `AddCoreContentBlocks` and
  leave the file looking like this:

  ```ruby
  # frozen_string_literal: true

  class AddCoreContentBlocks < ActiveRecord::Migration[5.2]
    class Organization < ApplicationRecord
      self.table_name = :decidim_organizations
    end

    class ContentBlock < ApplicationRecord
      self.table_name = :decidim_content_blocks
    end

    def change
      default_blocks = [:hero, :sub_hero, :highlighted_content_banner, :how_to_participate, :stats, :footer_sub_hero]

      Organization.pluck(:id).each do |organization_id|
        default_blocks.each_with_index do |manifest_name, index|
          weight = (index + 1) * 10
          ContentBlock.create(
            decidim_organization_id: organization_id,
            weight: weight,
            scope: :homepage,
            manifest_name: manifest_name,
            published_at: Time.current
          )
        end
      end
    end
  end
  ```

  After this change you'll be able to safely migrate your database.

- **Newsletter OptIn migration**: *Only for upgrades from 0.13 version* With the
  0.13 version, User's field `newsletter_notifications_at` could had not been correctly
  filled for subscribed users with `ChangeNewsletterNotificationTypeValue` migration.
  To solve it, and in case you have an updated list of old subscribed users, you could
  execute the following command in Rails console.

   ```ruby
  Decidim::User.where(**search for old subscribed users**).update(newsletter_notifications_at: Time.zone.parse("2018-05-24 00:00 +02:00"))
  ```

**Added**:

- **decidim-proposals**: Apply hashtags to Proposals. [\#3959](https://github.com/decidim/decidim/pull/3959)
- **decidim-core**: Add the functionality of hashtags. [\#3959](https://github.com/decidim/decidim/pull/3959)
- **decidim-assemblies**: Add the posibility to select the parent assembly when the assembly is created or edited [\#4022](https://github.com/decidim/decidim/pull/4022)
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

**Changed**:

- **decidim-docs**: Update the image that shows the proposed life-cycle of a Proposal.[\#3933](https://github.com/decidim/decidim/pull/3933)
- **decidim-initiatives**: For consistency with DB, use Ruby Dates instead of DateTimes, rename `signature_start_time` and `signature_end_time` fields to `signature_start_date` and `signature_end_date`. [\#3932](https://github.com/decidim/decidim/pull/3932)
- **decidim-participatory_processes**: For consistency with DB, use Ruby Dates instead of DateTimes for `start_date` and `end_date`. [\#3932](https://github.com/decidim/decidim/pull/3932)
- **decidim-participatory_processes**: Improve usability of filters on processes index page [\#3728](https://github.com/decidim/decidim/pull/3728)
- **decidim-meetings**: The invite attendee form has been moved to the top of the new invites list. [\#3826](https://github.com/decidim/decidim/pull/3826)
- **decidim-core**: Load authorization modals content with AJAX requests. [\#3753](https://github.com/decidim/decidim/pull/3753)
- **decidim-core**: Updated the `CollapsibleList` cell to be able to show any number of elements from 1 to 12 [\#3810](https://github.com/decidim/decidim/pull/3810)
- **decidim-core**: Move the homepage sections from view hooks to content blocks [\#3839](https://github.com/decidim/decidim/pull/3839)
- **decidim-core**: Move conversations to a profile tab. [\#3960](https://github.com/decidim/decidim/pull/3960)
- **decidim-consultations**: Removed the secondary navbar in the admin sections where it's redundant [\#4015](https://github.com/decidim/decidim/pull/4015)

**Fixed**:

- **decidim-proposals**: Fix hashtags on title when showing proposals related. [\4107](https://github.com/decidim/decidim/pull/4107)
- **decidim-participatory_processes**: Fix hastag display on participatory processes. [\#4024](https://github.com/decidim/decidim/pull/4024)
- **decidim-core**: Fix day date translation on profile notifications. [\#3994](https://github.com/decidim/decidim/pull/3994)
- **decidim-accountability**: Fix accountability progress to be between 0 and 100 if provided. [\#3952](https://github.com/decidim/decidim/pull/3952)
- **decidim-initiatives**: Fix initiative edition when state is not published. [\#3930](https://github.com/decidim/decidim/pull/3930)
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
- **decidim-consultations**: Remove unused indexes from consultations questions. [\#3840](https://github.com/decidim/decidim/pull/3840)
- **decidim-admin**: Paginate private users. [\#3871](https://github.com/decidim/decidim/pull/3871)
- **decidim-surveys**: Order survey answer options by date and time. [#3867](https://github.com/decidim/decidim/pull/3867)
- **decidim-surveys**: Allow deleting surveys components when there are no answers [#4013](https://github.com/decidim/decidim/pull/4013)
- **decidim-proposals**: Proposal creation and update fixes: [\#3744](https://github.com/decidim/decidim/pull/3744)
  - Fix `CookieOverflow` in wizard steps
  - Fix `proposal_length` validation on create_step
  - Fix ability to update proposal attachment
  - Fix `has_address` checked and `address` on invalid form
  - Fix ability to update the proposal's `author/user_group`
- **decidim-proposals**: Hide withdrawn proposals from index [\#4012](https://github.com/decidim/decidim/pull/4012)
- **decidim-comments**: Users should never be notified about their own comments. [\#3888](https://github.com/decidim/decidim/pull/3888)
- **decidim-core**: Consider only users in profile follow counters. [\#3887](https://github.com/decidim/decidim/pull/3887)
- **decidim-accountability**: Fix results string in the home [\#3537](https://github.com/decidim/decidim/pull/3537)
- **decidim-core**: Make API authors optional [\#4014](https://github.com/decidim/decidim/pull/4014)
- **decidim**: Make sure the same task on each decidim module is only loaded once. [\#3890](https://github.com/decidim/decidim/pull/3890)
- **decidim**: Correctly pass cells options to sized card cells [\#4017](https://github.com/decidim/decidim/pull/4017)
- **decidim-initiatives**: Only show initiative types fomr the current tenant [\#3887](https://github.com/decidim/decidim/pull/3887)
- **decidim-core**: Allows users with admin access to preview unpublished components [\#4016](https://github.com/decidim/decidim/pull/4016)
- **decidim-proposals**: Rename "votes" column to "supports" when exporting proposals [\#4018](https://github.com/decidim/decidim/pull/4018)
- **decidim-core**: Fix hero content block migration [\#4061](https://github.com/decidim/decidim/pull/4061)
- **decidim-core**: Fix default content block creation migration [\#4100](https://github.com/decidim/decidim/pull/4100)
- **decidim-core**: Fix default content block creation migration [\#4084](https://github.com/decidim/decidim/pull/4084)
- **decidim-generators**: Bootsnap warnings when generating test applications [\#4098](https://github.com/decidim/decidim/pull/4098)
- **decidim-admin**: Don't list deleted users at officialized list. [\#4203](https://github.com/decidim/decidim/pull/4203)
- **decidim-participayory_processes**: Copy categories and subcategories to the new process. [\#4203](https://github.com/decidim/decidim/pull/4203)
- **decidim-core**: Fix newsletter opt-in migration [\#4198](https://github.com/decidim/decidim/pull/4218)

**Removed**:

## Previous versions

Please check [0.13-stable](https://github.com/decidim/decidim/blob/0.13-stable/CHANGELOG.md) for previous changes.
