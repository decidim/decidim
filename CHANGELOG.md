# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

**Upgrade notes**:

- In order for the newly searchable entities to be indexed, you'll have to manually trigger a reindex. You can do that executing:

  ```ruby
Decidim::Assemblies::Assembly.find_each(&:add_to_index_as_search_resource)
Decidim::ParticipatoryProcesses::ParticipatoryProcess.find_each(&:add_to_index_as_search_resource)
Decidim::Conferences::Conference.find_each(&:add_to_index_as_search_resource)
Decidim::Consultations::Consultation.find_each(&:add_to_index_as_search_resource)
Decidim::Initiatives::Initiative.find_each(&:add_to_index_as_search_resource)
- In order for the newly searchable entities to be indexed, you'll have to manually trigger a reindex. You can do that by running in the rails console:
- **Data portability**

Thanks to [#5342](https://github.com/decidim/decidim/pull/5342), Decidim now supports removal of user's data portability expired files from Amazon S3. Check out the [scheduled tasks in the getting started guide](https://github.com/decidim/decidim/blob/master/docs/getting_started.md#scheduled-tasks) for information in how to configure it.

- **SocialShareButton**

Due to [#5270](https://github.com/decidim/decidim/pull/5270), the SocialShareButton gem [default configuration](https://github.com/CodiTramuntana/decidim/blob/master/decidim-generators/lib/decidim/generators/app_templates/social_share_button.rb) that decidim uses has changed so you'll want to update your configuration accordingly.

- **Decidim::Searchable**

Due to [#5469](https://github.com/decidim/decidim/pull/5469), in order for the newly searchable entities to be indexed, you'll have to manually trigger a reindex. You can do that by running in the rails console:

```ruby
Decidim::Assembly.find_each(&:add_to_index_as_search_resource)
Decidim::ParticipatoryProcess.find_each(&:add_to_index_as_search_resource)
Decidim::Conference.find_each(&:add_to_index_as_search_resource)
Decidim::Consultation.find_each(&:add_to_index_as_search_resource)
Decidim::Initiative.find_each(&:add_to_index_as_search_resource)
Decidim::Debates::Debate.find_each(&:add_to_index_as_search_resource)
# results are ready to be searchable but don't have a card-m so can't be rendered
# Decidim::Accountability::Result.find_each(&:add_to_index_as_search_resource)
Decidim::Budgets::Project.find_each(&:add_to_index_as_search_resource)
Decidim::Blogs::Post.find_each(&:add_to_index_as_search_resource)
  ```
```

**Added**:

- **decidim-core**: Data portability now supports AWS S3 storage. [\#5342](https://github.com/decidim/decidim/pull/5342)
- **decidim-core**: Loofah has deprecated the use of WhiteList in favour of SafeList. [\#5576](https://github.com/decidim/decidim/pull/5576)
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

**Changed**:

**Fixed**:

**Removed**:

## Previous versions

Please check [0.20-stable](https://github.com/decidim/decidim/blob/0.20-stable/CHANGELOG.md) for previous changes.
