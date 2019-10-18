# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)


**Added**:

- **decidim-forms**: Added UML clarifying the relation between the Questionnaire classes. [#5394](https://github.com/decidim/decidim/pull/5394)
- **decidim-consultations**: Allow multi-choice answers to questions in consultations. [#5356](https://github.com/decidim/decidim/pull/5356)
- **decidim-proposals**: Allow admins to create image galleries in proposals if attachments are enabled. [\#5339](https://github.com/decidim/decidim/pull/5339)
- **decidim-blog**: Allow attachments to blog posts. [\#5336](https://github.com/decidim/decidim/pull/5336)
- **decidim-admin**, **decidim-assemblies**, **decidim-participatory-processes**: Add CSV Import to Participatory Space Private Users. [\#5304](https://github.com/decidim/decidim/pull/5304)
- **decidim-participatory-processes**: Add: process group presenter [#5289](https://github.com/decidim/decidim/pull/5289)
- **decidim-consultations**: Allow to restrict voting to a question by adding verifications permissions [#5274](https://github.com/decidim/decidim/pull/5274)
- **decidim-participatory-processes**: Add: traceability to process groups [#5278](https://github.com/decidim/decidim/pull/5278)
- **decidim-core**, **decidim-proposals**: Add: amendments Wizard Step Form [#5244](https://github.com/decidim/decidim/pull/5244)
- **decidim-core**, **decidim-admin**, **decidim-proposals**: Add: `amendments_visibility` component step setting [#5223](https://github.com/decidim/decidim/pull/5223)
- **decidim-core**, **decidim-admin**, **decidim-proposals**: Add: admin configuration of amendments by step [#5178](https://github.com/decidim/decidim/pull/5178)
- **decidim-consultations**: Add admin results page to consultations [#5188](https://github.com/decidim/decidim/pull/5188)
- **decidim-core**: Adds SECURITY.md per Github recommendations [#5181](https://github.com/decidim/decidim/pull/5181)
- **decidim-core**, **decidim-system**: Add force users to authenticate before access to the organization [#5189](https://github.com/decidim/decidim/pull/5189)
- **decidim-proposals**: Add new fields to proposal_serializer [#5186](https://github.com/decidim/decidim/pull/5186)
- **decidim-proposals**: Add :amend action to proposal's authorization workflow [#5184](https://github.com/decidim/decidim/pull/5184)
- **decidim-core**, **decidim-proposals**: Add: Improvements in amendments on `Proposals` control version [#5185](https://github.com/decidim/decidim/pull/5185)
- **decidim-proposals**: Copy attachments when importing proposals [#5198](https://github.com/decidim/decidim/pull/5198)
- **decidim-core**: Adds new language: Norwegian [#5335](https://github.com/decidim/decidim/pull/5335)


**Changed**:

- **decidim-comments**: Change: Promote URLs in plain text to HTML anchors in comments.[\#5401](https://github.com/decidim/decidim/pull/5401)
- **decidim-core**: Promote URLs in plain text to HTML anchors after strip_tags. [\#5341](https://github.com/decidim/decidim/pull/5341)
- **decidim-accountability**, **decidim-assemblies**, **decidim-consultations**, **decidim-core**, **decidim-proposals**, **decidim-debates**, **decidim-dev**, **decidim-generators**, **decidim-initiatives**, **decidim-meetings**, **decidim-participatory_processes**, **decidim-proposals**, **decidim-sortitions**, **decidim_app-design**: Change: social share button default sites [\#5270](https://github.com/decidim/decidim/pull/5270)
- **decidim-core**: Changes default format date [#5330](https://github.com/decidim/decidim/pull/5330)
- **decidim-verifications**: Change CSV census validations [#5346](https://github.com/decidim/decidim/pull/5346)

**Fixed**:

- **decidim-assemblies**, **decidim-core**, **decidim-participatory_processes**, **decidim-proposals**: Fix: Non-private users can amend proposals from a private space [#5427](https://github.com/decidim/decidim/pull/5427)
- **decidim-sortitions**: Fix: Creating a Sortition ignores categories [#5412](https://github.com/decidim/decidim/pull/5412)
- **decidim-proposals**: Fix: ParticipatoryText workflow creates multiple versions [#5399](https://github.com/decidim/decidim/pull/5399)
- **decidim-assemblies**: Fix: show the Assemblies button to allow managing nested assemblies [#5386](https://github.com/decidim/decidim/pull/5386)
- **decidim-admin**: Fix: Remove first `:header_snippets` field on organization admin apparence form. [#5352](https://github.com/decidim/decidim/pull/5352)
- **decidim-accountability**, **decidim-core**, **decidim-proposals**, **decidim-dev**: Fix: diffing empty versions of translatable attributes [\#5312](https://github.com/decidim/decidim/pull/5312)
- **decidim-core**: Fix: WhatsApp url button [#5317](https://github.com/decidim/decidim/pull/5317)
- **decidim-core**: Fix: AuthorizationFormBuilder does not detect attribute types [#5315](https://github.com/decidim/decidim/pull/5315)
- **decidim-participatory_processes**: Fix: ParticipatoryProcessSearch#search_date [#5319](https://github.com/decidim/decidim/pull/5319)
- **decidim-proposals**: Fix: Show error when upload a file with the correct extension but with an error in the content [#5320](https://github.com/decidim/decidim/pull/5320)
- **decidim-core**: Fix: saving default language to session if choosen by the user [#5308](https://github.com/decidim/decidim/pull/5308)
- **decidim-proposals**: Fix: show amend button in `ParticipatoryText` when `amendment_creation` is enabled and there are no visible emendations [#5300](https://github.com/decidim/decidim/pull/5300)
- **decidim-proposals**: Fix: prevent ransack gem to upgrade to 2.3 as breaks searches with amendments. [#5303](https://github.com/decidim/decidim/pull/5303)
- **decidim-core**: Fix: Add uniq index to `decidim_metrics` table [#5314](https://github.com/decidim/decidim/pull/5314)
- **decidim-admin**, **decidim-core**, **decidim-dev**, **decidim-proposals**: Fix: multiple items related to amendments step settings and wizard [#5263](https://github.com/decidim/decidim/pull/5263)
- **decidim-admin**, **decidim-assemblies**, **decidim-conferences**, **decidim-consultations**, **decidim-core**, **decidim-dev**, **decidim-initiatives**, **decidim-participatory_processes**: Fix: `Decidim::Admin::ComponentForm` validations [#5269](https://github.com/decidim/decidim/pull/5269)
- **decidim-core**: Fix: `Accept-Language` header language detection and uses language default from the organization [#5272](https://github.com/decidim/decidim/pull/5272)
- **decidim-core**, **decidim-proposals**: When rendering the admin log for a Proposal, use the title from extras instead of crashing, when proposal has been deleted. [#5267](https://github.com/decidim/decidim/pull/5267)
- **decidim-core**, **decidim-proposals**: Fix: diffing withdrawn amendments and new lines in body [#5242](https://github.com/decidim/decidim/pull/5242)
- **decidim-core**: Filter forbidden characters in users invitations. [\#5245](https://github.com/decidim/decidim/pull/5245)
- **decidim-assemblies**: Don't show private assemblies when becoming childs from another assembly. [#5235](https://github.com/decidim/decidim/pull/5235)
- **decidim-conferences**: Fix: can't remove area, when conferences are enabled [#5234](https://github.com/decidim/decidim/pull/5234)
- **decidim-conferences**: Don't send registrations enabled notification when creating a Conference[#5240](https://github.com/decidim/decidim/pull/5240)
- **decidim-admin**: Fix: Proposals component form introduced regression [#5179](https://github.com/decidim/decidim/pull/5179)
- **decidim-core**: Fix seeds and typo in ActionAuthorizer [#5168](https://github.com/decidim/decidim/pull/5168)
- **decidim-proposals**: Fix seeds [#5168](https://github.com/decidim/decidim/pull/5168)
- **decidim-core**: Fix user names migration [#5209](https://github.com/decidim/decidim/pull/5209)
- **decidim-proposals**: Fix proposals accepted stat when they include hidden proposals [#5276](https://github.com/decidim/decidim/pull/5276)
- **decidim-forms**: Fix adding answer options to a new form [#5275](https://github.com/decidim/decidim/pull/5275)
- **decidim-core**: Add missing locales when creating a new user group [#5262](https://github.com/decidim/decidim/pull/5262)
- **decidim-core**: Fix CVE-2015-9284 Omniauth issue [#5284](https://github.com/decidim/decidim/pull/5284)
- **decidim-comments**, **decidim-core**, **decidim-verifications**, **decidim-initiatives**: Bugfixing [#5213](https://github.com/decidim/decidim/pull/5213)
- **decidim-core**: Fix forgotten redirect page in case TOS is not yet agreed on [#5313](https://github.com/decidim/decidim/pull/5313)
- **decidim-admin**: Fix managed users stolen identities with users having the same name [#5318](https://github.com/decidim/decidim/pull/5318)
- **decidim-core**: Fix usernames migration [#5321](https://github.com/decidim/decidim/pull/5321)
- **decidim-accountability**, **decidim-core**, **decidim-proposals**, **decidim-dev**, **decidim-admin**, **decidim-consultations**, **decidim-initiatives**, **decidim-meetings**, **decidim-proposals**: Multiple bugfixes [\#5329](https://github.com/decidim/decidim/pull/5329)
- **decidim-core**: Fix rendering when custom colors exist [#5347](https://github.com/decidim/decidim/pull/5347)
- **decidim-core**: Fix component generator [#5348](https://github.com/decidim/decidim/pull/5348)
- **decidim-core**: Fix email notifications [#5370](https://github.com/decidim/decidim/pull/5370)
- **decidim-assemblies**, **decidim-core**, **decidim-generators**, **decidim-initiatives**, **decidim-meetings**, **decidim-system** Various bugfixes [\#5376](https://github.com/decidim/decidim/pull/5376)
- **decidim-conferences**, **decidim-consultations**, **decidim-core**, **decidim-forms**, **decidim-meetings**, **decidim-proposals**, **decidim-verifications**** Various bugfixes [\#5383](https://github.com/decidim/decidim/pull/5383)
- **decidim-core** Fix omniauth registration edge cases and specs [#5397](https://github.com/decidim/decidim/pull/5397)
- **decidim-core**: Fix errors controller forgery protection [#5398](https://github.com/decidim/decidim/pull/5398)
- **decidim-meetings**, **decidim-core**: Various bugfixes [#5402](https://github.com/decidim/decidim/pull/5402)

**Removed**:

## Previous versions

Please check [0.18-stable](https://github.com/decidim/decidim/blob/0.18-stable/CHANGELOG.md) for previous changes.
