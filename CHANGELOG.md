# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)


**Added**:

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


**Changed**:

- **decidim-accountability**, **decidim-assemblies**, **decidim-consultations**, **decidim-core**, **decidim-proposals**, **decidim-debates**, **decidim-dev**, **decidim-generators**, **decidim-initiatives**, **decidim-meetings**, **decidim-participatory_processes**, **decidim-proposals**, **decidim-sortitions**, **decidim_app-design**: Change: social share button default sites [\#5270](https://github.com/decidim/decidim/pull/5270)
- **decidim-core**: Changes default format date [#5330](https://github.com/decidim/decidim/pull/5330)

**Fixed**:

- **decidim-core**: Fix: saving default language to session if choosen by the user [#5308](https://github.com/decidim/decidim/pull/5308)
- **decidim-proposals**: Fix: show amend button in `ParticipatoryText` when `amendment_creation` is enabled and there are no visible emendations [#5300](https://github.com/decidim/decidim/pull/5300)
- **decidim-proposals**: Fix: prevent ransack gem to upgrade to 2.3 as breaks searches with amendments. [#5303](https://github.com/decidim/decidim/pull/5303)
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


**Removed**:

## Previous versions

Please check [0.18-stable](https://github.com/decidim/decidim/blob/0.18-stable/CHANGELOG.md) for previous changes.
