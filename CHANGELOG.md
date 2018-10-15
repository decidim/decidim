# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

**Upgrade notes**:

- **Metrics**: See [metrics docs](/docs/metrics.md)

- **Newsletter OptIn migration**: *Only for upgrades from 0.13 version* With the 0.13 version, User's field `newsletter_notifications_at` could had not been correctly filled for subscribed users with `ChangeNewsletterNotificationTypeValue` migration. To solve it, and in case you have an updated list of old subscribed users, you could execute the following command in Rails console.

```ruby
Decidim::User.where(**search for old subscribed users**).update(newsletter_notifications_at: Time.zone.parse("2018-05-24 00:00 +02:00"))
```

**Added**:

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

**Changed**:

- **decidim-assemblies**: For consistency with DB, `ceased_date` and `designation_date` columns now use date attributes in forms, instead of datetime ones. [\#3724](https://github.com/decidim/decidim/pull/3724)
- **decidim-assemblies**: Don't show child assemblies in assemblies general homepage. [\#4239](https://github.com/decidim/decidim/pull/4239)
- **decidim-core**: Allow users to enter datetime fields manually. [\#3724](https://github.com/decidim/decidim/pull/3724)
- **decidim-core**: Allow users to enter date fields manually. [\#3724](https://github.com/decidim/decidim/pull/3724)
- **decidim-core**: Merge Users and UserGroups DB tables [\#4196](https://github.com/decidim/decidim/pull/4196)
- **decidim-core**: Move user group creation to user profile [\#4256](https://github.com/decidim/decidim/pull/4256)

**Fixed**:

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
- **decidim-core**: Fix newsletter opt-in migration [\#4198](https://github.com/decidim/decidim/pull/4198)
- **decidim-core**: Hide weird flash message [\#4235](https://github.com/decidim/decidim/pull/4235)
- **decidim-core**: Fix newsletter subscription checkbox always being unchecked [\#4238](https://github.com/decidim/decidim/pull/4238)
- **decidim-core**: Thread safe locale switching [\#4237](https://github.com/decidim/decidim/pull/4237)

**Removed**:

## Previous versions

Please check [0.14-stable](https://github.com/decidim/decidim/blob/0.14-stable/CHANGELOG.md) for previous changes.
