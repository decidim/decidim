# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

**Upgrade notes**:

**Added**:

**Changed**:

**Fixed**:

- **decidim-participatory_processes and decidim-core**: Participatory processes not being imported properly. [\#5596](https://github.com/decidim/decidim/pull/5596)
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

**Removed**:

## Previous versions

Please check [0.20-stable](https://github.com/decidim/decidim/blob/0.19-stable/CHANGELOG.md) for previous changes.
