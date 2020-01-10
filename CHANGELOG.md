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

**Changed**:

**Fixed**:

**Removed**:

## Previous versions

Please check [0.20-stable](https://github.com/decidim/decidim/blob/0.20-stable/CHANGELOG.md) for previous changes.
