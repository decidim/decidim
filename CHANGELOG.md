# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

### Upgrade notes

- **Endorsements**

This new version of Decidim has extracted the Endorsement feature into a generic concern that can now be applied to many resources.
To keep current Decidim::Proposals::Proposal's endorsement information, endorsements are copied into the new `Decidim::Endorsable` tables and counter cache columns. This is done via migrations.

After this, `Decidim::Proposals::ProposalEndorsement` and the corresponding counter cache column in `decidim_proposals_proposal.proposal_endorsements_count` should be removed. To do so, Decidim will provide the corresponding migration in the next release.

- **decidim-forms**: New question type "Matrix" [\5876](https://github.com/decidim/decidim/pull/5876)
- **decidim-proposals**: Add images to proposal cards [\#5640](https://github.com/decidim/decidim/pull/5640)
- **decidim-api**: Added documentation to use the API (newcomers friendly). [\#5582](https://github.com/decidim/decidim/pull/5582)
- **decidim-blogs**: GraphQL API: Complete Blogs specification. [\#5569](https://github.com/decidim/decidim/pull/5569)
- **decidim-debates**: GraphQL API: Complete Debates specification. [\#5570](https://github.com/decidim/decidim/pull/5570)
- **decidim-surveys**: GraphQL API: Complete Surveys specification. [\#5571](https://github.com/decidim/decidim/pull/5571)
- **decidim-sortitions**: GraphQL API: Complete Sortitions specification. [\#5583](https://github.com/decidim/decidim/pull/5583)
- **decidim-accountability**: GraphQL API: Complete Accountability specification. [\#5584](https://github.com/decidim/decidim/pull/5584)
- **decidim-budgets**: GraphQL API: Complete Budgets specification. [\#5585](https://github.com/decidim/decidim/pull/5585)
- **decidim-assemblies**: GraphQL API: Create fields for assemblies types and specs. [\#5544](https://github.com/decidim/decidim/pull/5544)
- **decidim-core**: Add search and order capabilities to the GraphQL API. [\#5586](https://github.com/decidim/decidim/pull/5586)
- **documentation**: Added documentation in how Etherpad Lite integrates with the Meetings component. [\#5652](https://github.com/decidim/decidim/pull/5652)
- **decidim-meetings**: GraphQL API: Complete Meetings specification. [\#5563](https://github.com/decidim/decidim/pull/5563)
- **decidim-meetings**: Follow a meeting on registration [\#5615](https://github.com/decidim/decidim/pull/5615)
- **decidim-admin**, **decidim-assemblies**, **decidim-conferences**, **decidim-consultations**, **decidim-core**, **decidim-initiatives**, **decidim-participatory_processes**, **decidim-proposals**: Add filters, search and pagination to participatory spaces in admin panel. [\#5558](https://github.com/decidim/decidim/pull/5558)
- **decidim-admin**: Extend search, add pagination and change filters styling to participants/officializations in the admin panel. [\#5558](https://github.com/CodiTramuntana/decidim/pull/5558)
- **decidim-admin**: Added filters, search and pagination into admin proposals. [\#5503](https://github.com/decidim/decidim/pull/5503)
- **decidim-consultations**: GraphQL API: Create fields for consultations types and specs. [\#5550](https://github.com/decidim/decidim/pull/5550)
- **decidim-conferences**: GraphQL API: Create fields for conferences types and specs. [\#5551](https://github.com/decidim/decidim/pull/5551)
- **decidim-initiatives**: GraphQL API: Create fields for initiatives types and specs. [\#5544](https://github.com/decidim/decidim/pull/5549)
- **decidim-proposals**: GraphQL API: Complete Proposals specification. [\#5537](https://github.com/decidim/decidim/pull/5537)
- **decidim-participatory_processes**: GraphQL API: Add participatory process groups specification. [\#5540](https://github.com/decidim/decidim/pull/5540)
- **decidim-participatory_processes**: GraphQL API: Complete fields for participatory processes. [\#5562](https://github.com/decidim/decidim/pull/5562)
- **decidim-admin** Add terms of use for admin. [#5507](https://github.com/decidim/decidim/pull/5507)
- **decidim-assemblies**: Added configurable assembly types. [\#5616](https://github.com/decidim/decidim/pull/5616)
- **decidim-core**: Added configurable time zones for every tenant (organization). [\#5607](https://github.com/decidim/decidim/pull/5607)
- **decidim-admin**: Display the number of participants subscribed to a newsletter. [\#5555](https://github.com/decidim/decidim/pull/5555)
- **decidim-accountability**, **decidim-admin**, **decidim-budgets**, **decidim-core**, **decidim-debates**, **decidim-generators**, **decidim-meetings**, **decidim-proposals**, **decidim_app-design**: Change: Extend the capabilities of the Quill text editor. [\#5488](https://github.com/decidim/decidim/pull/5488)
- **decidim-core**: Add docs in how to fix metrics problems. [\#5587](https://github.com/decidim/decidim/pull/5587)
- **decidim-core**: Data portability now supports AWS S3 storage. [\#5342](https://github.com/decidim/decidim/pull/5342)
- **decidim-system**: Permit customizing omniauth settings for each tenant [#5516](https://github.com/decidim/decidim/pull/5516)
- **decidim-core**: Add the `nofollow` value to the `rel` attribute on parsed links [\#5651](https://github.com/decidim/decidim/pull/5651)
- **decidim-proposals**: Allow admins to set a predefined template [\#5613](https://github.com/decidim/decidim/pull/5613)
- **decidim-comments**: Let users check a single comment in a commentable resource [#5662](https://github.com/decidim/decidim/pull/5662)
- **decidim-participatory-processes**: Link processes and only show published ones [#5676](https://github.com/decidim/decidim/pull/5676)
- **decidim-proposals**: Automatically link proposals and meetings when creating a proposal authored by a meeting [\#5674](https://github.com/decidim/decidim/pull/5674)
- **decidim-proposals**: Add proposal page with all info in admin section [\#5671](https://github.com/decidim/decidim/pull/5671)
- **decidim-proposals** and **decidim-budgets**: Improve navigation and visualization of proposals and projects by scope, category, origin and status [\#5654](https://github.com/decidim/decidim/pull/5654)
- **decidim-proposals**: Let admins add cost reports to proposals [\#5695](https://github.com/decidim/decidim/pull/5695)
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
