# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

**Upgrade notes (search)**:

In order for the currently existing Users to be indexed, you'll have to manually trigger a reindex. You can do that executing:

```ruby
Decidim::User.find_each(&:add_to_index_as_search_resource)
```

**Added**:

- **decidim-docs**: Add proposal lifecycle diagram to docs. [\#3811](https://github.com/decidim/decidim/pull/3811)
- **decidim-budgets**: Added vote project authorization action [\#3804](https://github.com/decidim/decidim/pull/3804)
- **decidim-meetings**: Added join meeting authorization action [\#3804](https://github.com/decidim/decidim/pull/3804)
- **decidim-proposals**: Added vote and endorse proposal authorization actions [\#3804](https://github.com/decidim/decidim/pull/3804)
- **decidim-core**: Support for actions authorizations at resource level [\#3804](https://github.com/decidim/decidim/pull/3804)
- **decidim-meetings**: Allow users to accept or reject invitations to meetings, and allow admins to see their status. [\#3632](https://github.com/decidim/decidim/pull/3632)
- **decidim-meetings**: Allow admins to invite existing users to meetings. [\#3831](https://github.com/decidim/decidim/pull/3831)
- **decidim-meetings**: Generate a registration code and give it to users when they join to the meeting. [\#3805](https://github.com/decidim/decidim/pull/3805)
- **decidim-core**: Make Users Searchable. [\#3796](https://github.com/decidim/decidim/pull/3796)
- **decidim-participatory_processes**: Highlight the correct menu item when visiting a process group page [\#3737](https://github.com/decidim/decidim/pull/3737)

**Changed**:

- **decidim-participatory_processes**: Improve usability of filters on processes index page [\#3728](https://github.com/decidim/decidim/pull/3728)
- **decidim-meetings**: The invite attendee form has been moved to the top of the new invites list. [\#3826](https://github.com/decidim/decidim/pull/3826)
- **decidim-core**: Load authorization modals content with AJAX requests. [\#3753](https://github.com/decidim/decidim/pull/3753)
- **decidim-core**: Updated the `CollapsibleList` cell to be able to show any number of elements from 1 to 12 [\#3810](https://github.com/decidim/decidim/pull/3810)

**Fixed**:

- **decidim-proposals**: Fix Endorse button broken if endorse action is authorized. [\#3875](https://github.com/decidim/decidim/pull/3875)
- **decidim-proposals**: Refactor searchable proposal test to avoid flakes. [\#3825](https://github.com/decidim/decidim/pull/3825)
- **decidim-proposals**: Proposal seeds iterate over a sample of users to add coauthorships. [\#3796](https://github.com/decidim/decidim/pull/3796)
- **decidim-core**: Make proposal m-card render its authorship again. [\#3727](https://github.com/decidim/decidim/pull/3727)
- **decidim-generators**: Generated application not including bootsnap.
- **decidim-generators**: Generated application not including optional gems.
- **decidim-core**: Fix follow within search results. [\#3745](https://github.com/decidim/decidim/pull/3745)
- **decidim-proposals**: An author should always follow their proposal. [\#3791](https://github.com/decidim/decidim/pull/3791)
- **decidim-core**: Fix notifications sending when there's no component. [\#3792](https://github.com/decidim/decidim/pull/3792)
- **decidim-proposals**: Use the same proposals collection for the map. [\#3793](https://github.com/decidim/decidim/pull/3793)
- **decidim-core**: Fix followable type for Decidim::Accountability::Result. [\#3798](https://github.com/decidim/decidim/pull/3798)
- **decidim-accountability**: Fix accountability diff renderer when a locale is missing. [\#3797](https://github.com/decidim/decidim/pull/3797)
- **decidim-core**: Don't crash when a nickname has a dot. [\#3793](https://github.com/decidim/decidim/pull/3793)
- **decidim-core**: Don't crash when a page doesn't exist. [\#3799](https://github.com/decidim/decidim/pull/3799)
- **decidim-admin**: Paginate private users. [\#3871](https://github.com/decidim/decidim/pull/3871)
- **decidim-surveys**: Order survey answer options by date and time. [#3867](https://github.com/decidim/decidim/pull/3867)
- **decidim-core**: Set `organization.tos_version` when creating `terms-and-conditions` DefaultPage [#3882](https://github.com/decidim/decidim/pull/3882)
- **decidim-comments**: Users should never be notified about their own comments. [\#3888](https://github.com/decidim/decidim/pull/3888)
- **decidim-core**: Consider only users in profile follow counters. [\#3887](https://github.com/decidim/decidim/pull/3887)
- **decidim-assembly**: Fix Non private users can participate to a private, transparent assembly [\#3438](https://github.com/decidim/decidim/pull/3438)
- **decidim-proposals**: Fixes artificial margin between proposal "header" and list of endorsements. [\#2893](https://github.com/decidim/decidim/pull/2893)
- **decidim-proposals**: Use translations for hardcoded text. [\#3464](https://github.com/decidim/decidim/pull/3464)
- **decidim-core**: Include datepicker locales in front pages too. [\#3448](https://github.com/decidim/decidim/pull/3448)
- **decidim-core**: Uses current organization scopes in scopes picker. [\#3386](https://github.com/decidim/decidim/pull/3386)
- **decidim-blog**: Add `params[:id]` when editing/deleting a post from admin site [\#3329](https://github.com/decidim/decidim/pull/3329)
- **decidim-admin**: Fixes the validation uniqueness name of area, scoped with organization and area_type [\#3336](https://github.com/decidim/decidim/pull/3336) https://github.com/decidim/decidim/pull/3336
- **decidim-core**: Fix `Resourceable` concern to only find linked resources from published components. [\#3433](https://github.com/decidim/decidim/pull/3433)
- **decidim-accountability**: Fixes linking proposals to results for accountability on creation time. [\#3167](https://github.com/decidim/decidim/pull/3262)
- **decidim-proposals**: Fixes clicking on "see all" should remove the ellipsis sign. [\#2894](https://github.com/decidim/decidim/pull/3238)
- **decidim-participatory_processes**: Remove duplicated space title on page meta tags [\#3278](https://github.com/decidim/decidim/pull/3278)
- **decidim-assemblies**: Remove duplicated space title on page meta tags [\#3278](https://github.com/decidim/decidim/pull/3278)
- **decidim-core**: Add validation to nickname's length. [\#3342](https://github.com/decidim/decidim/pull/3342)
- **decidim-core**: Deactivate notifications bell when marking all as read [\#3509](https://github.com/decidim/decidim/pull/3509)
- **decidim-surveys**: Fix a N+1 in surveys [\#3497](https://github.com/decidim/decidim/pull/3497)
- **decidim-initiatives**: Fix user signing of initiatives [\#3513](https://github.com/decidim/decidim/pull/3513)
- **decidim-core**: Make admin link on user menu stop disappearing [\#3508](https://github.com/decidim/decidim/pull/3508)
- **decidim-core**: Sort static pages by title [\#3479](https://github.com/decidim/decidim/pull/3479)
- **decidim-core**: Data picker form inputs having no bottom margin. [\#3463](https://github.com/decidim/decidim/pull/3463)
- **decidim-core**: Make signup forms show the password confirmation field as required[\#3521](https://github.com/decidim/decidim/pull/3521)
- **decidim-core**: Fix default page creation so they get scoped to the actual organization [\#3526](https://github.com/decidim/decidim/pull/3526)
- **decidim-consultations**: Do not allow votes on upcoming consultations [\#3529](https://github.com/decidim/decidim/pull/3529)
- **decidim-accountability**: Fix results string in the home [\#3537](https://github.com/decidim/decidim/pull/3537)

**Removed**:

## Previous versions

Please check [0.13-stable](https://github.com/decidim/decidim/blob/0.13-stable/CHANGELOG.md) for previous changes.
