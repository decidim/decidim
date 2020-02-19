# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

### Deprecation warnings

PR [\#5676](https://github.com/decidim/decidim/pull/5676) introduced a deprecation warning:

- `Decidim::ParticipatorySpaceResourceable#link_participatory_spaces_resources` should be renamed to `link_participatory_space_resources` (notice singular `spaces`)

### Upgrade notes

- **Assembly types**

In order to prevent errors while upgrading multi-servers envirnoments, the fields `assembly_type` and `assembly_type_other` are maintained. Future releases will take care of this.

- **Organization Time Zones**

Now is its possible to configure every organization (tenant) with a different time zone by any admin in the global configuration. We recommend to not define any specific `config.time_zone` in Rails so it uses UTC internally. In any case Rails configuration will be ignored in the context of the controller (users will be using always organization's configured time zone).

To upgrade it is recommended to configured the proper time zone in the admin for the organization and remove any `config.time_zone` personalization in Rails (unless you know what you are doing).

For those who have not changed the Rails `config.time_zone` (thus using UTC globally) but using dates as if they were non-UTC zones might notice that changing the organization time zone will shift all presented dates accordingly. This might require to re-edit any scheduled date in meetings or debates in order be properly displayed.

- **Data portability**

Thanks to [#5342](https://github.com/decidim/decidim/pull/5342), Decidim now supports removal of user's data portability expired files from Amazon S3. Check out the [scheduled tasks in the getting started guide](https://github.com/decidim/decidim/blob/master/docs/getting_started.md#scheduled-tasks) for information in how to configure it.

**Added**:

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

**Fixed**:

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
- **decidim-verifications**: Fix: Missing method email_regexp [#5560](https://github.com/decidim/decidim/pull/5560)
- **decidim-core**: Fix: use incrementing date when rebuilding since one date. [\#5541](https://github.com/decidim/decidim/pull/5541)
- **decidim-core**: Expand top-level navigation on mobile by default [#5580](https://github.com/decidim/decidim/pull/5580)
- **decidim-proposals**: Filtering by state working when searching amendments [#5703](https://github.com/decidim/decidim/pull/5703)
- **decidim-core**: Fix: Display values on translated fields with hashtaggable option on edit forms [#5661](https://github.com/decidim/decidim/pull/5661)

**Removed**:

## Previous versions

Please check [0.20-stable](https://github.com/decidim/decidim/blob/0.20-stable/CHANGELOG.md) for previous changes.
