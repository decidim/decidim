# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/0.15-stable)

**Fixed**:

- **decidim-meetings**: Fix meetings form when only one locale is available [\#4625](https://github.com/decidim/decidim/pull/4625)
- **decidim-core**: Update Ransack to make it work with Rails 5.2.2 [\#4683](https://github.com/decidim/decidim/pull/4683)

## [0.15.1](https://github.com/decidim/decidim/tree/v0.15.1)

**Fixed**:

- **decidim-meetings**: Change title to description in meetings admin form. [\#4484](https://github.com/decidim/decidim/pull/4484)
- **decidim-meetings**: Fix title and description fields in admin form. [\#4547](https://github.com/decidim/decidim/pull/4547)
- **decidim-proposals**: Fix vote-rerendering on a proposal's page [\#4558](https://github.com/decidim/decidim/pull/4558)
- **decidim-admin**: Fix image updating in content blocks [\#4561](https://github.com/decidim/decidim/pull/4561)
- **decidim-core**: Fix tabs with inputs with invalid characters [\#4561](https://github.com/decidim/decidim/pull/4561)

## [0.15.0](https://github.com/decidim/decidim/tree/v0.15.0)

**Upgrade notes**:

- **Metrics**: See [metrics docs](/docs/advanced/metrics.md)

- **Newsletter OptIn migration**: *Only for upgrades from 0.13 version* With the 0.13 version, User's field `newsletter_notifications_at` could had not been correctly filled for subscribed users with `ChangeNewsletterNotificationTypeValue` migration. To solve it, and in case you have an updated list of old subscribed users, you could execute the following command in Rails console.

```ruby
Decidim::User.where(**search for old subscribed users**).update(newsletter_notifications_at: Time.zone.parse("2018-05-24 00:00 +02:00"))
```

**Added**:

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

- **decidim-assemblies**: Change the not_ceased scope for AssemblyMembers to show them publicly if they have a ceased_date bigger than today [\#4370](https://github.com/decidim/decidim/pull/4370)
- **decidim-assemblies**: For consistency with DB, `ceased_date` and `designation_date` columns now use date attributes in forms, instead of datetime ones. [\#3724](https://github.com/decidim/decidim/pull/3724)
- **decidim-assemblies**: Don't show child assemblies in assemblies general homepage. [\#4239](https://github.com/decidim/decidim/pull/4239)
- **decidim-core**: Allow users to enter datetime fields manually. [\#3724](https://github.com/decidim/decidim/pull/3724)
- **decidim-core**: Allow users to enter date fields manually. [\#3724](https://github.com/decidim/decidim/pull/3724)
- **decidim-core**: Merge Users and UserGroups DB tables [\#4196](https://github.com/decidim/decidim/pull/4196)
- **decidim-core**: Move user group creation to user profile [\#4256](https://github.com/decidim/decidim/pull/4256)
- **decidim-core**: Make authors polymorphic [\#4282](https://github.com/decidim/decidim/pull/4282)
- **decidim-core**: Don't allow weird characters in names and nicknames [\#4317](https://github.com/decidim/decidim/pull/4317)
- **decidim-proposals**: Admins can edit official proposals from the admin as long as they don't have any support [\#4364](https://github.com/decidim/decidim/pull/4364)

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

## Previous versions

Please check [0.14-stable](https://github.com/decidim/decidim/blob/0.14-stable/CHANGELOG.md) for previous changes.
