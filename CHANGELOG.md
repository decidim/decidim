# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

### Upgrade notes

- **New "extras" key in authorization metadata**

[\#6097](https://github.com/decidim/decidim/pull/6097) adds the possibility to have an "extras" key in the Authentication metadata that will be ignored. For example when
signing an initiative (decidim-initiatives/app/forms/decidim/initiatives/vote_form.rb) or on Authorization renewal (decidim-verifications/app/cells/decidim/verifications/authorization_metadata/show.erb).

This key may be used to persist whatever information related to the user's authentication that should not be used for authenticating her.
The use case that originated this change is the persistence of the user's gender for statistical uses.

### Added

- **decidim-api**: Use organization time zone [\#6112](https://github.com/decidim/decidim/pull/6112)
- **decidim-initiatives**: Ignore new "extras" key when checking authorization/variation metadata [\#6097](https://github.com/decidim/decidim/pull/6097)

### Changed

### Fixed

- **decidim-proposals**: Fix participatory text newline absence. [\#6159](https://github.com/decidim/decidim/pull/6159)
- **decidim-core**: Fix broken puma version in generator's Gemfile. [\#6060](https://github.com/decidim/decidim/pull/6060)
- **decidim-core,decidim-system**: Fix using Decidim as a provider for omniauth authentication. [\#6081](https://github.com/decidim/decidim/pull/6081)

### Removed

## [v0.21.0](https://github.com/decidim/decidim/releases/tag/v0.21.0)

### Deprecation warnings

PR [\#5676](https://github.com/decidim/decidim/pull/5676) introduced a deprecation warning:

- `Decidim::ParticipatorySpaceResourceable#link_participatory_spaces_resources` should be renamed to `link_participatory_space_resources` (notice singular `spaces`)

PR [\#5768](https://github.com/decidim/decidim/pull/5768) introduced a deprecation warning:

- `:here_app_id` and `:here_app_code` that might be configured in `config/initializers/decidim.rb` are no longer valid authorization key-values for the HERE Maps API. Now it is required to generate and API key using the keyword `:here_api_key` to replace the old ones:

`config/initializers/decidim.rb`:

```ruby
  Geocoder configuration
    config.geocoder = {
    #...
      here_api_key: Rails.application.secrets.geocoder[:here_api_key],
    #...
  }
```

### Upgrade notes

- **Omniauth settings for each tenant**

Thanks to [\#5516](https://github.com/decidim/decidim/pull/5516) it is now possible to customize which omniauth providers are enabled on each of the organizations in a multitenant installation.

This modification changes the way Devise omniauth providers are activated. It is now automatic, so all providers declared in the secrets file are loaded into `Decidim::OmniauthProvider#available` and then activated in `Decidim::User` `devise` declaration.

If you want to enable sign up through social providers like Facebook you will need to generate app credentials and store them in one of the following places:

- In the Rails secrets file: `config/secrets.yml`. This configuration will be shared by all tenants.
- In the organization's configuration (ex. system/organizations/1/edit). This configuration overrides the one in `config/secrets.yml`.

Take into account that for a social provider integration to appear in the organization form, it must also be defined in `config/secrets.yml` (but the values are optional). For example:

```yaml
twitter:
  enabled: false # disabled by default, unless activated in the organization
  api_key:
  api_secret:
```

Installations with custom Omniauth providers must remove the provider configuration from the corresponding `config/initializer/omniauth_xxx.rb` (just remove the whole file if it is the only thing declared there). Then copy the required values in `config/secrets.yml` or go to `yourinstallation.tld/system` to configure the valid values for the tenant (this requires to have at least the provider with `enabled: false` in the `config/secrets.yml`).

```
# The following should be removed from any initializer or Rails will crash when starting
if Rails.application.secrets.dig(:omniauth, :decidim, :enabled)
  Devise.setup do |config|
    config.omniauth :decidim,
                    Rails.application.secrets.dig(:omniauth, :decidim, :client_id),
                    Rails.application.secrets.dig(:omniauth, :decidim, :client_secret),
                    Rails.application.secrets.dig(:omniauth, :decidim, :site_url),
                    scope: :public
  end
end
Decidim::User.omniauth_providers << :decidim
```

Maintainers of custom omniauth providers will need to add translations for the translatable settings names in organization's system administration panel, see https://github.com/decidim/decidim/pull/6042 for context.

Documentation regarding oauth providers has been updated: https://github.com/decidim/decidim/blob/develop/docs/services/social_providers.md

- **Geocoder**

Here maps API has changed, including the way clients authenticate. Thus, former `app_id` and `app_code` credentials are now deprecated in favour of a unique `api_key` token. For your current application to continue working with Here maps services generate an `api_key` and configure it as explained in [Decidim's geocoding documentation](https://github.com/decidim/decidim/blob/master/docs/services/geocoding.md).

If you would like to stay with the old api (app_id + app_code), you should force `geocoder` gem version to `1.5.2` in your application. This is because `geocoder v1.6.0` only supports the new Here api (app_key).

Here is a summary of the different configurations depending on the Here api that is going to be used.

Old/legacy Here api:

- geocoder 1.5
- initializer with:
  - `here_app_code`
  - `here_app_id`
  - `static_map_url:` "https://image.maps.cit.api.here.com/mia/1.6/mapview"

New Here api:

- geocoder >= 1.6
- initializer with:
  - `here_api_key`
  - `static_map_url:` "https://image.maps.ls.hereapi.com/mia/1.6/mapview"

- **Assembly types**

In order to prevent errors while upgrading multi-servers envirnoments, the fields `assembly_type` and `assembly_type_other` are maintained. Future releases will take care of this.

- **Organization Time Zones**

Now is its possible to configure every organization (tenant) with a different time zone by any admin in the global configuration. We recommend to not define any specific `config.time_zone` in Rails so it uses UTC internally. In any case Rails configuration will be ignored in the context of the controller (users will be using always organization's configured time zone).

To upgrade it is recommended to configured the proper time zone in the admin for the organization and remove any `config.time_zone` personalization in Rails (unless you know what you are doing).

For those who have not changed the Rails `config.time_zone` (thus using UTC globally) but using dates as if they were non-UTC zones might notice that changing the organization time zone will shift all presented dates accordingly. This might require to re-edit any scheduled date in meetings or debates in order be properly displayed.

- **Data portability**

Thanks to [#5342](https://github.com/decidim/decidim/pull/5342), Decidim now supports removal of user's data portability expired files from Amazon S3. Check out the [scheduled tasks in the getting started guide](https://github.com/decidim/decidim/blob/master/docs/getting_started.md#scheduled-tasks) for information in how to configure it.

**Added**:

- **decidim-core**: Add new language: Greek [#5597](https://github.com/decidim/decidim/pull/5597)
- **decidim-initiatives**: An admin can only send the initiative to technical validation if it has enough committee members. [\#5762](https://github.com/decidim/decidim/pull/5762)
- **decidim-proposals**: Add images to proposal cards [\#5640](https://github.com/decidim/decidim/pull/5640)
- **decidim-api**: Added documentation to use the API (newcomers friendly). [\#5582](https://github.com/decidim/decidim/pull/5582)
- **decidim-blogs**: GraphQL API: Complete Blogs specification. [\#5569](https://github.com/decidim/decidim/pull/5569)
- **decidim-debates**: GraphQL API: Complete Debates specification. [\#5570](https://github.com/decidim/decidim/pull/5570)
- **decidim-surveys**: GraphQL API: Complete Surveys specification. [\#5571](https://github.com/decidim/decidim/pull/5571)
- **decidim-sortitions**: GraphQL API: Complete Sortitions specification. [\#5583](https://github.com/decidim/decidim/pull/5583)
- **decidim-accountability**: GraphQL API: Complete Accountability specification. [\#5584](https://github.com/decidim/decidim/pull/5584)
- **decidim-budgets**: GraphQL API: Complete Budgets specification. [\#5585](https://github.com/decidim/decidim/pull/5585)
- **decidim-assemblies**: GraphQL API: Create fields for assemblies types and specs. [\#5544](https://github.com/decidim/decidim/pull/5544)
- **decidim-core**: Add search and order capabilities to the GraphQL API. [\#5586](https://github.com/decidim/decidim/pull/5586)
- **documentation**: Added documentation in how Etherpad Lite integrates with the Meetings component. [\#5652](https://github.com/decidim/decidim/pull/5652)
- **decidim-meetings**: GraphQL API: Complete Meetings specification. [\#5563](https://github.com/decidim/decidim/pull/5563)
- **decidim-meetings**: Follow a meeting on registration [\#5615](https://github.com/decidim/decidim/pull/5615)
- **decidim-admin**, **decidim-assemblies**, **decidim-conferences**, **decidim-consultations**, **decidim-core**, **decidim-initiatives**, **decidim-participatory_processes**, **decidim-proposals**: Add filters, search and pagination to participatory spaces in admin panel. [\#5558](https://github.com/decidim/decidim/pull/5558)
- **decidim-admin**: Extend search, add pagination and change filters styling to participants/officializations in the admin panel. [\#5558](https://github.com/CodiTramuntana/decidim/pull/5558)
- **decidim-admin**: Added filters, search and pagination into admin proposals. [\#5503](https://github.com/decidim/decidim/pull/5503)
- **decidim-consultations**: GraphQL API: Create fields for consultations types and specs. [\#5550](https://github.com/decidim/decidim/pull/5550)
- **decidim-conferences**: GraphQL API: Create fields for conferences types and specs. [\#5551](https://github.com/decidim/decidim/pull/5551)
- **decidim-initiatives**: GraphQL API: Create fields for initiatives types and specs. [\#5544](https://github.com/decidim/decidim/pull/5549)
- **decidim-proposals**: GraphQL API: Complete Proposals specification. [\#5537](https://github.com/decidim/decidim/pull/5537)
- **decidim-participatory_processes**: GraphQL API: Add participatory process groups specification. [\#5540](https://github.com/decidim/decidim/pull/5540)
- **decidim-participatory_processes**: GraphQL API: Complete fields for participatory processes. [\#5562](https://github.com/decidim/decidim/pull/5562)
- **decidim-admin** Add terms of use for admin. [#5507](https://github.com/decidim/decidim/pull/5507)
- **decidim-assemblies**: Added configurable assembly types. [\#5616](https://github.com/decidim/decidim/pull/5616)
- **decidim-core**: Added configurable time zones for every tenant (organization). [\#5607](https://github.com/decidim/decidim/pull/5607)
- **decidim-admin**: Display the number of participants subscribed to a newsletter. [\#5555](https://github.com/decidim/decidim/pull/5555)
- **decidim-accountability**, **decidim-admin**, **decidim-budgets**, **decidim-core**, **decidim-debates**, **decidim-generators**, **decidim-meetings**, **decidim-proposals**, **decidim_app-design**: Change: Extend the capabilities of the Quill text editor. [\#5488](https://github.com/decidim/decidim/pull/5488)
- **decidim-core**: Add docs in how to fix metrics problems. [\#5587](https://github.com/decidim/decidim/pull/5587)
- **decidim-core**: Data portability now supports AWS S3 storage. [\#5342](https://github.com/decidim/decidim/pull/5342)
- **decidim-system**: Permit customizing omniauth settings for each tenant [#5516](https://github.com/decidim/decidim/pull/5516)
- **decidim-core**: Add the `nofollow` value to the `rel` attribute on parsed links [\#5651](https://github.com/decidim/decidim/pull/5651)
- **decidim-proposals**: Allow admins to set a predefined template [\#5613](https://github.com/decidim/decidim/pull/5613)
- **decidim-comments**: Let users check a single comment in a commentable resource [#5662](https://github.com/decidim/decidim/pull/5662)
- **decidim-participatory-processes**: Link processes and only show published ones [#5676](https://github.com/decidim/decidim/pull/5676)
- **decidim-proposals**: Automatically link proposals and meetings when creating a proposal authored by a meeting [\#5674](https://github.com/decidim/decidim/pull/5674)
- **decidim-proposals**: Add proposal page with all info in admin section [\#5671](https://github.com/decidim/decidim/pull/5671)
- **decidim-proposals**: Add a navbar link to answer a proposal in the admin [\#5706](https://github.com/decidim/decidim/pull/5706)
- **decidim-participatory_processes** Statistics and Metrics Improvements[\#5688](https://github.com/decidim/decidim/pull/5688)
- **decidim-proposals** and **decidim-budgets**: Improve navigation and visualization of proposals and projects by scope, category, origin and status [\#5654](https://github.com/decidim/decidim/pull/5654)
- **decidim-proposals**: Let admins add cost reports to proposals [\#5695](https://github.com/decidim/decidim/pull/5695)
- **decidim-conferences**: Add Valuator role [\#5687](https://github.com/decidim/decidim/pull/5687)
- **decidim-initiatives**: Add Valuator role [\#5687](https://github.com/decidim/decidim/pull/5687)
- **decidim-participatory_processes**: Add Valuator role [\#5687](https://github.com/decidim/decidim/pull/5687)
- **decidim-proposals**: Let Valuators only answer and leave private notes on proposals [\#5687](https://github.com/decidim/decidim/pull/5687)
- **decidim-core**: Let exporters filter collection by user triggering the action [\#5687](https://github.com/decidim/decidim/pull/5687)
- **decidim-admin**: Admin can bulk update proposal's scope [\5759](https://github.com/decidim/decidim/pull/5759)
- **decidim-proposals**: Publish proposals anwers at once [\#5810](https://github.com/decidim/decidim/pull/5810)

**Changed**:

- **decidim-dev**: Retry failed test to avoid flaky. [\#5894](https://github.com/decidim/decidim/pull/5894)
- **decidim-core**: Upgrade leaflet-HERE Maps javascript library to use new apiKey authentication method [\#5768](https://github.com/decidim/decidim/pull/5768)
- **decidim-core**: Upgrade geocoder to be able to use the new Here geolocation API. [\#5644](https://github.com/decidim/decidim/pull/5644)
- **decidim-core**: Shorten the 100 chars default last activity cards description lenght to 80 chars [\#5742](https://github.com/decidim/decidim/pull/5742)
- **decidim-core**: Show the number of followers when the button "follow" appears. [\#5593](https://github.com/decidim/decidim/pull/5593)
- **decidim-dev**: Be liberal with Puma's declared version condition. [\#5650](https://github.com/decidim/decidim/pull/5650)
- **decidim-meetings**: Add width and height to meetings component icon [\#5614](https://github.com/decidim/decidim/pull/5614)
- **decidim-proposals**: Versions box is removed and placed after the reference ID, and using the same styles. [\#5594](https://github.com/decidim/decidim/pull/5594)
- **decidim-participatory_processes**, **decidim-conferences**, **decidim-assemblies**, **decidim-initiatives**: Use cardM cell in space embed [#5589](https://github.com/decidim/decidim/pull/5589)
- **decidim-proposals**: Update tags layout in proposal page [\#5646](https://github.com/decidim/decidim/pull/5646)
- **decidim-comments**: Hide and show comment threads [#5655](https://github.com/decidim/decidim/pull/5655)
- **decidim-core**: Amendable resources can react to amendment state changes [#5703](https://github.com/decidim/decidim/pull/5703)

**Fixed**:

- **decidim-admin**: Fix: let components without step settings be added [\#6144](https://github.com/decidim/decidim/pull/6144)
- **decidim-core** Patch various security alerts reported by GitHub. [\#6149](https://github.com/decidim/decidim/pull/6149)
- **decidim-debates**: Fix a notification failure when the creating a new debate event is fired. [\#6017](https://github.com/decidim/decidim/pull/6017)
- **decidim-proposals**: Fix proposals that have their state not published. [\#5833](https://github.com/decidim/decidim/pull/5833)
- **decidim-core** adapt API classes to the release of the graphql gem v1.10.4 [\#5829](https://github.com/decidim/decidim/pull/5829)
- **decidim-core** Fixes the integration between the use of older and new versions of geocoder using HERE maps [\#5822](https://github.com/decidim/decidim/pull/5822)
- **decidim-core** and **decidim-dev**: Solve puma's GHSA-84j7-475p-hp8v vulnerability, and nokogiri's CVE-2020-7595 vulnerability. [\#5820](https://github.com/decidim/decidim/pull/5820)
- **decidim-core**: Do not allow invited users to sign up. [\#5803](https://github.com/decidim/decidim/pull/5803)
- **decidim-initiatives**: Fix initiative state bug [\#5805](https://github.com/decidim/decidim/pull/5805)
- **decidim-admin**, **decidim-proposals**: Fix proposal card layout. [\#5783](https://github.com/decidim/decidim/pull/5783)
- **decidim-core**: [FIX] Add description pop up required [\#5771](https://github.com/decidim/decidim/pull/5771)
- **decidim-admin**: Fixed css visual issues with dynamic filters. [\#5801](https://github.com/decidim/decidim/pull/5801)
- **decidim-admin**: Fixed dynamic filters showing ID. [\#5786](https://github.com/decidim/decidim/pull/5786)
- **decidim-comments**: Fix rendering up to 4 levels of comments. [\#5707](https://github.com/decidim/decidim/pull/5707)
- **decidim-proposals**: Render rich text in Proposals originated in Meetings. [\#5705](https://github.com/decidim/decidim/pull/5705)
- **decidim-admin**: Avoid user_manager permissions to shadow space admin permissions. [\#5698](https://github.com/decidim/decidim/pull/5698)
- **decidim-core**: Fix: display the correct google brand log in omniauth login view. [\#5685](https://github.com/decidim/decidim/pull/5685)
- **decidim-core**: Fix \#5342, when the fog provider is aws there were some fixes to be done. [\#5660](https://github.com/decidim/decidim/pull/5660)
- **decidim-participatory_processes and decidim-core**: Participatory processes not being imported properly. [\#5596](https://github.com/decidim/decidim/pull/5596)
- **decidim-api**: Fix a missing asset in the API documentation.  [\#5693](https://github.com/decidim/decidim/pull/5693)
- **decidim-core**: Fix 4 accessibility warnings generated by Google Chrome.  [\#5299](https://github.com/decidim/decidim/pull/5299)
- **decidim-core**: Fix: display the correct google brand log in omniauth login view. [\#5685](https://github.com/decidim/decidim/pull/5685)
- **decidim-core**: Fix: Apply google webmaster guidelines for buttons "sign with Google".[\#5592](https://github.com/decidim/decidim/pull/5592)
- **decidim-verifications**: Fix: Missing method email_regexp [\#5560](https://github.com/decidim/decidim/pull/5560)
- **decidim-core**: Fix: use incrementing date when rebuilding since one date. [\#5541](https://github.com/decidim/decidim/pull/5541)
- **decidim-core**: Expand top-level navigation on mobile by default [#5580](https://github.com/decidim/decidim/pull/5580)
- **decidim-proposals**: Filtering by state working when searching amendments [#5703](https://github.com/decidim/decidim/pull/5703)
- **decidim-core**: Fix: Display values on translated fields with hashtaggable option on edit forms [#5661](https://github.com/decidim/decidim/pull/5661)
- **decidim-core**: Fix: use of browse history with filters [#5749](https://github.com/decidim/decidim/pull/5749)
- **decidim-budgets**: Add a missing fix applied to proposals in [\#5654](https://github.com/decidim/decidim/pull/5654) but not to projects [\#5743](https://github.com/decidim/decidim/pull/5743)
- **decidim-proposals**: Admin: fix "Answer Proposal" action tooltip [/#5750](https://github.com/decidim/decidim/pull/5750)
- **decidim-proposals**: Fix relative path in mentioned proposal email [\#5852](https://github.com/decidim/decidim/pull/5852)

**Removed**:

### Previous versions

Please check [0.20-stable](https://github.com/decidim/decidim/blob/0.20-stable/CHANGELOG.md) for previous changes.
