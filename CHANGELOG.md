# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

### Deprecation warnings

PR [\#5676](https://github.com/decidim/decidim/pull/5676) introduced a deprecation warning:

- `Decidim::ParticipatorySpaceResourceable#link_participatory_spaces_resources` should be renamed to `link_participatory_space_resources` (notice singular `spaces`)

PR [\#5768](https://github.com/decidim/decidim/pull/5768) introduced a deprecation warning:

- `:here_app_id ` and `:here_app_code` that might be configured in `config/initializers/decidim.rb` are no longer valid authorization key-values for the HERE Maps API. Now it is required to generate and API key using the keyword `:here_api_key` to replace the old ones:

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

#### SocialShareButton
- **Geocoder**

Here maps API has changed, including the way clients authenticate. Thus, former `app_id` and `app_code` credentials are now deprecated in favour of a unique `api_key` token. For your current application to continue working with Here maps services generate an `api_key` and configure it as explained in [Decidim's geocoding documentation](https://github.com/decidim/decidim/blob/master/docs/services/geocoding.md).

If you would like to stay with the old api (app_id + app_code), you should force `geocoder` gem version to `1.5.2` in your application. This is because `geocoder v1.6.0` only supports the new Here api (app_key).

Here is a summary of the different configurations depending on the Here api that is going to be used.

Old/legacy Here api:

- geocoder 1.5
- initializer with:
  - app_code
  - app_id
  - static_map_url: "https://image.maps.cit.api.here.com/mia/1.6/mapview"

New Here api:

- geocoder 1.
- initializer with:
  - api_key
  - static_map_url: "https://image.maps.cit.api.here.com/mia/1.6/mapview"

- **Assembly types**

In order to prevent errors while upgrading multi-servers envirnoments, the fields `assembly_type` and `assembly_type_other` are maintained. Future releases will take care of this.

Due to [#5270](https://github.com/decidim/decidim/pull/5270), the SocialShareButton gem [default configuration](https://github.com/CodiTramuntana/decidim/blob/master/decidim-generators/lib/decidim/generators/app_templates/social_share_button.rb) that decidim uses has changed so you'll want to update your configuration accordingly.

#### Decidim::Searchable

Due to [#5469](https://github.com/decidim/decidim/pull/5469), in order for the newly searchable entities to be indexed, you'll have to manually trigger a reindex. You can do that by running in the rails console:

```ruby
Decidim::Assembly.find_each(&:add_to_index_as_search_resource)
Decidim::ParticipatoryProcess.find_each(&:add_to_index_as_search_resource)
Decidim::Conference.find_each(&:add_to_index_as_search_resource)
Decidim::Consultation.find_each(&:add_to_index_as_search_resource)
Decidim::Initiative.find_each(&:add_to_index_as_search_resource)
Decidim::Debates::Debate.find_each(&:add_to_index_as_search_resource)
# results are ready to be searchable but don't have a card-m so can't be rendered
# Decidim::Accountability::Result.find_each(&:add_to_index_as_search_resource)
Decidim::Budgets::Project.find_each(&:add_to_index_as_search_resource)
Decidim::Blogs::Post.find_each(&:add_to_index_as_search_resource)
```

**Added**:

- **decidim-core**: Loofah has deprecated the use of WhiteList in favour of SafeList. [\#5576](https://github.com/decidim/decidim/pull/5576)
- **many modules**: Added all spaces and many entities to global search, see Upgrade notes for more detail. [\#5469](https://github.com/decidim/decidim/pull/5469)
- **decidim-core**: Add weight to categories and sort them by that field. [\#5505](https://github.com/decidim/decidim/pull/5505)
- **decidim-proposals**: Add: Additional sorting filters for proposals index. [\#5506](https://github.com/decidim/decidim/pull/5506)
- **decidim-core**: Add a searchable users endpoint to the GraphQL api and enable drop-down @mentions helper in comments. [\#5474](https://github.com/decidim/decidim/pull/5474)
- **decidim-consultations**: Create groups of responses in multi-choices question consultations. [\#5387](https://github.com/decidim/decidim/pull/5387)
- **decidim-core**, **decidim-participatory_processes**: Export/import space components feature, applied to for ParticipatoryProcess. [#5424](https://github.com/decidim/decidim/pull/5424)
- **decidim-participatory_processes**: Export/import feature for ParticipatoryProcess. [#5422](https://github.com/decidim/decidim/pull/5422)
- **decidim-surveys**: Added a setting to surveys to allow unregistered (aka: anonymous) users to answer a survey. [\#4996](https://github.com/decidim/decidim/pull/4996)
- **decidim-core**: Added Devise :lockable to Users [#5478](https://github.com/decidim/decidim/pull/5478)
- **decidim-meetings**: Added help texts for meetings forms to solve doubts about Geocoder fields. [\# #5487](https://github.com/decidim/decidim/pull/5487)

**Changed**:

- **decidim-core**: Wait to upgrade geocoder due to lacking compatile leaflet-tilelayer-here plugin, it has been solved in next release. [\#5815](https://github.com/decidim/decidim/pull/5815)
- **decidim-proposals, decidim-debates and decidim-initiatives**: Improved visiblity of buttons: new proposal, debate and initiative. [\#5535](https://github.com/decidim/decidim/pull/5535)
- **decidim-proposals**: Add a filter "My proposals" at the list of proposals. [\#5512](https://github.com/decidim/decidim/pull/5512)
- **decidim-meetings**: Change: @meetings_spaces collection to use I18n translations [#5494](https://github.com/decidim/decidim/pull/5494)
- **decidim-core**: Add @ prefix to the nickname field in the registration view. [\#5482](https://github.com/decidim/decidim/pull/5482)
- **decidim-core**: Introduce the ActsAsAuthor concern. [\#5482](https://github.com/decidim/decidim/pull/5482)
- **decidim-core**: Extract footers into partials. [#5461](https://github.com/decidim/decidim/pull/5461)
- **decidim-initiatives**: UX improvements to initiatives [#5369](https://github.com/decidim/decidim/pull/5369)
- **decidim-core**: Update to JQuery 3 [#5433](https://github.com/decidim/decidim/pull/5433)
- **decidim_participatory_process**: Admin: move `:participatory_process_groups` from `:main_menu` to `:participatory_processes` `:secondary_nav`[#5545](https://github.com/decidim/decidim/pull/5545)
- **decidim-core**: Remove the Continuity badge [#5565](https://github.com/decidim/decidim/pull/5565)
- **decidim-core**: Remove resizing for banner images [#5567](https://github.com/decidim/decidim/pull/5567)
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

**Removed**:

## Previous versions

Please check [0.19-stable](https://github.com/decidim/decidim/blob/0.19-stable/CHANGELOG.md) for previous changes.
