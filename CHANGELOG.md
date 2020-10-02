# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

## Upgrade Notes

- **Bump Ruby to v2.6**

As per [\#6320](https://github.com/decidim/decidim/pull/6320) we've bumped the minimum Ruby version to 2.6.6.

- **Stable branches nomenclature changes**

Since this release we're changing the branch nomenclature for stable branches. Until now we were using `x.y-stable`, now we will use `release/x.y-stable`.
Legacy names for stable branches will be kept for a while but won't be created anymore, so new releases won't have the old `x.y-stable` nomenclature.

The plan is to keep new and old nomenclatures until the release of v0.25, so they will coexist until that release.
When releasing v0.25 all stable branches with the nomenclature `x.y-stable` will be removed.

- **Maps**

Maps functionality is now fully configurable. It defaults to HERE Maps as you'd expect when upgrading from an older version and it works still fine with your legacy style geocoder configuration after the update. This is, however, deprecated and it is highly recommended to define your maps configuration with the new style:

```ruby
# Before:
Decidim.configure do |config|
  config.geocoder = {
    static_map_url: "https://image.maps.ls.hereapi.com/mia/1.6/mapview",
    here_api_key: Rails.application.secrets.geocoder[:here_api_key],
    timeout: 5,
    units: :km
  }
end

# After (remember to also update your secrets):
Decidim.configure do |config|
  config.maps = {
    provider: :here,
    api_key: Rails.application.secrets.maps[:api_key],
    static: { url: "https://image.maps.ls.hereapi.com/mia/1.6/mapview" }
  }
  config.geocoder = {
    timeout: 5,
    units: :km
  }
end
```

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

- **Settings `maximum_attachment_size` and `maximum_avatar_size` moved to organization system settings**

As per [\#6377](https://github.com/decidim/decidim/pull/6377), the `maximum_attachment_size` and `maximum_avatar_size` settings will no longer have any effect if configured through the Decidim initializer configurations. Instead, these are now configured from the organization system settings at the `/system` path of your installation.

Note that if you had these previously configured in the initializer, these previous settings have been automatically migrated to all organizations in your installation after running the Decidim upgrade migrations.

### Fixed

- **decidim-comments**: Fix comments JS errors and delays [\#6193](https://github.com/decidim/decidim/pull/6193)
- **decidim-elections**: Improve navigation consistency in the admin zone for elections questions and answers [\#6139](https://github.com/decidim/decidim/pull/6139)
- **decidim-assemblies**, **decidim-core**, **decidim-dev**, **decidim-forms**, **decidim-participatory_processes**, **decidim-proposals**: Fix rubocop errors arising from capybara upgrade [\#6197](https://github.com/decidim/decidim/pull/6197)

### Removed

- **decidim-proposals**: Remove legacy proposal endorsements. [\#5643](https://github.com/decidim/decidim/pull/5643)

## Previous versions

Please check [release/0.22-stable](https://github.com/decidim/decidim/blob/release/0.22-stable/CHANGELOG.md) for previous changes.
