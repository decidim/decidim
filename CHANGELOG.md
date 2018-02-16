# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

**Added**:

- **decidim-assemblies**: Assemblies now have a reference [\#2557](https://github.com/decidim/decidim/pull/2557)
- **decidim-core**: Let participatory spaces have reference [\#2557](https://github.com/decidim/decidim/pull/2557)
- **decidim-meetings**: Add simple formatting to debates fields to improve readability [\#2670](https://github.com/decidim/decidim/issues/2670)
- **decidim-meetings**: Notify participatory space followers when a meeting is created. [\#2646](https://github.com/decidim/decidim/pull/2646)
- **decidim-participatory_processes**: Processes now have a reference [\#2557](https://github.com/decidim/decidim/pull/2557)
- **decidim-proposals**: Notify participatory space followers when a proposal is created. [\#2646](https://github.com/decidim/decidim/pull/2646)
- **decidim-proposals**: Copy proposals to another component [\#2619](https://github.com/decidim/decidim/issues/2619).
- **decidim-proposals**: Users and user_groups can now endorse proposals. [\#2287](https://github.com/decidim/decidim/pull/2287)
- **decidim-participatory_processes**: Ensure only active processes are shown in the highlighted processes section in the homepage[\#2682](https://github.com/decidim/decidim/pull/2682)
- **decidim-core**: Add collections to group attachments [\#2394](https://github.com/decidim/decidim/pull/2394).

**Changed**:

- **decidim-core**: General improvements on documentation [\#2656](https://github.com/decidim/decidim/pull/2656).
- **decidim-core**: `FeatureReferenceHelper#feature_reference` has been moved to `ResourceReferenceHelper#resource_reference` to clarify its use. [\#2557](https://github.com/decidim/decidim/pull/2557)
- **decidim-core**: `Decidim.resource_reference_generator` has been moved to `Decidim.reference_generator` to clarify its use. [\#2557](https://github.com/decidim/decidim/pull/2557)

**Fixed**:

- **decidim-core**: Fix categories select when missing translations. [\#2742](https://github.com/decidim/decidim/pull/2742)
- **decidim-core**: Don't try to send notification emails to deleted users. [\#2743](https://github.com/decidim/decidim/pull/2743)
- **decidim-core**: Fix notifications list when the resource is a User. [\#2687](https://github.com/decidim/decidim/pull/2687)
- **decidim-core**: Fix mention rendering when there's more than one mention. [\2690](https://github.com/decidim/decidim/pull/2690)
- **decidim-participatory_processes**: Fix find a process by its ID.[\#2672](https://github.com/decidim/decidim/pull/2672)
- **decidim-assemblies**: Fix find an assembly by its ID.[\#2672](https://github.com/decidim/decidim/pull/2672)
- **decidim-core**: Fix notification mailer when a resource doesn't have an organization. [\#2661](https://github.com/decidim/decidim/pull/2661)
- **decidim-comments**: Fix comment notifications listing. [\#2652](https://github.com/decidim/decidim/pull/2652)
- **decidim-participatory_processes**: Fix editing a process after an error.[\#2653](https://github.com/decidim/decidim/pull/2653)
- **decidim-assemblies**: Fix editing a process after an error.[\#2653](https://github.com/decidim/decidim/pull/2653)
- **decidim-core**: Fix missing i18n strings for "Feature published" events. [\#2729](https://github.com/decidim/decidim/pull/2729)

Please check [0.9-stable](https://github.com/decidim/decidim/blob/0.9-stable/CHANGELOG.md) for previous changes.
