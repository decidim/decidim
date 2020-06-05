# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

### Upgrade notes

- **Endorsements**

This new version of Decidim has extracted the Endorsement feature into a generic concern that can now be applied to many resources.
To keep current Decidim::Proposals::Proposal's endorsement information, endorsements are copied into the new `Decidim::Endorsable` tables and counter cache columns. This is done via migrations.

After this, `Decidim::Proposals::ProposalEndorsement` and the corresponding counter cache column in `decidim_proposals_proposal.proposal_endorsements_count` should be removed. To do so, Decidim will provide the corresponding migration in the next release.

- **Data portability**

Thanks to [\#5342](https://github.com/decidim/decidim/pull/5342), Decidim now supports removal of user's data portability expired files from Amazon S3. Check out the [scheduled tasks in the getting started guide](https://github.com/decidim/decidim/blob/master/docs/getting_started.md#scheduled-tasks) for information in how to configure it.

- **SSL is forced on by default**

Due to [\#5553](https://github.com/decidim/decidim/pull/5553), SSL is turned on by default.

- **New "extras" key in authorization metadata**

[\#6044](https://github.com/decidim/decidim/pull/6044) adds the possibility to have an "extras" key in the Authentication metadata that will be ignored. For example when
signing an initiative (decidim-initiatives/app/forms/decidim/initiatives/vote_form.rb) or on Authorization renewal (decidim-verifications/app/cells/decidim/verifications/authorization_metadata/show.erb).

This key may be used to persist whatever information related to the user's authentication that should not be used for authenticating her.
The use case that originated this change is the persistence of the user's gender for statistical uses.

### Added

- **decidim-initiative**: Skip initiative type selection if there is only one initiative type. [\#5835](https://github.com/decidim/decidim/pull/5835)
- **decidim-participatory_processes**: Add related assemblies to participatory processes [\#5868](https://github.com/decidim/decidim/pull/5868)
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
- **decidim-accountability**: Added support for import csv files [\#6028](https://github.com/decidim/decidim/pull/6028)
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
- **decidim-initiatives**: Add areas to initiatives. [\#6111](https://github.com/decidim/decidim/pull/6111)
- **decidim-meetings**: Let users create meetings [\#6095](https://github.com/decidim/decidim/pull/6095)

### Changed

- **decidim-admin**, **decidim-core**: Improve explanation on image management on Layout Appearance. [\#6089](https://github.com/decidim/decidim/pull/6089)
- **decidim-initiatives**: Change initiatives committee request permission to prevent homepage redirection. [\#6115](https://github.com/decidim/decidim/pull/6115)
- **decidim-accountability**, **decidim-core**, **decidim-meetings**, **decidim-proposals**: Optimize queries for performance in Homepage, process page, proposals page and coauthorable cell. [\#5903](https://github.com/decidim/decidim/pull/5903)
- **decidim-assemblies**: Replace current meetings hook with highlighted elements hook [\#5897](https://github.com/decidim/decidim/pull/5897)
- **decidim-core**: Change the map marker color to the Decidim primary color [\#5870](https://github.com/decidim/decidim/pull/5870)
- **decidim-core**: Add whitespace: nowrap style to compact buttons. [\#5891](https://github.com/decidim/decidim/pull/5891)
- **decidim-core**: Hide password fields on Accounts page when organization sign in is disabled. [\#6130](https://github.com/decidim/decidim/pull/6130)
- **decidim-initiatives**: Ignore new "extras" key when checking authorization/variation metadata [\#6044](https://github.com/decidim/decidim/pull/6044)
- **decidim-assemblies**: Change user permission to list assemblies. Users can only list the assemblies that they have been assigned permission [\#5944](https://github.com/decidim/decidim/pull/5944)
- **decidim-accountability**: Using the new proposals selector for choosing result proposals [\#5863](https://github.com/decidim/decidim/pull/5863)
- **decidim-meetings**: Using the new proposals selector for choosing meeting close proposals [\#5863](https://github.com/decidim/decidim/pull/5863)

### Fixed

- **decidim-consultations**: Fix permissions in order to make components inside of questions accessible. [\#6079](https://github.com/decidim/decidim/pull/6079)
- **decidim-core**: Patch various security alerts reported by GitHub. [\#6148](https://github.com/decidim/decidim/pull/6148)
- **decidim-core**: Fix user's avatar icon in CSS. [\#5990](https://github.com/decidim/decidim/pull/5990)
- **decidim-core**: Use internal Organization class in migration. [\#6052](https://github.com/decidim/decidim/pull/6052)
- **decidim-core**: Fix email not being sent to some users when uploading a CSV file. [\#6011](https://github.com/decidim/decidim/pull/6011)
- **decidim-core**: Fix broken puma version in generator's Gemfile. [\#6060](https://github.com/decidim/decidim/pull/6060)
- **decidim-core,decidim-system**: Fix using Decidim as a provider for omniauth authentication. [\#6042](https://github.com/decidim/decidim/pull/6042)
- **decidim-proposals**: Fix missing values for filter values in proposals admin. [\#6013](https://github.com/decidim/decidim/pull/6013)
- **decidim-api**: Fix broken documentation if using Decidim from a Gem. [\#5996](https://github.com/decidim/decidim/pull/5996)
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
- **decidim-core**: Fix the destroy account command removing relations with spaces [\#6041](https://github.com/decidim/decidim/pull/6041)
- **decidim-core**: Avoid server hanging up when rendering newsletter templates previews on develoment or test env [\#6096](https://github.com/decidim/decidim/pull/6096)
- **decidim-initiatives**: Fix attachments related module inclusion [\#6140](https://github.com/decidim/decidim/pull/6140)
- **decidim-core**: Fix scopes filter when a participatory space scope has subscopes [\#6110](https://github.com/decidim/decidim/pull/6110)

### Removed

- **decidim-assemblies**: Removed legacy `assembly_type` fields. [\#5617](https://github.com/decidim/decidim/pull/5617)

## Previous versions

Please check [0.21-stable](https://github.com/decidim/decidim/blob/0.21-stable/CHANGELOG.md) for previous changes.
