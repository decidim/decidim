# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

**Upgrade notes**:

**Added**:

- **decidim-proposals** Add text formatting capabilities to MarkdownToProposals. [\#4837](https://github.com/decidim/decidim/pull/4837)
- **decidim-docs** Update dependencies and ruby version. [\#4812](https://github.com/decidim/decidim/pull/4812)
- **decidim-proposals** Lists are imported as a single proposal. [\#4780](https://github.com/decidim/decidim/pull/4780)
- **decidim-proposals**: Allow to persist participatory text drafts before publishing. [\#4808](https://github.com/decidim/decidim/pull/4808)
- **decidim-docs**: Some components.md corrections and a little more info related with modules and engines.. [\#4752](https://github.com/decidim/decidim/pull/4752)
- **decidim-proposals**: Add Participatory Text support for images in Markdown. [\#4791](https://github.com/decidim/decidim/pull/4791)
- **decidim-proposals**: In participatory texts it is better to render Article cards open by default. [\#4806](https://github.com/decidim/decidim/pull/4806)
- **decidim-proposals**: Add Participatory Text support for links in Markdown. [\#4790](https://github.com/decidim/decidim/pull/4790)
- **decidim-core**: User groups can now be disabled per organization. [\#4681](https://github.com/decidim/decidim/pull/4681/)
- **decidim-initiatives**: Add setting in `Decidim::InitiativesType` to restrict online signatures [\#4668](https://github.com/decidim/decidim/pull/4668)
- **decidim-initiatives**: Extend authorizations to resources not related with components and define initiatives vote authorizations on initiatives types [\#4747](https://github.com/decidim/decidim/pull/4747)
- **decidim-initiatives**: Add setting in `Decidim::InitiativesType` to set minimum commitee members before sending initiative to technical evaluation [\#4688](https://github.com/decidim/decidim/pull/4688)
- **decidim-initiatives**: Add option to initiative types to collect personal data on signature and make related changes in front [\#4690](https://github.com/decidim/decidim/pull/4690)
- **decidim-initiatives**: Implement a mechanism to store encrytped personal data of users on votes and decrypt it exporting to PDF [\#4716](https://github.com/decidim/decidim/pull/4716)
- **decidim-initiatives**: Add setting to initiatives types to enable a step to allow initiative signature after passing SMS verification mechanism [\#4792](https://github.com/decidim/decidim/pull/4792)
- **decidim-initiatives**: Allow integration of services to add timestamps and sign PDFs, define example services and use in application generator [\#4805](https://github.com/decidim/decidim/pull/4805)
- **decidim-initiatives**: Add setting to initiatives types to verify document number provided on votes and avoid duplicated votes with the same document [\#4794](https://github.com/decidim/decidim/pull/4794)
- **decidim-initiatives**: Add validation using metadata of authorization for handler defined to validate document mumber [\#4838](https://github.com/decidim/decidim/pull/4838)

**Changed**:

- **decidim-proposals** Allow to change participatory texts title without uploading file. [\#4761](https://github.com/decidim/decidim/pull/4761)
- **decidim-proposals** Change collaborative draft contributors permissions [\#4712](https://github.com/decidim/decidim/pull/4712)
- **decidim-admin**: Change admin moderations manager [\#4717](https://github.com/decidim/decidim/pull/4717)
- **decidim-core**: Change action_authorization and modals to manage multiple authorization handlers instead of one [\#4747](https://github.com/decidim/decidim/pull/4747)
- **decidim-admin**: Change interface to manage multiple authorizations for components and resources [\#4747](https://github.com/decidim/decidim/pull/4747)

**Fixed**:

- **decidim-proposals**: Fix Proposals Last Activity feed [\#4828](https://github.com/decidim/decidim/pull/4828)
- **decidim-proposals**: Fix attachments not being inherited from collaborative draft when published as proposal. [\#4811](https://github.com/decidim/decidim/pull/4811)
- **decidim-core**: Add set_locale method to prevent users be redirected to unexpected locale[#4809](https://github.com/decidim/decidim/pull/4809)
- **decidim-core**: Fix inconsistent dataviz [\#4787](https://github.com/decidim/decidim/pull/4787)
- **decidim-proposals**: Fix participatory texts error uploading files with accents and special characters. [\#4788](https://github.com/decidim/decidim/pull/4788)
- **decidim-meetings**: Fix form when duplicating meetings [\#4750](https://github.com/decidim/decidim/pull/4750)
- **decidim-proposals**: Fix admin proposals manager: show proposal state [\#4789](https://github.com/decidim/decidim/pull/4789/)
- **decidim-core**: Fix DataPortabilityExportJob: private method 'file' called when Carrierwave Storage fog enable [#4337](https://github.com/decidim/decidim/pull/4337)
- **decidim-proposals** Public view of Participatory Text is now preserving new lines. [\#4782](https://github.com/decidim/decidim/pull/4782)
- **decidim-assemblies**: Fix assemblies filter by type [\#4778](https://github.com/decidim/decidim/pull/4778)
- **decidim-conferences**: Fix error when visiting a Conference event[\#4776](https://github.com/decidim/decidim/pull/4776)
- **decidim-proposals** Fix unhideable reported collaborative drafts and mail jobs [\#4706](https://github.com/decidim/decidim/pull/4706)
- **decidim-assemblies**: Fix parent assemblies children_count counter [\#4718](https://github.com/decidim/decidim/pull/4718/)
- **decidim-core**: Place `CurrentOrganization` middleware before `WardenManager`. [\#4708](https://github.com/decidim/decidim/pull/4708)
- **decidim-core**: Fix form builder upload field multiple errors display [\#4715](https://github.com/decidim/decidim/pull/4715)
- **decidim-core**: MetricResolver filtering corrected comparison between symbol and string [\#4733](https://github.com/decidim/decidim/pull/4733)
- **decidim-core**: Ignore blank permission options in action authorizer [\#4744](https://github.com/decidim/decidim/pull/4744)
- **decidim-proposals** Lock proposals on voting to avoid race conditions to vote over the limit [\#4763](https://github.com/decidim/decidim/pull/4763)
- **decidim-initiatives** Add missing dependency for wicked_pdf to initiatives module [\#4813](https://github.com/decidim/decidim/pull/4813)
- **decidim-participatory_processes**: Shows the short description on processes when displaying a single one on the homepage. [\#4824](https://github.com/decidim/decidim/pull/4824)
- **decidim-core** Fix redirect to static map view after login. [\#4830](https://github.com/decidim/decidim/pull/4830)
- **decidim-proposals**: Add missing translation key for "Address". [\#4835](https://github.com/decidim/decidim/pull/4835)
- **decidim-meetings**: Fix accepting/declining meeting invitations [\#4839](https://github.com/decidim/decidim/pull/4839)
- **decidim-budgets**: Allow only to attach published proposals to budgeting projects [\#4840](https://github.com/decidim/decidim/pull/4840)
- **decidim-core**: Prevent empty selection in the data picker [\#4842](https://github.com/decidim/decidim/pull/4842)

**Removed**:

## Previous versions

Please check [0.16-stable](https://github.com/decidim/decidim/blob/0.16-stable/CHANGELOG.md) for previous changes.
