# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

**Upgrade notes**:

**Added**:

- **decidim-assemblies**: Add organizational chart to assemblies home. [\#4045](https://github.com/decidim/decidim/pull/4045)
- **decidim-core**: Adds the *followers* badge. [\#4089](https://github.com/decidim/decidim/pull/4089)
- **decidim-debates**: Adds the *commented debates* badge. [\#4089](https://github.com/decidim/decidim/pull/4089)
- **decidim-meetings**: Add upcoming events content block and page. [\#3987](https://github.com/decidim/decidim/pull/3987)
- **decidim-generators**: Enable one more bootsnap optimization in test apps when coverage tracking is not enabled [\#4098](https://github.com/decidim/decidim/pull/4098)

**Changed**:

- **decidim-assemblies**: For consistency with DB, `ceased_date` and `designation_date` columns now use date attributes in forms, instead of datetime ones. [\#3724](https://github.com/decidim/decidim/pull/3724)
- **decidim-core**: Allow users to enter datetime fields manually. [\#3724](https://github.com/decidim/decidim/pull/3724)
- **decidim-core**: Allow users to enter date fields manually. [\#3724](https://github.com/decidim/decidim/pull/3724)
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

- **decidim-admin**: English locale now uses a consistent date format (UK style everywhere). [\#3724](https://github.com/decidim/decidim/pull/3724)
- **decidim**: Fix crashes when sending incorrectly formatted dates to forms with date fields. [\#3724](https://github.com/decidim/decidim/pull/3724)
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
- **decidim-core**: Make API authors optional [\#4014](https://github.com/decidim/decidim/pull/4014)
- **decidim**: Make sure the same task on each decidim module is only loaded once. [\#3890](https://github.com/decidim/decidim/pull/3890)
- **decidim**: Correctly pass cells options to sized card cells [\#4017](https://github.com/decidim/decidim/pull/4017)
- **decidim-initiatives**: Only show initiative types fomr the current tenant [\#3887](https://github.com/decidim/decidim/pull/3887)
- **decidim-core**: Allows users with admin access to preview unpublished components [\#4016](https://github.com/decidim/decidim/pull/4016)
- **decidim-proposals**: Rename "votes" column to "supports" when exporting proposals [\#4018](https://github.com/decidim/decidim/pull/4018)

**Fixed**:

- **decidim-proposals**: Fix hashtags on title when showing proposals related. [\4081](https://github.com/decidim/decidim/pull/4081)
- **decidim-core**: Fix hero content block migration [\#4061](https://github.com/decidim/decidim/pull/4061)
- **decidim-core**: Fix default content block creation migration [\#4084](https://github.com/decidim/decidim/pull/4084)
- **decidim-generators**: Bootsnap warnings when generating test applications [\#4098](https://github.com/decidim/decidim/pull/4098)

**Removed**:

## Previous versions

Please check [0.14-stable](https://github.com/decidim/decidim/blob/0.14-stable/CHANGELOG.md) for previous changes.
