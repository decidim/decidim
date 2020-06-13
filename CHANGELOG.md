# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

### Added

### Changed

### Fixed

- **decidim-surveys**: Fix ip_hash not being saved in anonymous surveys. [\#6156](https://github.com/decidim/decidim/pull/6156)
- **decidim-proposals**: Fix participatory text newline absence. [\#6158](https://github.com/decidim/decidim/pull/6158)
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
- **decidim-core**, **decidim-assemblies**: Fix the edit link test failing seemingly randomly [\#6161](https://github.com/decidim/decidim/pull/6161)
- **decidim-participatory_processes**: Fix the edit link test failing randomly for participatory processes spec [\#6180](https://github.com/decidim/decidim/pull/6180)
- **decidim-comments**: Fix comments JS errors and delays [\#6193](https://github.com/decidim/decidim/pull/6193)

### Removed

## Previous versions

Please check [0.22-stable](https://github.com/decidim/decidim/blob/0.22-stable/CHANGELOG.md) for previous changes.
