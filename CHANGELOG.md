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

### Added

- **decidim-comments**: Fix comment link on Last Activity. [\#5999](https://github.com/decidim/decidim/pull/5999)
- **decidim-system**: Add from_label to Organization SMTP settings. [#\6125](https://github.com/decidim/decidim/pull/6125)
- **decidim-initiatives**: Send notification when signature threshold reached. [\#6098](https://github.com/decidim/decidim/pull/6098)
- **decidim-proposals**: Add an information message when there aren't proposals. [\#6063](https://github.com/decidim/decidim/pull/6063)
- **decidim-core**: Set email asset host dynamically. [\#5888](https://github.com/decidim/decidim/pull/5888)
- **decidim-meetings**: Include year in meetings' card [\#6102](https://github.com/decidim/decidim/pull/6102)
- **decidim-initiatives**: Add attachments to initiatives [\#5844](https://github.com/decidim/decidim/pull/5844)
- **decidim-proposals**: Improve proposal preview: Use proposal card when previewing a proposal draft. [\#6064](https://github.com/decidim/decidim/pull/6064)
- **decidim-core**: Allow groups to have private conversations with other users or groups. [\#6009](https://github.com/decidim/decidim/pull/6009)
- **decidim-api**: Use organization time zone [\#6088](https://github.com/decidim/decidim/pull/6088)
- **decidim-docs**: Add helpful info to install docs for seed errors during installation process. [\#6085](https://github.com/decidim/decidim/pull/6085)
- **decidim-forms**: Collapse and expand questions when editing questionnaire [\#5945](https://github.com/decidim/decidim/pull/5945)
- **decidim-forms**: New question type "Matrix" [\#5948](https://github.com/decidim/decidim/pull/5948)
- **decidim-core**: Notify admins o user_group created or updated. [\#5906](https://github.com/decidim/decidim/pull/5906)
- **decidim-comments**: Notify user_group followers when it posts a comment. [\#5906](https://github.com/decidim/decidim/pull/5906)
- **decidim-initiatives**: Notify admins when an initiative is sent to technical validation. [\#5906](https://github.com/decidim/decidim/pull/5906)
- **decidim-proposals**: Notify admins and valuators when someone leaves a private note on a proposal. [\#5906](https://github.com/decidim/decidim/pull/5906)
- **decidim-forms**: Update move up and down buttons after dragging questions when managing questionnaire. [\#5947](https://github.com/decidim/decidim/pull/5947)
- **decidim-meetings**: Automatic task for deleting Meeting Inscription data. [\#5989](https://github.com/decidim/decidim/pull/5989)
- **decidim-core**: Don't follow the header x forwarded host by default. [\#5899](https://github.com/decidim/decidim/pull/5899)
- **decidim-initiative**: Add CTA on initiative submission. [\#5838](https://github.com/decidim/decidim/pull/5838)
- **decidim-core**: Allow users to register with a preferred language. [\#5789](https://github.com/decidim/decidim/pull/5789)
- **decidim-dev**: Retry failed test to avoid flaky. [\#5894](https://github.com/decidim/decidim/pull/5894)
- **decidim-core**: Filter options to Timeline and Activity tabs. [\#5845](https://github.com/decidim/decidim/pull/5845)
- **decidim-core**: Add scroll to last message and apply it on conversations. [\#5718](https://github.com/decidim/decidim/pull/5718)
- **decidim-core**: Allow to restric direct messages to only people followed by the user. [\#5720](https://github.com/decidim/decidim/pull/5720)
- **decidim-comments**: Comments can mention groups and its members are notified. [\#5763](https://github.com/decidim/decidim/pull/5763)
- **decidim-core**: Now messages inside conversations have their urls identified as links. [\#5755](https://github.com/decidim/decidim/pull/5755)
- **decidim-verifications**: Added Verification's Revocation [\#5814](https://github.com/decidim/decidim/pull/5814)
- **decidim-verifications**: Participants can renew verifications [\#5854](https://github.com/decidim/decidim/pull/5854)
- **decidim-core**: Support node.js semver rules for release candidates. [\#5828](https://github.com/decidim/decidim/pull/5828)
- **decidim-proposals**, **decidim-core**, **decidim-blogs**: Extract proposals' endorsements into a polymorphic concern that can now be applied no any resource. It has, in turn, been aplied to blog posts. [\#5542](https://github.com/decidim/decidim/pull/5542)
- **decidim-proposals**, **decidim-core**, **decidim-blogs**: Apply generalized endorsements to the GraphQL API and add it to the blog posts query. [\#5847](https://github.com/decidim/decidim/pull/5847)
- **decidim-core**: Allow users to have private conversations with more than one participant. [\#5861](https://github.com/decidim/decidim/pull/5861)
- **decidim-budgets**: Allow projects to be sorted by different criteria [\#5808](https://github.com/decidim/decidim/pull/5808)
- **decidim-budgets**: Request confirmation to exit budgets component [\#5765](https://github.com/decidim/decidim/pull/5765)
- **decidim-budgets**: Add minimum projects rule to Budgets [\#5865](https://github.com/decidim/decidim/pull/5865)
- **decidim-proposals**: Proposals selector added [\#5863](https://github.com/decidim/decidim/pull/5863)
- **decidim-admin**: Allow to see a participant's email from the admin panel [\#5849](https://github.com/decidim/decidim/pull/5849)
- **decidim-admin**: As an Admin, add existing participant to an assembly by searching their email [\#5952](https://github.com/decidim/decidim/pull/5952)
- **decidim**: Add missing indexs on foreign keys on the DB [\#5885](https://github.com/decidim/decidim/pull/5885)
- **decidim-core**: Redesign activity cards for the home page [\#5672](https://github.com/decidim/decidim/pull/5672)
- **decidim-core**: Redesign activity cards on Timeline and Activity Tabs for a consistent user experience [\#5779](https://github.com/decidim/decidim/issues/5779)
- **decidim-admin**: Counter of active users. [\#5907](https://github.com/decidim/decidim/pull/5907)
- **decidim-proposals**: Update rspec proposal_activity_cell_spec to check existence of card\_\_content css class instead of car-data css class [#5779](https://github.com/decidim/decidim/issues/5779)
- **decidim-comments**: Update rspec comment_activity_cell_spec to check existence of card\_\_content css class instead of car-data css class[#5779](https://github.com/decidim/decidim/issues/5779)
- **decidim-core**: Add newsletter templates [\#5887](https://github.com/decidim/decidim/pull/5887)
- **decidim-core**: Fix clearing the current_user after sign out [\#5823](https://github.com/decidim/decidim/pull/5823)
- **decidim-budgets**: Send email with summary on order checkout [\#6006](https://github.com/decidim/decidim/pull/6006)
- **decidim-admin**: Show activity charts on admin dashboard [\#6030](https://github.com/decidim/decidim/pull/6030)
- **decidim-budgets**: Projects filter by multiple categories [\#5992](https://github.com/decidim/decidim/pull/5992)
- **decidim-budgets**: Improve the budget page and the project card [\#5809](https://github.com/decidim/decidim/pull/5809)
- **decidim-assemblies** **decidim-conferences** **decidim-participatory-processes**: Notify users on adding roles. [\#5886](https://github.com/decidim/decidim/pull/5886)
- **decidim-budgets**: Projects filter by multiple categories [/#5992](https://github.com/decidim/decidim/pull/5992)
- **decidim-initiatives**: Add option to enable/disable attachments to initiatives [/#6036](https://github.com/decidim/decidim/pull/6036)
- **decidim-core**: Adds new language: Slovak [\#6039](https://github.com/decidim/decidim/pull/6039)
- **decidim-core**: Add redesign for responsive public profile navigation tabs [\#6032](https://github.com/decidim/decidim/pull/6032)
- **decidim-initiatives**: Add pages for versioning. [\#5935](https://github.com/decidim/decidim/pull/5935)
- **decidim-core**: Explain how to initialize a custom oauth2 client provider [\#6055](https://github.com/decidim/decidim/pull/6055)
- **decidim-core**: Added support for enum settings for components [\#6001](https://github.com/decidim/decidim/pull/6001)
- **decidim-core**: Added support for readonly settings for components [\#6001](https://github.com/decidim/decidim/pull/6001)
- **decidim-initiatives**: Add filter by type to admin. [\#6093](https://github.com/decidim/decidim/pull/6093)
- **decidim-initiatives**: New search/filters design [\#6090](https://github.com/decidim/decidim/pull/6090)
- **decidim-core**: Improvements to conversations with more than one participant. [\#6094](https://github.com/decidim/decidim/pull/6094)
- **decidim-elections**: Elections module and election administration. [\#6065](https://github.com/decidim/decidim/pull/6065)
- **decidim-forms**: Split forms in steps using separators [\#6108](https://github.com/decidim/decidim/pull/6108)
- **decidim-initiatives**: Enhanced initiatives search [\#6086](https://github.com/decidim/decidim/pull/6086)
- **decidim-initiatives**: Add setting in `Decidim::InitiativesType` to enable users to set a custom signature end date in their initiatives. [\#5998](https://github.com/decidim/decidim/pull/5998)
- **decidim-initiatives**: Sorting by publish date and supports count on admin, by publish date on front [/#6016](https://github.com/decidim/decidim/pull/6016)
- **decidim-assemblies**: Added a setting for assemblies to enable or disable the visibility of the organization chart. [\#6040](https://github.com/decidim/decidim/pull/6040)
- **decidim-initiatives**: Allow admins to export initiatives [\#6070](https://github.com/decidim/decidim/pull/6070)
- **decidim-elections**: Add questions and answers to elections [\#6129](https://github.com/decidim/decidim/pull/6129)
- **decidim-forms**: Request confirmation when leaving the form half-answered [\#6118](https://github.com/decidim/decidim/pull/6118)
- **decidim-forms**: Request confirmation when leaving the form half-answered [\#6118](https://github.com/decidim/decidim/pull/6118)
- **decidim-initiatives**: Allow admins to export initiatives [/#6070](https://github.com/decidim/decidim/pull/6070)

### Changed

### Fixed

- **decidim-comments**: Fix comments JS errors and delays [\#6193](https://github.com/decidim/decidim/pull/6193)
- **decidim-elections**: Improve navigation consistency in the admin zone for elections questions and answers [\#6139](https://github.com/decidim/decidim/pull/6139)
- **decidim-assemblies**, **decidim-core**, **decidim-dev**, **decidim-forms**, **decidim-participatory_processes**, **decidim-proposals**: Fix rubocop errors arising from capybara upgrade [\#6197](https://github.com/decidim/decidim/pull/6197)

### Removed

- **decidim-proposals**: Remove legacy proposal endorsements. [\#5643](https://github.com/decidim/decidim/pull/5643)

## Previous versions

Please check [release/0.22-stable](https://github.com/decidim/decidim/blob/release/0.22-stable/CHANGELOG.md) for previous changes.