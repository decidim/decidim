# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

**Added**:

- **decidim-meetings**: Add Minutes entity to manage Minutes. [\#3213](https://github.com/decidim/decidim/pull/3213)

**Changed**:

- **decidim-core**: Force user_group.name uniqueness in user_group test factory. (https://github.com/decidim/decidim/pull/3290)
- **decidim-admin**: Admins no longer need to introduce raw json to define options for an authorization workflow. [\#3300](https://github.com/decidim/decidim/pull/3300)

**Fixed**:

- **decidim-accountability**: Fixes linking proposals to results for accountability on creation time. [\#3167](https://github.com/decidim/decidim/pull/3262)
- **decidim-proposals**: Fixes clicking on "see all" should remove the ellipsis sign. [\#2894](https://github.com/decidim/decidim/pull/3238)
- **decidim-proposals**: Ignore already imported proposals when importing them [\#3257](https://github.com/decidim/decidim/pull/3257)
- **decidim-proposals**: Fixes clicking on "see all" should remove the ellipsis sign. [\#3238](https://github.com/decidim/decidim/pull/3238)
- **decidim-core**: Add missing locales in Freanch fot the datepicker [\#3260](https://github.com/decidim/decidim/pull/3260)
- **decidim-proposals**: Fixes clicking on "see all" should remove the ellipsis sign. \#2894](https://github.com/decidim/decidim/pull/3238)
- **decidim-proposals**: Restore creation date in proposal detail page. [\#3249](https://github.com/decidim/decidim/pull/3249)
- **decidim-proposals**: Fix threshold_per_proposal method positive? for nil:NilClass when threshold is null or not defined. [\#3185](https://github.com/decidim/decidim/pull/3185)
- **decidim-proposals**: Make sure threshold per proposal has the right value in existing components [\#3235](https://github.com/decidim/decidim/pull/3235)
- **decidim-proposals**: Fix when I create a proposal I see the draft proposal from someone else! [\#3170](https://github.com/decidim/decidim/pull/3083)
- **decidim-proposals**: Fix view hooks returning proposals that should not be shown [\#3175](https://github.com/decidim/decidim/pull/3175)
- **decidim-debates**: Fix debates times. [\#3071](https://github.com/decidim/decidim/pull/3071)
- **decidim-proposals**: Fix Feedback needed after Endorsing when user has no user_groups [\#2968](https://github.com/decidim/decidim/pull/2998)
- **decidim-proposals**: Fix threshold absolute view and rename the field maximum_votes_per_proposal to threshold_per_proposal. [\#2994](https://github.com/decidim/decidim/pull/2994)
- **decidim-proposals**: Fix proposal endorsed event [\#2970](https://github.com/decidim/decidim/pull/2970)
- **decidim-accountability**: Fix parent results progress [\#2954](https://github.com/decidim/decidim/pull/2954)
- **decidim-core**: Fix `Decidim::UserPresenter#nickname` [\#2958](https://github.com/decidim/decidim/pull/2958)
- **decidim-verifications**: Only show authorizations from current organization [\#2959](https://github.com/decidim/decidim/pull/2959)
- **decidim-comments**: Fix mentions not working properly.  [\#2947](https://github.com/decidim/decidim/pull/2947)
- **decidim-proposals**: Fix proposal endorsed event  generation [\#2983](https://github.com/decidim/decidim/pull/2983)
- **decidim-core**: foundation-rails 6.4.3 support [\#2995](https://github.com/decidim/decidim/pull/2995)
- **decidim-surveys**: Fix errored questions being re-rendered with disabled inputs [\#3014](https://github.com/decidim/decidim/pull/3014)
- **decidim-surveys**: Fix errored questions rendering answer options as empty fields [\#3014](https://github.com/decidim/decidim/pull/3014)
- **decidim-surveys**: Fix translated fields of freshly created questions not working after form errors [\#3026](https://github.com/decidim/decidim/pull/3026)
- **decidim-surveys**: Fix question form errors not being displayed [\#3046](https://github.com/decidim/decidim/pull/3046)
- **decidim-admin**: Require organization's `reference_prefix` at the form level [\#3056](https://github.com/decidim/decidim/pull/3056)
- **decidim-core**: Only require caps on the first line with `EtiquetteValidator` [\#3072](https://github.com/decidim/decidim/pull/3072)
- **decidim-proposals**: Fix notification sent when proposal draft was created, now sent on publish. [\#3065](https://github.com/decidim/decidim/pull/3065)
- **decidim-surveys**: Multiple choice questions without answer options can no longer be created [\#3087](https://github.com/decidim/decidim/pull/3087)
- **decidim-surveys**: Multiple choice questions with empty answer options can no longer be created [\#3087](https://github.com/decidim/decidim/pull/3087)
- **decidim-surveys**: Preserve deleted status of questions accross submission failures [\#3089](https://github.com/decidim/decidim/pull/3089)
- **decidim-surveys**: Question type selector not disabled when survey has already been answered [\#3133](https://github.com/decidim/decidim/pull/3133)
- **decidim-surveys**: Max choices selector not disabled when survey has already been answered [\#3133](https://github.com/decidim/decidim/pull/3133)
- **decidim-surveys**: Translated fields not disabled when survey has already been answered [\#3133](https://github.com/decidim/decidim/pull/3133)
- **decidim-admin**: Default managed user form displaying two buttons [\#3211](https://github.com/decidim/decidim/pull/3211)
- **decidim-admin**: Dropdown menus appearance on hover [\#3241](https://github.com/decidim/decidim/pull/3241)
- **decidim-admin**: Ability to select leaf categories from Admin change-category bulk action [\#3243](https://github.com/decidim/decidim/pull/3243)
- **decidim-admin**: Highlighted banner image is not required if already present in the organization [\#3244](https://github.com/decidim/decidim/pull/3244)
- **decidim-proposals**: Keep the user group (if set) as default value of author field on forms [\#3247](https://github.com/decidim/decidim/pull/3247)
- **decidim-participatory_processes**: Remove duplicated space title on page meta tags [\#3278](https://github.com/decidim/decidim/pull/3278)
- **decidim-assemblies**: Remove duplicated space title on page meta tags [\#3278](https://github.com/decidim/decidim/pull/3278)

**Removed**:

Please check [0.11-stable](https://github.com/decidim/decidim/blob/0.11-stable/CHANGELOG.md) for previous changes.
