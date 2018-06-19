# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

**Added**:

- **decidim-core**: GDPR: Add Right of data portability. [\#3489](https://github.com/decidim/decidim/pull/3489)
- **decidim-initiatives**: Notify the followers when an initiative's signatures end date has been extended [\#3621](https://github.com/decidim/decidim/pull/3621)

**Changed**:

- **decidim-participatory_processes**: Make process moderators receive notifications about flagged content [\#3605](https://github.com/decidim/decidim/pull/3605)
- **decidim-meetings**: Do not let users join a meeting from the Search page, as the button fails [\#3612](https://github.com/decidim/decidim/pull/3612)
- **decidim-core**: Scope nicknames in organizations, so they don't have to be unique in a multi-tenant setup [\#3671](https://github.com/decidim/decidim/pull/3671)

**Fixed**:

- **decidim-core**: Search results should be paginated so that server does not hang when search term is too wide. [\#3605](https://github.com/decidim/decidim/pull/3605)
- **decidim-assemblies**: Fix private assemblies showing more than once for private users. [\#3638](https://github.com/decidim/decidim/pull/3638)
- **decidim-proposals**: Do not index non published Proposals. [\#3618](https://github.com/decidim/decidim/pull/3618)
- **decidim-proposals**: Fix link to endorsements behaviour, now it does not link when there are no endorsements. [\#3531](https://github.com/decidim/decidim/pull/3531)
- **decidim-meetings**: Fix meetings M card cell so that it works outside the component [\#3612](https://github.com/decidim/decidim/pull/3612)
- **decidim-proposals**: Fix proposals M card cell so that it works outside the component [\#3612](https://github.com/decidim/decidim/pull/3612)
- **decidim-core**: Adds a missing migration to properly rename features to components [\#3657](https://github.com/decidim/decidim/pull/3657)
- **decidim-blogs**: Use custom sanitizer in views instead of the default one [\#3655](https://github.com/decidim/decidim/pull/3655)
- **decidim-core**: Use custom sanitizer in views instead of the default one [\#3655](https://github.com/decidim/decidim/pull/3655)
- **decidim-initiatives**: Use custom sanitizer in views instead of the default one [\#3655](https://github.com/decidim/decidim/pull/3655)
- **decidim-sortitions**: Use custom sanitizer in views instead of the default one [\#3655](https://github.com/decidim/decidim/pull/3655)
- **decidim-assemblies**: Let space users access the admin area from the public one [\#3666](https://github.com/decidim/decidim/pull/3666)
- **decidim-participatory_processes**: Let space users access the admin area from the public one [\#3666](https://github.com/decidim/decidim/pull/3666)
- **decidim-core**: Fix comments count failing in AuthorCell [\#3668](https://github.com/decidim/decidim/pull/3668)

**Removed**:

## Previous versions

Please check [0.12-stable](https://github.com/decidim/decidim/blob/0.12-stable/CHANGELOG.md) for previous changes.
