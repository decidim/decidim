# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

**Upgrade notes**:

- **Data portability**

Thanks to [#5342](https://github.com/decidim/decidim/pull/5342), Decidim now supports removal of user's data portability expired files from Amazon S3. Check out the [scheduled tasks in the getting started guide](https://github.com/decidim/decidim/blob/master/docs/getting_started.md#scheduled-tasks) for information in how to configure it.

**Added**:

- **decidim-admin**: Display the number of participants subscribed to a newsletter. [\#5555](https://github.com/decidim/decidim/pull/5555)
- **decidim-core**: Loofah has deprecated the use of WhiteList in favour of SafeList. [\#5576](https://github.com/decidim/decidim/pull/5576)
- **decidim-proposals, decidim-debates and decidim-initiatives**: Added all spaces and many entities to global search, see Upgrade notes for more detail. [\#5469](https://github.com/decidim/decidim/pull/5469)
- **decidim-core**: Add weight to categories and sort them by that field. [\#5505](https://github.com/decidim/decidim/pull/5505)
- **decidim-proposals**: Add: Additional sorting filters for proposals index. [\#5506](https://github.com/decidim/decidim/pull/5506)
- **decidim-core**: Add a searchable users endpoint to the GraphQL api and enable drop-down @mentions helper in comments. [\#5474](https://github.com/decidim/decidim/pull/5474)
- **decidim-consultations**: Create groups of responses in multi-choices question consultations. [\#5387](https://github.com/decidim/decidim/pull/5387)
- **decidim-core**, **decidim-participatory_processes**: Export/import space components feature, applied to for ParticipatoryProcess. [#5424](https://github.com/decidim/decidim/pull/5424)
- **decidim-participatory_processes**: Export/import feature for ParticipatoryProcess. [#5422](https://github.com/decidim/decidim/pull/5422)
- **decidim-surveys**: Added a setting to surveys to allow unregistered (aka: anonymous) users to answer a survey. [\#4996](https://github.com/decidim/decidim/pull/4996)
- **decidim-core**: Added Devise :lockable to Users [#5478](https://github.com/decidim/decidim/pull/5478)
- **decidim-meetings**: Added help texts for meetings forms to solve doubts about Geocoder fields. [\# #5487](https://github.com/decidim/decidim/pull/5487)
- **decidim-core**: Add docs in how to fix metrics problems. [\#5587](https://github.com/decidim/decidim/pull/5587)
- **decidim-core**: Data portability now supports AWS S3 storage. [\#5342](https://github.com/decidim/decidim/pull/5342)

**Changed**:

**Fixed**:

**Removed**:

## Previous versions

Please check [0.20-stable](https://github.com/decidim/decidim/blob/0.20-stable/CHANGELOG.md) for previous changes.
