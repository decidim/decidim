# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

**Added**:

- **decidim-proposals**: Added a button to reset all participatory text drafts. [\#4814](https://github.com/decidim/decidim/pull/4814)
- **decidim-proposals** Add text formatting capabilities to MarkdownToProposals. [\#4837](https://github.com/decidim/decidim/pull/4837)
- **decidim-docs** Update dependencies and ruby version. [\#4812](https://github.com/decidim/decidim/pull/4812)
- **decidim-proposals** Lists are imported as a single proposal. [\#4780](https://github.com/decidim/decidim/pull/4780)
- **decidim-proposals**: Allow to persist participatory text drafts before publishing. [\#4808](https://github.com/decidim/decidim/pull/4808)
- **decidim-docs**: Some components.md corrections and a little more info related with modules and engines.. [\#4752](https://github.com/decidim/decidim/pull/4752)
- **decidim-proposals**: Add Participatory Text support for images in Markdown. [\#4791](https://github.com/decidim/decidim/pull/4791)
- **decidim-proposals**: In participatory texts it is better to render Article cards open by default. [\#4806](https://github.com/decidim/decidim/pull/4806)
- **decidim-proposals**: Add Participatory Text support for links in Markdown. [\#4790](https://github.com/decidim/decidim/pull/4790)
- **decidim-core**: User groups can now be disabled per organization. [\#4681](https://github.com/decidim/decidim/pull/4681/)
- **decidim-core**: Add custom SMTP settings per organization. [\#4698](https://github.com/decidim/decidim/pull/4698)
- **decidim-initiatives**: Add setting in `Decidim::InitiativesType` to restrict online signatures [\#4668](https://github.com/decidim/decidim/pull/4668)
- **decidim-verifications**: Add multitenant csv census verifications [\#4719](https://github.com/decidim/decidim/pull/4719)
- **decidim-initiatives**: Extend authorizations to resources not related with components and define initiatives vote authorizations on initiatives types [\#4747](https://github.com/decidim/decidim/pull/4747)
- **decidim-initiatives**: Add setting in `Decidim::InitiativesType` to set minimum commitee members before sending initiative to technical evaluation [\#4688](https://github.com/decidim/decidim/pull/4688)
- **decidim-initiatives**: Add option to initiative types to collect personal data on signature and make related changes in front [\#4690](https://github.com/decidim/decidim/pull/4690)
- **decidim-initiatives**: Implement a mechanism to store encrytped personal data of users on votes and decrypt it exporting to PDF [\#4716](https://github.com/decidim/decidim/pull/4716)
- **decidim-initiatives**: Add setting to initiatives types to enable a step to allow initiative signature after passing SMS verification mechanism [\#4792](https://github.com/decidim/decidim/pull/4792)
- **decidim-initiatives**: Allow integration of services to add timestamps and sign PDFs, define example services and use in application generator [\#4805](https://github.com/decidim/decidim/pull/4805)
- **decidim-initiatives**: Add setting to initiatives types to verify document number provided on votes and avoid duplicated votes with the same document [\#4794](https://github.com/decidim/decidim/pull/4794)
- **decidim-initiatives**: Add validation using metadata of authorization for handler defined to validate document mumber [\#4838](https://github.com/decidim/decidim/pull/4838)
- **decidim-initiatives**: Better admin initiative search [\#4845](https://github.com/decidim/decidim/pull/4845)
- **decidim-meetings**: Order meetings at admin [\#4844](https://github.com/decidim/decidim/pull/4844)
- **decidim-proposals** Add admin edit link for proposals [\#4843](https://github.com/decidim/decidim/pull/4843)
- **decidim-initiatives**: Add setting in `Decidim::InitiativesType` to enable users to undo their initiatives signatures. [\#4841](https://github.com/decidim/decidim/pull/4841)
- **decidim-initiatives**: Add author of initiative to committee members on creation. [\#4861](https://github.com/decidim/decidim/pull/4861)
- **decidim-initiatives**: Display state of initiative on edition form inside a disabled select. [\#4861](https://github.com/decidim/decidim/pull/4861)
- **decidim-initiatives**: Allow users report comments on initiatives and admins moderate reports from initiative admin panel. [\#4878](https://github.com/decidim/decidim/pull/4878)
- **decidim-admin**: Add css variables for multitenant custom colors. [\#4882](https://github.com/decidim/decidim/pull/4882)
- **decidim-verifications**: Allow definition of attributes in settings manifest to be required always on authorizations. [\#4911](https://github.com/decidim/decidim/pull/4911)
- **decidim-verifications**: Allow resending SMS code. [\#4928](https://github.com/decidim/decidim/pull/4928)
- **decidim-meetings** Let user groups join meetings [\#5060](https://github.com/decidim/decidim/pull/5060)
- **decidim-assemblies**, **decidim-participatory_processes** Reorganize admin form [\#5068](https://github.com/decidim/decidim/pull/5068)
- **decidim-assemblies**, **decidim-participatory_processes** Table headers sortable links [\#5010](https://github.com/decidim/decidim/pull/5010)
- **decidim-assemblies**, **decidim-participatory_processes** Filter spaces by scope and area [\#5047](https://github.com/decidim/decidim/pull/5047)
- **decidim-admin**: Do not allow to delete areas when they have dependent spaces. [#5041](https://github.com/decidim/decidim/pull/5041)
- **decidim-assemblies**, **decidim-conferences**, **decidim-participatory_processes** Space CTA button text changes when no components [\#5006](https://github.com/decidim/decidim/pull/5006)
- **decidim-participatory_processes**: Add a select field for assign an area to participatory processes [#5011](https://github.com/decidim/decidim/pull/5011)
- **decidim-accountability**: Also display the main scope as a filter for accountability results [#5022](https://github.com/decidim/decidim/pull/5022)

**Changed**:

- **decidim-core**: Change attachment photo image alt texts to title instead of description. [#5043](https://github.com/decidim/decidim/pull/5043)
- **decidim-comments**: Allow cancelling a vote on a comment. [#5042](https://github.com/decidim/decidim/pull/5042)

**Fixed**:

- **decidim-proposals**: Fix proposal participants metrics. [#5048](https://github.com/decidim/decidim/pull/5048)
- **decidim-comments**: Don't show a second reply button when comment is hidden. [#5045](https://github.com/decidim/decidim/pull/5045)
- **decidim-core**: Fix CSS transparencies using customized colors. [\#5071](https://github.com/decidim/decidim/pull/5071)
- **decidim-core**, **decidim-proposals**: Fix: show existing amendments when amendments feature is disabled [\#5070](https://github.com/decidim/decidim/pull/5070)
- **decidim-assemblies**: Fix admin assemblies form. [\#5054](https://github.com/decidim/decidim/pull/5054)
- **decidim-core**: Fix repeated amendments notifications. [\#5001](https://github.com/decidim/decidim/pull/5001)
- **decidim-core**: Fix amendments forms: show error messages and render hashtags. [#4951](https://github.com/decidim/decidim/pull/4951)
- **decidim-comments**: Fixes that as a normal user (no private user) I can comment on a private assembly where is available. [#4924](https://github.com/decidim/decidim/pull/4924)
- **decidim-accountability**: Handle special case when all children weight are nil on accountability. [#5026](https://github.com/decidim/decidim/pull/5026)
- **decidim-proposals**: Filter emendations by rendering only amendments. [#5025](https://github.com/decidim/decidim/pull/5025)
- **decidim-proposals**: Add documents folder in proposals manifest for precompile assets. [#5015](https://github.com/decidim/decidim/pull/5015)
- **decidim-core**: Fix user notification and interest settings on IE11. [#5044](https://github.com/decidim/decidim/pull/5044)
- **decidim-admin**, **decidim-forms**, **decidim-meetings**: Fix dynamic fields components on IE11. [#5052](https://github.com/decidim/decidim/pull/5052)
- **decidim-core**: Fix possible NoMethodErrors in the notification jobs filling logs. [#5083](https://github.com/decidim/decidim/pull/5083)
- **decidim-participatory_processes**: Fix step CTA URL when abse URL had params [#5082](https://github.com/decidim/decidim/pull/5082)

**Removed**:

## Previous versions

Please check [0.17-stable](https://github.com/decidim/decidim/blob/0.17-stable/CHANGELOG.md) for previous changes.
