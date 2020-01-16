# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

### Upgrade notes

- **Assembly types**

In order to prevent errors while upgrading multi-servers envirnoments, the fields `assembly_type` and `assembly_type_other` are maintained. Future releases will take care of this.

- **Organization Time Zones**

Now is its possible to configure every organization (tenant) with a different time zone by any admin in the global configuration. We recommend to not define any specific `config.time_zone` in Rails so it uses UTC internally. In any case Rails configuration will be ignored in the context of the controller (users will be using always organization's configured time zone).

To upgrade it is recommended to configured the proper time zone in the admin for the organization and remove any `config.time_zone` personalization in Rails (unless you know what you are doing).

For those who have not changed the Rails `config.time_zone` (thus using UTC globally) but using dates as if they were non-UTC zones might notice that changing the organization time zone will shift all presented dates accordingly. This might require to re-edit any scheduled date in meetings or debates in order be properly displayed.

- **Data portability**

Thanks to [#5342](https://github.com/decidim/decidim/pull/5342), Decidim now supports removal of user's data portability expired files from Amazon S3. Check out the [scheduled tasks in the getting started guide](https://github.com/decidim/decidim/blob/master/docs/getting_started.md#scheduled-tasks) for information in how to configure it.

**Added**:

- **decidim-admin**, **decidim-assemblies**, **decidim-conferences**, **decidim-consultations**, **decidim-core**, **decidim-initiatives**, **decidim-participatory_processes**, **decidim-proposals**: Add filters, search and pagination to participatory spaces in admin panel. [\#5558](https://github.com/decidim/decidim/pull/5558)
- **decidim-admin**: Extend search, add pagination and change filters styling to participants/officializations in the admin panel. [\#38](https://github.com/CodiTramuntana/decidim/pull/38)
- **many modules**: Added all spaces and many entities to global search, see Upgrade notes for more detail. [\#5469](https://github.com/decidim/decidim/pull/5469)
- **decidim-core**: Add weight to categories and sort them by that field. [\#5505](https://github.com/decidim/decidim/pull/5505)
- **decidim-proposals**: Add: Additional sorting filters for proposals index. [\#5506](https://github.com/decidim/decidim/pull/5506)
- **decidim-core**: Add a searchable users endpoint to the GraphQL api and enable drop-down @mentions helper in comments. [\#5474](https://github.com/decidim/decidim/pull/5474)
- **decidim-consultations**: Create groups of responses in multi-choices question consultations. [\#5387](https://github.com/decidim/decidim/pull/5387)
- **decidim-core**, **decidim-participatory_processes**: Export/import space components feature, applied to for ParticipatoryProcess. [#5424](https://github.com/decidim/decidim/pull/5424)
- **decidim-participatory_processes**: Export/import feature for ParticipatoryProcess. [#5422](https://github.com/decidim/decidim/pull/5422)
- **decidim-surveys**: Added a setting to surveys to allow unregistered (aka: anonymous) users to answer a survey. [\#4996](https://github.com/decidim/decidim/pull/4996)
- **decidim-core**: Added Devise :lockable to Users [#5478](https://github.com/decidim/decidim/pull/5478)
- **decidim-meetings**: Added help texts for meetings forms to solve doubts about Geocoder fields. [\# #5487](https://github.com/decidim/decidim/pull/5487)
- **decidim-admin** Added per_page option in Admin participant index[#5480](https://github.com/decidim/decidim/pull/5480)

**Changed**:

- **decidim-admin**: Added filters, search and pagination into admin proposals. [\#5503](https://github.com/decidim/decidim/pull/5503)
- **decidim-proposals**: Add a filter "My proposals" at the list of proposals. [\#5512](https://github.com/decidim/decidim/pull/5512)
- **decidim-meetings**: Change: @meetings_spaces collection to use I18n translations [#5494](https://github.com/decidim/decidim/pull/5494)
- **decidim-core**: Add @ prefix to the nickname field in the registration view. [\#5482](https://github.com/decidim/decidim/pull/5482)
- **decidim-core**: Introduce the ActsAsAuthor concern. [\#5482](https://github.com/decidim/decidim/pull/5482)
- **decidim-core**: Extract footers into partials. [#5461](https://github.com/decidim/decidim/pull/5461)
- **decidim-initiatives**: UX improvements to initiatives [#5369](https://github.com/decidim/decidim/pull/5369)
- **decidim-core**: Update to JQuery 3 [#5433](https://github.com/decidim/decidim/pull/5433)

- **decidim-assemblies**: Added configurable assembly types. [\#5616](https://github.com/decidim/decidim/pull/5616)
- **decidim-core**: Added configurable time zones for every tenant (organization). [\#5607](https://github.com/decidim/decidim/pull/5607)
- **decidim-admin**: Display the number of participants subscribed to a newsletter. [\#5555](https://github.com/decidim/decidim/pull/5555)
- **decidim-accountability**, **decidim-admin**, **decidim-budgets**, **decidim-core**, **decidim-debates**, **decidim-generators**, **decidim-meetings**, **decidim-proposals**, **decidim_app-design**: Change: Extend the capabilities of the Quill text editor. [\#5488](https://github.com/decidim/decidim/pull/5488)
- **decidim-core**: Add docs in how to fix metrics problems. [\#5587](https://github.com/decidim/decidim/pull/5587)
- **decidim-core**: Data portability now supports AWS S3 storage. [\#5342](https://github.com/decidim/decidim/pull/5342)

**Changed**:

**Fixed**:

- **decidim-verifications**: Fix: Missing method email_regexp [#5560](https://github.com/decidim/decidim/pull/5560)
- **decidim-core**: Fix: use incrementing date when rebuilding since one date. [\#5541](https://github.com/decidim/decidim/pull/5541)

**Removed**:

## Previous versions

Please check [0.20-stable](https://github.com/decidim/decidim/blob/0.20-stable/CHANGELOG.md) for previous changes.
