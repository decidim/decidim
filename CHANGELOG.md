# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

## Upgrade Notes

- **Stable branches nomenclature changes**

Since this release we're changing the branch nomenclature for stable branches. Until now we were using `x.y-stable`, now we will use `release/x.y-stable`.
Legacy names for stable branches will be kept for a while but won't be created anymore, so new releases won't have the old `x.y-stable` nomenclature.

The plan is to keep new and old nomenclatures until the release of v0.25, so they will coexist until that release.
When releasing v0.25 all stable branches with the nomenclature `x.y-stable` will be removed.

- **Endorsements**

The latest version of Decidim extracted the Endorsement feature into a generic concern that can now be applied to many resources.
To keep current Decidim::Proposals::Proposal's endorsement information, endorsements were copied into the new `Decidim::Endorsable` tables and counter cache columns via migrations.

After this, `Decidim::Proposals::ProposalEndorsement` and the corresponding counter cache column in `decidim_proposals_proposal.proposal_endorsements_count` should be removed. To do so, Decidim provides now the corresponding migration.

- **Removal of Surveys' legacy tables**

This version removes the legacy tables that were left when extracting Questionnaires from `decidim-surveys` into `decidim-forms`.
These tables were left to give time to Decidim imlementors to migrate the data in them if required.
It is now time to remove these tables but, as stated in [\#6275](https://github.com/decidim/decidim/issues/6275), the process must avoid data loss.

To avoid data loss migration `decidim-surveys/db/migrate/20200609090533_check_legacy_tables.rb` checks if there is still data in `decidim-surveys` legacy tables and migrates this data to the tables in `decidim-forms`.

After 20200609090533 is executed the next 5 migrations will remove the legacy tables and columns.

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