# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

**Upgrade notes**:

- **Metrics**: See [metrics docs](/docs/metrics.md)

**Added**:

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

**Changed**:

- **decidim-assemblies**: For consistency with DB, `ceased_date` and `designation_date` columns now use date attributes in forms, instead of datetime ones. [\#3724](https://github.com/decidim/decidim/pull/3724)
- **decidim-core**: Allow users to enter datetime fields manually. [\#3724](https://github.com/decidim/decidim/pull/3724)
- **decidim-core**: Allow users to enter date fields manually. [\#3724](https://github.com/decidim/decidim/pull/3724)

**Fixed**:

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

**Removed**:

## Previous versions

Please check [0.14-stable](https://github.com/decidim/decidim/blob/0.14-stable/CHANGELOG.md) for previous changes.
