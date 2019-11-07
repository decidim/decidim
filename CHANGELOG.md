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
Decidim::Debates::Debate.find_each(&:add_to_index_as_search_resource)
Decidim::Accountability::Result.find_each(&:add_to_index_as_search_resource)
  ```

**Added**:

- **decidim-consultations**: Create groups of responses in multi-choices question consultations. [\#5387](https://github.com/decidim/decidim/pull/5387)
- **decidim-core**, **decidim-participatory_processes**: Export/import space components feature, applied to for ParticipatoryProcess. [#5424](https://github.com/decidim/decidim/pull/5424)
- **decidim-participatory_processes**: Export/import feature for ParticipatoryProcess. [#5422](https://github.com/decidim/decidim/pull/5422)
- **decidim-surveys**: Added a setting to surveys to allow unregistered (aka: anonymous) users to answer a survey. [\#4996](https://github.com/decidim/decidim/pull/4996)

**Changed**:

- **decidim-core**: Extract footers into partials. [#5461](https://github.com/decidim/decidim/pull/5461)
- **decidim-initiatives**: UX improvements to initiatives [#5369](https://github.com/decidim/decidim/pull/5369)
- **decidim-core**: Update to JQuery 3 [#5433](https://github.com/decidim/decidim/pull/5433)

**Fixed**:

- **decidim-participatory_processes**: Fix: flaky test when mapping Rails timezone names to PostgreSQL [\#5472](https://github.com/decidim/decidim/pull/5472)
- **decidim-conferences**: Fix: Add pagination interface to some sections [\#5463](https://github.com/decidim/decidim/pull/5463)
- **decidim-sortitions**: Fix: Don't include drafts in sortitions [\#5434](https://github.com/decidim/decidim/pull/5434)
- **decidim-assemblies**: Fix: Fixed assembly parent_id when selecting itself [#5416](https://github.com/decidim/decidim/pull/5416)

**Removed**:

## Previous versions

Please check [0.19-stable](https://github.com/decidim/decidim/blob/0.19-stable/CHANGELOG.md) for previous changes.
