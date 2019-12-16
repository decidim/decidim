# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

### Upgrade notes

- **Endorsements**

This new version of Decidim has extracted the Endorsement feature into a generic concern that can now be applied to many resources.
To keep current Decidim::Proposals::Proposal's endorsement information, endorsements are copied into the new `Decidim::Endorsable` tables and counter cache columns. This is done via migrations.

After this, `Decidim::Proposals::ProposalEndorsement` and the corresponding counter cache column in `decidim_proposals_proposal.proposal_endorsements_count` should be removed. To do so, Decidim will provide the corresponding migration in the next release.

### Added

- **decidim-dev**: Retry failed test to avoid flaky. [\#5894](https://github.com/decidim/decidim/pull/5894)
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
- **decidim**: Add missing indexs on foreign keys on the DB [\#5885](https://github.com/decidim/decidim/pull/5885)
## Removed
In order to prevent errors while upgrading multi-servers envirnoments, the fields `assembly_type` and `assembly_type_other` are maintained. Future releases will take care of this.

- **Organization Time Zones**

Now is its possible to configure every organization (tenant) with a different time zone by any admin in the global configuration. We recommend to not define any specific `config.time_zone` in Rails so it uses UTC internally. In any case Rails configuration will be ignored in the context of the controller (users will be using always organization's configured time zone).

To upgrade it is recommended to configured the proper time zone in the admin for the organization and remove any `config.time_zone` personalization in Rails (unless you know what you are doing).

For those who have not changed the Rails `config.time_zone` (thus using UTC globally) but using dates as if they were non-UTC zones might notice that changing the organization time zone will shift all presented dates accordingly. This might require to re-edit any scheduled date in meetings or debates in order be properly displayed.

- **Data portability**

Thanks to [#5342](https://github.com/decidim/decidim/pull/5342), Decidim now supports removal of user's data portability expired files from Amazon S3. Check out the [scheduled tasks in the getting started guide](https://github.com/decidim/decidim/blob/master/docs/getting_started.md#scheduled-tasks) for information in how to configure it.

- **SSL is forced on by default**

Due to [#5553](https://github.com/decidim/decidim/pull/5553), SSL is turned on by default.

- **GraphiQL is no longer exposed in production**

You can override this through the configuration flag `Decidim.config.expose_graphiql`.

**Added**:
- **decidim-core**: Add new language: Greek [#5597](https://github.com/decidim/decidim/pull/5597)

- **decidim-initiatives**: An admin can only send the initiative to technical validation if it has enough committee members. [\#5762](https://github.com/decidim/decidim/pull/5762)
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
- **decidim-proposals**: Add a navbar link to answer a proposal in the admin [\#5706](https://github.com/decidim/decidim/pull/5706)
- **decidim-participatory_processes** Statistics and Metrics Improvements[\#5688](https://github.com/decidim/decidim/pull/5688)
- **decidim-proposals** and **decidim-budgets**: Improve navigation and visualization of proposals and projects by scope, category, origin and status [\#5654](https://github.com/decidim/decidim/pull/5654)
- **decidim-proposals**: Let admins add cost reports to proposals [\#5695](https://github.com/decidim/decidim/pull/5695)
- **decidim-conferences**: Add Valuator role [\#5687](https://github.com/decidim/decidim/pull/5687)
- **decidim-initiatives**: Add Valuator role [\#5687](https://github.com/decidim/decidim/pull/5687)
- **decidim-participatory_processes**: Add Valuator role [\#5687](https://github.com/decidim/decidim/pull/5687)
- **decidim-proposals**: Let Valuators only answer and leave private notes on proposals [\#5687](https://github.com/decidim/decidim/pull/5687)
- **decidim-core**: Let exporters filter collection by user triggering the action [\#5687](https://github.com/decidim/decidim/pull/5687)
- **decidim-admin**: Admin can bulk update proposal's scope [\5759](https://github.com/decidim/decidim/pull/5759)

**Changed**:

- **decidim-core**: Shorten the 100 chars default last activity cards description lenght to 80 chars [\#5742](https://github.com/decidim/decidim/pull/5742)
- **decidim-core**: Show the number of followers when the button "follow" appears. [\#5593](https://github.com/decidim/decidim/pull/5593)
- **decidim-dev**: Be liberal with Puma's declared version condition. [\#5650](https://github.com/decidim/decidim/pull/5650)
- **decidim-meetings**: Add width and height to meetings component icon [\#5614](https://github.com/decidim/decidim/pull/5614)
- **decidim-proposals**: Versions box is removed and placed after the reference ID, and using the same styles. [\#5594](https://github.com/decidim/decidim/pull/5594)
- **decidim-participatory_processes**, **decidim-conferences**, **decidim-assemblies**, **decidim-initiatives**: Use cardM cell in space embed [#5589](https://github.com/decidim/decidim/pull/5589)
- **decidim-proposals**: Update tags layout in proposal page [\#5646](https://github.com/decidim/decidim/pull/5646)
- **decidim-comments**: Hide and show comment threads [#5655](https://github.com/decidim/decidim/pull/5655)
- **decidim-core**: Amendable resources can react to amendment state changes [#5703](https://github.com/decidim/decidim/pull/5703)
- **decidim-proposals, decidim-debates and decidim-initiatives**: Improved visiblity of buttons: new proposal, debate and initiative. [\#5535](https://github.com/decidim/decidim/pull/5535)
- **decidim-proposals**: Add a filter "My proposals" at the list of proposals. [\#5512](https://github.com/decidim/decidim/pull/5512)
- **decidim-meetings**: Change: @meetings_spaces collection to use I18n translations [#5494](https://github.com/decidim/decidim/pull/5494)
- **decidim-core**: Add @ prefix to the nickname field in the registration view. [\#5482](https://github.com/decidim/decidim/pull/5482)
- **decidim-core**: Introduce the ActsAsAuthor concern. [\#5482](https://github.com/decidim/decidim/pull/5482)
- **decidim-core**: Extract footers into partials. [#5461](https://github.com/decidim/decidim/pull/5461)
- **decidim-initiatives**: UX improvements to initiatives [#5369](https://github.com/decidim/decidim/pull/5369)
- **decidim-core**: Update to JQuery 3 [#5433](https://github.com/decidim/decidim/pull/5433)
- **decidim_participatory_process**: Admin: move `:participatory_process_groups` from `:main_menu` to `:participatory_processes` `:secondary_nav`[#5545](https://github.com/decidim/decidim/pull/5545)
- **decidim-core**: Remove the Continuity badge [#5565](https://github.com/decidim/decidim/pull/5565)
- **decidim-core**: Remove resizing for banner images [#5567](https://github.com/decidim/decidim/pull/5567)
- **decidim-comments**: Paginate comments [#5553](https://github.com/decidim/decidim/pull/5553)

**Fixed**:

- **decidim-core**: Do not allow invited users to sign up. [\#5803](https://github.com/decidim/decidim/pull/5803)
- **decidim-initiatives**: Fix initiative state bug [\#5805](https://github.com/decidim/decidim/pull/5805)
- **decidim-admin**, **decidim-proposals**: Fix proposal card layout. [\#5783](https://github.com/decidim/decidim/pull/5783)
- **decidim-core**: [FIX] Add description pop up required [\#5771](https://github.com/decidim/decidim/pull/5771)
- **decidim-admin**: Fixed css visual issues with dynamic filters. [\#5801](https://github.com/decidim/decidim/pull/5801)
- **decidim-admin**: Fixed dynamic filters showing ID. [\#5786](https://github.com/decidim/decidim/pull/5786)
- **decidim-comments**: Fix rendering up to 4 levels of comments. [\#5707](https://github.com/decidim/decidim/pull/5707)
- **decidim-proposals**: Render rich text in Proposals originated in Meetings. [\#5705](https://github.com/decidim/decidim/pull/5705)
- **decidim-admin**: Avoid user_manager permissions to shadow space admin permissions. [\#5698](https://github.com/decidim/decidim/pull/5698)
- **decidim-core**: Fix: display the correct google brand log in omniauth login view. [\#5685](https://github.com/decidim/decidim/pull/5685)
- **decidim-core**: Fix \#5342, when the fog provider is aws there were some fixes to be done. [\#5660](https://github.com/decidim/decidim/pull/5660)
- **decidim-participatory_processes and decidim-core**: Participatory processes not being imported properly. [\#5596](https://github.com/decidim/decidim/pull/5596)
- **decidim-api**: Fix a missing asset in the API documentation.  [\#5693](https://github.com/decidim/decidim/pull/5693)
- **decidim-core**: Fix 4 accessibility warnings generated by Google Chrome.  [\#5299](https://github.com/decidim/decidim/pull/5299)
- **decidim-core**: Fix: display the correct google brand log in omniauth login view. [\#5685](https://github.com/decidim/decidim/pull/5685)
- **decidim-core**: Fix: Apply google webmaster guidelines for buttons "sign with Google".[\#5592](https://github.com/decidim/decidim/pull/5592)
- **decidim-verifications**: Fix: Missing method email_regexp [\#5560](https://github.com/decidim/decidim/pull/5560)
- **decidim-core**: Fix: use incrementing date when rebuilding since one date. [\#5541](https://github.com/decidim/decidim/pull/5541)
- **decidim-core**: Expand top-level navigation on mobile by default [#5580](https://github.com/decidim/decidim/pull/5580)
- **decidim-proposals**: Filtering by state working when searching amendments [#5703](https://github.com/decidim/decidim/pull/5703)
- **decidim-core**: Fix: Display values on translated fields with hashtaggable option on edit forms [#5661](https://github.com/decidim/decidim/pull/5661)
- **decidim-core**: Fix: use of browse history with filters [#5749](https://github.com/decidim/decidim/pull/5749)
- **decidim-budgets**: Add a missing fix applied to proposals in [\#5654](https://github.com/decidim/decidim/pull/5654) but not to projects [\#5743](https://github.com/decidim/decidim/pull/5743)
- **decidim-proposals**: Admin: fix "Answer Proposal" action tooltip [/#5750](https://github.com/decidim/decidim/pull/5750)
- **decidim-conferences**: Fix: Cluttered conference sessions in confirmation mail.[\#5524](https://github.com/decidim/decidim/pull/5524)
- **decidim-core**: Security upgrade: puma. [\#5556](https://github.com/decidim/decidim/pull/5556)
- **decidim-admin**: Fix: Edit component permissions when PermissionsForm validations fail [\#5458](https://github.com/decidim/decidim/pull/5458)
- **decidim-core**: Security upgrade: rack-cors. [\#5527](https://github.com/decidim/decidim/pull/5527)
- **decidim-core**, **decidim-proposals**: Fix: diffing attributes with integer values [\#5468](https://github.com/decidim/decidim/pull/5468)
- **decidim-consultations**: Fix: current_participatory_space raises error in ConsultationsController.[\#5513](https://github.com/decidim/decidim/pull/5513)
- **decidim-admin**: Admin HasAttachments forces the absolute namespace for the AttachmentForm to `::Decidim::Admin::AttachmentForm`.[\#5511](https://github.com/decidim/decidim/pull/5511)
- **decidim-participatory_processes**: Fix participatory process import when some imported elements are null [\#5496](https://github.com/decidim/decidim/pull/5496)
- **decidim-core**: Security upgrade: loofah. [\#5493](https://github.com/decidim/decidim/pull/5493)
- **decidim-core**: Fix: misspelling when selecting the meetings presenter. [\#5482](https://github.com/decidim/decidim/pull/5482)
- **decidim-core**, **decidim-participatory_processes**: Fix: Duplicate results in `Decidim::HasPrivateUsers::visible_for(user)` [\#5462](https://github.com/decidim/decidim/pull/5462)
- **decidim-participatory_processes**: Fix: flaky test when mapping Rails timezone names to PostgreSQL [\#5472](https://github.com/decidim/decidim/pull/5472)
- **decidim-conferences**: Fix: Add pagination interface to some sections [\#5463](https://github.com/decidim/decidim/pull/5463)
- **decidim-sortitions**: Fix: Don't include drafts in sortitions [\#5434](https://github.com/decidim/decidim/pull/5434)
- **decidim-assemblies**: Fix: Fixed assembly parent_id when selecting itself [#5416](https://github.com/decidim/decidim/pull/5416)
- **decidim-core**: Fix: Search box on mobile (menu) [#5502](https://github.com/decidim/decidim/pull/5502)
- **decidim-core**: Fix dynamic controller extensions (undefined method `current_user`) [#5533](https://github.com/decidim/decidim/pull/5533)
- **decidim-proposals**: Standardize proposal answer callout styles [#5530](https://github.com/decidim/decidim/pull/5530)
- **decidim-proposals**: Standardize proposal answer callout styles [#5530](https://github.com/decidim/decidim/pull/5530)
- **decidim-comments**: Don't allow comments deeper than a certain depth, at the API level [#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-core**: Force SSL and HSTS [#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-api**: Make exposing GraphiQL optional[#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-api**: Do not expose GraphiQL in production [#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-core**: Do not expose Ruby version in production [#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-verifications**: Throttle failed authorization attempts [#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-core**: Prevent timing attacks on login and avoid leaking timing info [#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-core**: Expire sessions after 24h of creation [#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-participatory_processes**: Do not expose process statistics in the API if hidden [#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-core**: Invalidate sessions on logout [#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-core**: Do now allow uploading SVGs [#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-core**: Do not leak image processing errors [#5553](https://github.com/decidim/decidim/pull/5553)
- **decidim-core**, **decidim-proposals**, **decidim-participatory_processes**, **decidim-meetings**, **decidim-sortitions**: XSS sanitization [#5553](https://github.com/decidim/decidim/pull/5553)

**Removed**:

### Changed

### Fixed

- **decidim-proposals**: Fix relative path in mentioned proposal email [\#5852](https://github.com/decidim/decidim/pull/5852)
- **decidim-proposals**: Use simple_format to add a wrapper to proposals body [\#5753](https://github.com/decidim/decidim/pull/5753)
- **decidim-sortitions**: Fix incorrect proposals sortition. [\#5620](https://github.com/decidim/decidim/pull/5620)
- **decidim-admin**: Fix: let components without step settings be added [\#5568](https://github.com/decidim/decidim/pull/5568)
- **decidim-proposals**: Fix proposals that have their state not published [\#5832](https://github.com/decidim/decidim/pull/5832)
- **decidim-core**: Fix missing tribute source map [\#5869](https://github.com/decidim/decidim/pull/5869)
- **decidim-api**: Force signin on API if the organization requires it [\#5859](https://github.com/decidim/decidim/pull/5859)
- **decidim-core**: Apply security patch for GHSA-65cv-r6x7-79hv [\#5896](https://github.com/decidim/decidim/pull/5896)

### Removed

### Previous versions

Please check [0.21-stable](https://github.com/decidim/decidim/blob/0.21-stable/CHANGELOG.md) for previous changes.
