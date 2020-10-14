# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

## Upgrade Notes

- **Bump Ruby to v2.7**

We've bumped the minimum Ruby version to 2.7.1, thanks to 2 PRs:

- [\#6320](https://github.com/decidim/decidim/pull/6320)
- [\#6522](https://github.com/decidim/decidim/pull/6522)

- **Stable branches nomenclature changes**

Since this release we're changing the branch nomenclature for stable branches. Until now we were using `x.y-stable`, now we will use `release/x.y-stable`.
Legacy names for stable branches will be kept for a while but won't be created anymore, so new releases won't have the old `x.y-stable` nomenclature.

The plan is to keep new and old nomenclatures until the release of v0.25, so they will coexist until that release.
When releasing v0.25 all stable branches with the nomenclature `x.y-stable` will be removed.

- **Debates and Comments are now in global search**

Debates and Comments have been added to the global search and need to be
indexed, otherwise all previous content won't be available as search results.
You should run this in a Rails console at your server or create a migration to
do it.

Please be aware that it could take a while if your database has a lot of
content.

```ruby
  Decidim::Comments::Comment.find_each(&:try_update_index_for_search_resource)
  Decidim::Debates::Debate.find_each(&:try_update_index_for_search_resource)
```

### Added

### Changed

### Fixed

### Removed

## Previous versions

Please check [release/0.23-stable](https://github.com/decidim/decidim/blob/release/0.23-stable/CHANGELOG.md) for previous changes.
