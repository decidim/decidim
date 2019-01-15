# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

**Upgrade notes**:

**Added**:

- **decidim-core**: User groups can now be disabled per organization. [\#4681](https://github.com/decidim/decidim/pull/4681/)
- **decidim-initiatives**: Add setting in `Decidim::InitiativesType` to restrict online signatures [\#4668](https://github.com/decidim/decidim/pull/4668)
- **decidim-initiatives**: Extend authorizations to resources not related with components and define initiatives vote authorizations on initiatives types [\#4747](https://github.com/decidim/decidim/pull/4747)

**Changed**:

- **decidim-proposals** Change collaborative draft contributors permissions [\#4712](https://github.com/decidim/decidim/pull/4712)
- **decidim-admin**: Change admin moderations manager [\#4717](https://github.com/decidim/decidim/pull/4717)
- **decidim-core**: Change action_authorization and modals to manage multiple authorization handlers instead of one [\#4747](https://github.com/decidim/decidim/pull/4747)
- **decidim-admin**: Change interface to manage multiple authorizations for components and resources [\#4747](https://github.com/decidim/decidim/pull/4747)

**Fixed**:

- **decidim-proposals** Fix unhideable reported collaborative drafts and mail jobs [\#4706](https://github.com/decidim/decidim/pull/4706)
- **decidim-assemblies**: Fix parent assemblies children_count counter [\#4718](https://github.com/decidim/decidim/pull/4718/)
- **decidim-core**: Place `CurrentOrganization` middleware before `WardenManager`. [\#4708](https://github.com/decidim/decidim/pull/4708)
- **decidim-core**: Fix form builder upload field multiple errors display [\#4715](https://github.com/decidim/decidim/pull/4715)
- **decidim-core**: MetricResolver filtering corrected comparison between symbol and string [\#4733](https://github.com/decidim/decidim/pull/4733)
- **decidim-core**: Ignore blank permission options in action authorizer [\#4744](https://github.com/decidim/decidim/pull/4744)

**Removed**:

## Previous versions

Please check [0.16-stable](https://github.com/decidim/decidim/blob/0.16-stable/CHANGELOG.md) for previous changes.
