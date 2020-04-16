# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

### Upgrade notes

- **Endorsements**

This new version of Decidim has extracted the Endorsement feature into a generic concern that can now be applied to many resources.
To keep current Decidim::Proposals::Proposal's endorsement information, endorsements are copied into the new `Decidim::Endorsable` tables and counter cache columns. This is done via migrations.

After this, `Decidim::Proposals::ProposalEndorsement` and the corresponding counter cache column in `decidim_proposals_proposal.proposal_endorsements_count` should be removed. To do so, Decidim will provide the corresponding migration in the next release.

- **Data portability**

Thanks to [#5342](https://github.com/decidim/decidim/pull/5342), Decidim now supports removal of user's data portability expired files from Amazon S3. Check out the [scheduled tasks in the getting started guide](https://github.com/decidim/decidim/blob/master/docs/getting_started.md#scheduled-tasks) for information in how to configure it.

- **SSL is forced on by default**

Due to [\#5553](https://github.com/decidim/decidim/pull/5553), SSL is turned on by default.

### Added

- **decidim-core**: Allow users to register with a preferred language. [\#5789](https://github.com/decidim/decidim/pull/5789)
- **decidim-dev**: Retry failed test to avoid flaky. [\#5894](https://github.com/decidim/decidim/pull/5894)
- **decidim-core**: Add scroll to last message and apply it on conversations. [\#5718](https://github.com/decidim/decidim/pull/5718)
- **decidim-core**: Allow to restric direct messages to only people followed by the user. [\#5720](https://github.com/decidim/decidim/pull/5720)
- **decidim-comments**: Comments can mention groups and its members are notified. [\#5763](https://github.com/decidim/decidim/pull/5763)
- **decidim-core**: Now messages inside conversations have their urls identified as links. [\#5755](https://github.com/decidim/decidim/pull/5755)
- **decidim-verifications**: Added Verification's Revocation [\#5814](https://github.com/decidim/decidim/pull/5814)
- **decidim-core**: Support node.js semver rules for release candidates. [\#5828](https://github.com/decidim/decidim/pull/5828)
- **decidim-proposals**, **decidim-core**, **decidim-blogs**: Extract proposals' endorsements into a polymorphic concern that can now be applied no any resource. It has, in turn, been aplied to blog posts. [\#5542](https://github.com/decidim/decidim/pull/5542)
- **decidim-proposals**, **decidim-core**, **decidim-blogs**: Apply generalized endorsements to the GraphQL API and add it to the blog posts query. [\#5847](https://github.com/decidim/decidim/pull/5847)
- **decidim-core**: Allow users to have private conversations with more than one participant. [\#5861](https://github.com/decidim/decidim/pull/5861)
- **decidim-budgets**: Allow projects to be sorted by different criteria [\#5808](https://github.com/decidim/decidim/pull/5808)
- **decidim-budgets**: Request confirmation to exit budgets component [\#5765](https://github.com/decidim/decidim/pull/5765)
- **decidim-budgets**: Add minimum projects rule to Budgets [/#5865](https://github.com/decidim/decidim/pull/5865)

- **decidim-admin**: Allow to see a participant's email from the admin panel [\#5849](https://github.com/decidim/decidim/pull/5849)
- **decidim**: Add missing indexs on foreign keys on the DB [\#5885](https://github.com/decidim/decidim/pull/5885)
- **decidim-core**: Redesign activity cards for the home page [#5672](https://github.com/decidim/decidim/pull/5672)
- **decidim-core**: Redesign activity cards on Timeline and Activity Tabs for a consistent user experience [#5779](https://github.com/decidim/decidim/issues/5779)
- **decidim-proposals**: Update rspec proposal_activity_cell_spec to check existence of card__content css class instead of car-data css class [#5779](https://github.com/decidim/decidim/issues/5779)
- **decidim-comments**: Update rspec comment_activity_cell_spec to check existence of card__content css class instead of car-data css class[#5779](https://github.com/decidim/decidim/issues/5779)
- **decidim-core**: Fix clearing the current_user after sign out [#5823](https://github.com/decidim/decidim/pull/5823)

### Changed

- **decidim-assemblies**: Replace current meetings hook with highlighted elements hook [\#5897](https://github.com/decidim/decidim/pull/5897)
- **decidim-core**: Change the map marker color to the Decidim primary color [\#5870](https://github.com/decidim/decidim/pull/5870)
- **decidim-core**: Add whitespace: nowrap style to compact buttons. [\#5891](https://github.com/decidim/decidim/pull/5891)

### Fixed

- **decidim-core**: Fix supported versions in SECURITY.md file. [\#5957](https://github.com/decidim/decidim/pull/5957)
- **decidim-debates**: Fix a notification failure when the creating a new debate event is fired. [\#5964](https://github.com/decidim/decidim/pull/5964)
- **decidim-proposals**: Fix a migration failure when generalizing proposal endorsements. [\#5953](https://github.com/decidim/decidim/pull/5953)
- **decidim-assemblies**: Fix parent-child loophole when setting a child as and parent and making assemblies disappear. [\#5807](https://github.com/decidim/decidim/pull/5807)
- **decidim-forms**: Fixes a performance degradation when displaying forms in surveys. [\#5819](https://github.com/decidim/decidim/pull/5819)
- **decidim-proposals**: Fix relative path in mentioned proposal email [\#5852](https://github.com/decidim/decidim/pull/5852)
- **decidim-proposals**: Use simple_format to add a wrapper to proposals body [\#5753](https://github.com/decidim/decidim/pull/5753)
- **decidim-sortitions**: Fix incorrect proposals sortition. [\#5620](https://github.com/decidim/decidim/pull/5620)
- **decidim-admin**: Fix: let components without step settings be added [\#5568](https://github.com/decidim/decidim/pull/5568)
- **decidim-proposals**: Fix proposals that have their state not published [\#5832](https://github.com/decidim/decidim/pull/5832)
- **decidim-core**: Fix map hovering over the secondary navigation element [\#5871](https://github.com/decidim/decidim/pull/5871)
- **decidim-core**: Fix follow button not doing anything when not logged in [\#5872](https://github.com/decidim/decidim/pull/5872)
- **decidim-core**: Fix missing tribute source map [\#5869](https://github.com/decidim/decidim/pull/5869)
- **decidim-api**: Force signin on API if the organization requires it [\#5859](https://github.com/decidim/decidim/pull/5859)
- **decidim-core**: Apply security patch for GHSA-65cv-r6x7-79hv [\#5896](https://github.com/decidim/decidim/pull/5896)
- **decidim-core**: Fix proposals filtering by scope in Chrome [\#5901](https://github.com/decidim/decidim/pull/5901)
- **decidim-comments**: Don't allow comments deeper than a certain depth, at the API level [\#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-core**: Force SSL and HSTS [\#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-core**: Do not expose Ruby version in production [\#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-verifications**: Throttle failed authorization attempts [\#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-core**: Prevent timing attacks on login and avoid leaking timing info [\#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-core**: Expire sessions after 24h of creation [\#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-participatory_processes**: Do not expose process statistics in the API if hidden [\#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-core**: Invalidate sessions on logout [\#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-core**: Do now allow uploading SVGs [\#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-core**: Do not leak image processing errors [\#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-core**, **decidim-proposals**, **decidim-participatory_processes**, **decidim-meetings**, **decidim-sortitions**: XSS sanitization [\#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-core**: Fix the scopes picker rendereding escaped characters [#5939](https://github.com/decidim/decidim/pull/5939)

### Removed

### Previous versions

Please check [0.21-stable](https://github.com/decidim/decidim/blob/0.21-stable/CHANGELOG.md) for previous changes.
