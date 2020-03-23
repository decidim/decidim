# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

### Upgrade notes

- **Endorsements**

This new version of Decidim has extracted the Endorsement feature into a generic concern that can now be applied to many resources.
To keep current Decidim::Proposals::Proposal's endorsement information, endorsements are copied into the new `Decidim::Endorsable` tables and counter cache columns. This is done via migrations.

After this, `Decidim::Proposals::ProposalEndorsement` and the corresponding counter cache column in `decidim_proposals_proposal.proposal_endorsements_count` should be removed. To do so, Decidim will provide the corresponding migration in the next release.

### Added

- **decidim-core**: Set email asset host dynamically. [\#5888](https://github.com/decidim/decidim/pull/5888)
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
### Changed

### Fixed

- **decidim-proposals**: Fix relative path in mentioned proposal email [\#5852](https://github.com/decidim/decidim/pull/5852)
- **decidim-proposals**: Use simple_format to add a wrapper to proposals body [\#5753](https://github.com/decidim/decidim/pull/5753)
- **decidim-sortitions**: Fix incorrect proposals sortition. [\#5620](https://github.com/decidim/decidim/pull/5620)
- **decidim-admin**: Fix: let components without step settings be added [\#5568](https://github.com/decidim/decidim/pull/5568)
- **decidim-proposals**: Fix proposals that have their state not published [\#5832](https://github.com/decidim/decidim/pull/5832)
- **decidim-core**: Fix missing tribute source map [\#5869](https://github.com/decidim/decidim/pull/5869)

### Removed

### Previous versions

Please check [0.21-stable](https://github.com/decidim/decidim/blob/0.21-stable/CHANGELOG.md) for previous changes.
