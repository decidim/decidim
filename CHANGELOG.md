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

### Added

### Changed

### Fixed

- **decidim-comments**: Fix comments JS errors and delays [\#6193](https://github.com/decidim/decidim/pull/6193)
- **decidim-elections**: Improve navigation consistency in the admin zone for elections questions and answers [\#6139](https://github.com/decidim/decidim/pull/6139)
- **decidim-assemblies**, **decidim-core**, **decidim-dev**, **decidim-forms**, **decidim-participatory_processes**, **decidim-proposals**: Fix rubocop errors arising from capybara upgrade [\#6197](https://github.com/decidim/decidim/pull/6197)

### Removed

- **decidim-proposals**: Remove legacy proposal endorsements. [\#5643](https://github.com/decidim/decidim/pull/5643)

## Previous versions

Please check [release/0.22-stable](https://github.com/decidim/decidim/blob/release/0.22-stable/CHANGELOG.md) for previous changes.
