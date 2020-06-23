# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

### Upgrade notes

- **Endorsements**

The latest version of Decidim extracted the Endorsement feature into a generic concern that can now be applied to many resources.
To keep current Decidim::Proposals::Proposal's endorsement information, endorsements were copied into the new `Decidim::Endorsable` tables and counter cache columns via migrations.

After this, `Decidim::Proposals::ProposalEndorsement` and the corresponding counter cache column in `decidim_proposals_proposal.proposal_endorsements_count` should be removed. To do so, Decidim provides now the corresponding migration.

### Added

- **decidim-core**: Add scroll to last message and apply it on conversations. [\#5718](https://github.com/decidim/decidim/pull/5718)
- **decidim-core**: Allow to restric direct messages to only people followed by the user. [\#5720](https://github.com/decidim/decidim/pull/5720)
- **decidim-comments**: Comments can mention groups and its members are notified. [\#5763](https://github.com/decidim/decidim/pull/5763)
- **decidim-core**: Now messages inside conversations have their urls identified as links. [\#5755](https://github.com/decidim/decidim/pull/5755)
- **decidim-verifications**: Added Verification's Revocation [\#5814](https://github.com/decidim/decidim/pull/5814)
- **decidim-core**: Support node.js semver rules for release candidates. [\#5828](https://github.com/decidim/decidim/pull/5828)
- **decidim-proposals**, **decidim-core**, **decidim-blogs**: Extract proposals' endorsements into a polymorphic concern that can now be applied no any resource. It has, in turn, been aplied to blog posts. [\#5542](https://github.com/decidim/decidim/pull/5542)
- **decidim-proposals**, **decidim-core**, **decidim-blogs**: Apply generalized endorsements to the GraphQL API and add it to the blog posts query. [\#5847](https://github.com/decidim/decidim/pull/5847)
- **decidim-budgets**: Allow projects to be sorted by different criteria [\#5808](https://github.com/decidim/decidim/pull/5808)
- **decidim-budgets**: Request confirmation to exit budgets component [\#5765](https://github.com/decidim/decidim/pull/5765)
- **decidim-admin**: Allow to see a participant's email from the admin panel [\#5849](https://github.com/decidim/decidim/pull/5849)
### Added

- **decidim-elections**: Add import proposals to answers [\6163](https://github.com/decidim/decidim/pull/6163)

### Changed

- **decidim-proposals**: Remove legacy proposal endorsements. [\#5643](https://github.com/decidim/decidim/pull/5643)

### Fixed

- **decidim-comments**: Fix comments JS errors and delays [\#6193](https://github.com/decidim/decidim/pull/6193)
- **decidim-elections**: Improve navigation consistency in the admin zone for elections questions and answers [\#6139](https://github.com/decidim/decidim/pull/6139)
- **decidim-participatory_processes**: Fix rubocop errors arising from capybara upgrade [\#6197](https://github.com/decidim/decidim/pull/6197)
- **decidim-assemblies**: Fix rubocop errors arising from capybara upgrade [\#6197](https://github.com/decidim/decidim/pull/6197)
- **decidim-proposals**: Fix rubocop errors arising from capybara upgrade [\#6197](https://github.com/decidim/decidim/pull/6197)
- **decidim-dev**: Fix rubocop errors arising from capybara upgrade [\#6197](https://github.com/decidim/decidim/pull/6197)
- **decidim-core**: Fix rubocop errors arising from capybara upgrade [\#6197](https://github.com/decidim/decidim/pull/6197)
- **decidim-forms**: Fix rubocop errors arising from capybara upgrade [\#6197](https://github.com/decidim/decidim/pull/6197)

### Removed

## Previous versions

Please check [release/0.22-stable](https://github.com/decidim/decidim/blob/release/0.22-stable/CHANGELOG.md) for previous changes.
