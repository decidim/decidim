# Change Log

## Unreleased

**Added**:

**Changed**:

**Fixed**:

## [0.10-pre](https://github.com/decidim/decidim/tree/0.10-stable)

**Note**: As per [\#2983](https://github.com/decidim/decidim/pull/2983), if you've been using `0.10.pre` version of Decidim for a while you'll need to fix some values in the database. In order to fix them,  run this script in your Rails console:

```ruby
Decidim::Notification.where(event_class: "Decidim::Proposals::ProposalEndorsedEvent").find_each{|ev| ev.extra = { endorser_id: ev.extra.dig("endorser", "id") }; ev.save! }
```

**Upgrade notes**:

This version has breaking changes, `Decidim::Feature` has been renamed to `Decidim::Component`,
and also everything related to it (controllers, views, etc.). If you have customised some
controller or added a new module you need to rename `feature` to `component`.

**Added**:

- **decidim**: Rename features to components [\#2913](https://github.com/decidim/decidim/pull/2913)
- **decidim-admin**: Log actions on areas [\#2944](https://github.com/decidim/decidim/pull/2944)
- **decidim-budgets**: Log actions on projects [\#2949](https://github.com/decidim/decidim/pull/2949)
- **decidim-meetings**: Log meeting registration exports [\#2922](https://github.com/decidim/decidim/pull/2922)
- **decidim-accountability**: Log results deletion [\#2923](https://github.com/decidim/decidim/pull/2923)

**Changed**:

- **decidim-participatory_processes**: Render documents in first place (before view hooks). [\#2977](https://github.com/decidim/decidim/pull/2977)

**Fixed**:

- **decidim-proposals**: Fix Feedback needed after Endorsing when user has no user_groups [\#2968](https://github.com/decidim/decidim/pull/2998)
- **decidim-core**: FIX Mispelling in available_locales initializer: pr-BR should be pt-BR. [\#2883](https://github.com/decidim/decidim/pull/2883)
- **decidim-admin**: FIX Area and AreaType command specs [\#2859](https://github.com/decidim/decidim/pull/2859)
- **decidim-proposals**: Fix wrong message when creating a proposal private note [\#2769](https://github.com/decidim/decidim/pull/2769)
- **decidim-core**: Fix AuthorEvent when author is missing [\#2777](https://github.com/decidim/decidim/pull/2777)
- **decidim-system**: Disable recover password for System admins. [\#2752](https://github.com/decidim/decidim/pull/2752)
- **decidim-core**: Fix DefaultActionAuthorizer when options is nil [\#2753](https://github.com/decidim/decidim/pull/2753)
- **decidim-core**: Don't render notifications if the resource has been deleted. [\#2746](https://github.com/decidim/decidim/pull/2746)
- **decidim-core**: Fix categories select when missing translations. [\#2742](https://github.com/decidim/decidim/pull/2742)
- **decidim-core**: Don't try to send notification emails to deleted users. [\#2743](https://github.com/decidim/decidim/pull/2743)
- **decidim-core**: Fix notifications list when the resource is a User. [\#2687](https://github.com/decidim/decidim/pull/2687)
- **decidim-core**: Fix mention rendering when there's more than one mention. [\2690](https://github.com/decidim/decidim/pull/2690)
- **decidim-core**: Fix mention parsing to only search users in current organization. [\2710](https://github.com/decidim/decidim/pull/2710)
- **decidim-participatory_processes**: Fix find a process by its ID.[\#2672](https://github.com/decidim/decidim/pull/2672)
- **decidim-assemblies**: Fix find an assembly by its ID.[\#2672](https://github.com/decidim/decidim/pull/2672)
- **decidim-core**: Fix notification mailer when a resource doesn't have an organization. [\#2661](https://github.com/decidim/decidim/pull/2661)
- **decidim-comments**: Fix comment notifications listing. [\#2652](https://github.com/decidim/decidim/pull/2652)
- **decidim-participatory_processes**: Fix editing a process after an error.[\#2653](https://github.com/decidim/decidim/pull/2653)
- **decidim-assemblies**: Fix editing a process after an error.[\#2653](https://github.com/decidim/decidim/pull/2653)
- **decidim-core**: Fix missing i18n strings for "Feature published" events. [\#2729](https://github.com/decidim/decidim/pull/2729)
- **decidim-core**: Fix user invitations by generating their nickname. [\#2783](https://github.com/decidim/decidim/pull/2783)
- **decidim-core**: Fix authorization modals not reopening [\#2811](https://github.com/decidim/decidim/pull/2811)
- **decidim-core**: Fix ugly white stripe under flash message on pages with a picture as main background (such as the homepage) [\#2818](https://github.com/decidim/decidim/pull/2818)
- **decidim-admin**: Fix a bug that lost the scope hierarchy when updating, making the updated scope top-level [\#2853](https://github.com/decidim/decidim/pull/2853)
- **decidim-proposals**: Fix proposals scope not displayed on process group highlighted proposals cards in some cases. [\#2894](https://github.com/decidim/decidim/pull/2894)
- **decidim-admin**: Fix officializations showing all users in the system instead of only the orgsanization ones [\#2912](https://github.com/decidim/decidim/pull/2912)
- **decidim-accountability**: Fix parent results progress [\#2954](https://github.com/decidim/decidim/pull/2954)
- **decidim-core**: Fix `Decidim::UserPresenter#nickname` [\#2958](https://github.com/decidim/decidim/pull/2958)
- **decidim-verifications**: Only show authorizations from current organization [\#2959](https://github.com/decidim/decidim/pull/2959)
- **decidim-proposals**: Fix proposal endorsed event [\#2970](https://github.com/decidim/decidim/pull/2970)
- **decidim-comments**: Fix mentions not working properly. [\#2972](https://github.com/decidim/decidim/pull/2972)
- **decidim-proposals**: Fix proposal endorsed event  generation [\#2983](https://github.com/decidim/decidim/pull/2983)
- **decidim-proposals**: Fix proposal endorsed event [\#2970](https://github.com/decidim/decidim/pull/2970)
- **decidim-accountability**: Fix parent results progress [\#2954](https://github.com/decidim/decidim/pull/2954)
- **decidim-core**: Fix `Decidim::UserPresenter#nickname` [\#2958](https://github.com/decidim/decidim/pull/2958)
- **decidim-verifications**: Only show authorizations from current organization [\#2959](https://github.com/decidim/decidim/pull/2959)
- **decidim-comments**: Fix mentions not working properly.  [\#2947](https://github.com/decidim/decidim/pull/2947)
- **decidim-proposals**: Fix proposal endorsed event  generation [\#2983](https://github.com/decidim/decidim/pull/2983)
- **decidim-core**: foundation-rails 6.4.3 support [\#2995](https://github.com/decidim/decidim/pull/2995)

Please check [0.10-stable](https://github.com/decidim/decidim/blob/0.10-stable/CHANGELOG.md) for previous changes.
