# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

DEPRECATION NOTE: The `description` field in the categories admin forms has been removed (this applies to any participatory space using categories). For now it's still available in the database, so you can extract it with the following command in the Rails console:

```ruby
Decidim::Category.pluck(:id, :name, :description) 
```

In the next version (v0.28.0) it will be fully removed from the database.

### Added

### Changed

### Fixed

### Removed

## Previous versions

Please check [release/0.26-stable](https://github.com/decidim/decidim/blob/release/0.26-stable/CHANGELOG.md) for previous changes.

