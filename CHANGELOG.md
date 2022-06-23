# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

DEPRECATION NOTE: The `description` field in the categories admin forms has been removed (this applies to any participatory space using categories). For now it's still available in the database, so you can extract it with the following command in the Rails console:

```ruby
Decidim::Category.pluck(:id, :name, :description)
```

In the next version (v0.28.0) it will be fully removed from the database.

### Added


#### Push notifications
PR [\#8774] https://github.com/decidim/decidim/pull/8774 Implements push notifications. Use `rails
decidim:pwa:generate_vapid_keys` to generate the VAPID keys and copy them to your env vars file.
#### Javascript load at the bottom of the pages

PR [\#9156] https://github.com/decidim/decidim/pull/9156 moves javascript snippets to the bottom of `body` sections.

If you are redefining Decidim layout, or partials including javascript packs you might need to review them.

Also, you can no longer call jQuery or any other library in your views directly. For example the
following snippet won't work:

```
<script>
$(() => {
  $(".some-element").addClass("page-loadded");
});
</script>
```

Instead of that, you should encapsulate it in a `content_for(:js_content)` block, that will render the snippet
right after javascript bundles have been loaded.

```
<% content_for(:js_content) do %>
  <script>
    $(() => {
      $(".some-element").addClass("page-loadded");
    });
  </script>
<% end %>
```
#### Upgrade to Ruby 3.0

PR [\#8452] https://github.com/decidim/decidim/pull/8452 has upgraded the required ruby version to 3.0. Upgrading to this version will require either to install the Ruby Version on your host, or change the decidim docker image to use ruby:3.0.2.

#### Rails Upgrade to 6.1
PR [\#8411] https://github.com/decidim/decidim/pull/8411 changes the following:

- ActionMailer - Change default queue name of the deliver (:mailers) job to be the job adapter's default (:default)
- ActiveSupport - Remove deprecated fallback to I18n.default_locale when config.i18n.fallbacks is empty.
  - This change should be transparent for all the Decidim users that have configured the `Decidim.default_locale`

If you are using Spring, it is highly suggested to add the following line at the top of your application's `config/spring.rb` (especially if you are seeing the following messages in the console `ERROR: directory is already being watched!`):

```ruby
require "decidim/spring"
```

#### Dynamic attachment uploads
PR [\#8681] https://github.com/decidim/decidim/pull/8681 Changes the way file uploads work in Decidim. Files are now dynamically uploaded inside the modal so we can give the user immediate feedback on validation. There are now two different types of file fields: titled and untitled. Titled file fields related to ```Decidim::Attachment``` internally.

**To update your module** you probably have to update forms and commands related to upload field (also views should be updated in case of titled attachments). After successful a upload and submitting a form, request params should contain signed_id of [ActiveStorage::Blob](https://api.rubyonrails.org/classes/ActiveStorage/Blob.html) which you need to find the blob at the backend.

To update view with titled file field see example: [edit_form_fields.html.erb](https://github.com/decidim/decidim/pull/8681/files#diff-17a22480fdfa3d439edcb26eb0a1a52bed5521d61ba36e0cc6ca83e838f03e9b)

To update untitled form example: [import_form.rb](https://github.com/decidim/decidim/pull/8681/files#diff-5ce71b5873906c6f8919f4bc1f8c330bd97e8757760705a66c789f375eb743c1)

To update untitled command example: [update_account.rb](https://github.com/decidim/decidim/pull/8681/files#diff-ed1274f76cd0ac1d5b223648dcdae670c2127c7dffa0d38540c1536a86f36abb)

[Learn more about direct uploads](https://edgeguides.rubyonrails.org/active_storage_overview.html#direct-uploads)

#### Moderated content can now be removed from search index
PR [\#8811](https://github.com/decidim/decidim/pull/8811) is addressing an issue when the moderated resources are not removed from the general search index.

This will automatically work for new moderated resources. For already existing ones, we have introduced a new task that will remove the moderated content from being displayed in search:

```ruby
bin/rails decidim:upgrade:moderation:remove_from_search
```

#### Default Decidim app fully configurable via ENV vars

PR [#8725](https://github.com/decidim/decidim/pull/8725) Modifies the default generator to create a new Decidim app (command `decidim my-decidim`).
Once generated, the default initializers allows to setup most of the optional configuration values (such as geolocation, languages, etc) for Decidim entirely via ENV variables.

Documentation is also updated so be sure to check the options in the [Environment Variables](https://docs.decidim.org/en/configure/environment_variables/) doc.

Note that this change does not affect existing installations as only the `config/initializers/decidim.rb` and `config/secrets.yml` files are involved.
However you can migrate to the new structure easily by creating a new Decidim app and copying or adapting those files to your own project.

#### Reminders for pending orders in budgets

**decidim-core**, **decidim-budgets**: Reminders for pending orders in budgets [#8621](https://github.com/decidim/decidim/pull/8621). To generate reminders:

```bash
bundle exec rake decidim:reminders:all
```

Or add cronjob:

```bash
4 0 * * * cd /home/user/decidim_application && RAILS_ENV=production bundle exec rake decidim:reminders:all
```

#### New Comments statistics structure

PR [#8012](https://github.com/decidim/decidim/pull/8012) Participatory space to comments, to fix the statistics. Use
`rake decidim_comments:update_participatory_process_in_comments` to migrate existing comments to the new structure.

#### New Api Documentation engine

PR [\#8631](https://github.com/decidim/decidim/pull/8631) Replaces graphql-docs npm package with gem. In this PR we have also added 3 configurable parameters:

```ruby
# defines the schema max_per_page to configure GraphQL pagination
Decidim::Api.schema_max_per_page = 50

# defines the schema max_complexity to configure GraphQL query complexity
Decidim::Api.schema_max_complexity = 5000

# defines the schema max_depth to configure GraphQL query max_depth
Decidim::Api.schema_max_depth = 15
```

The static documentation will be rendered into : ```app/views/static/api/docs``` which is being refreshed automatically when you will run ```rake decidim:upgrade```.
You can manually regenerate the docs by running: ```rake decidim_api:generate_docs```

#### Global search user by nickname

PR [\#8658](https://github.com/decidim/decidim/pull/8663) Added the ability to search for a user by nickname, to update the existing search, Run in a rails console or create a migration with:

```ruby
  Decidim::User.find_each(&:try_update_index_for_search_resource)
```

Please be aware that it could take a while if your database has a lot of Users.

#### `Decidim::Form`s no longer use `Rectify::Form` and `Virtus` should be no longer used

As per [\#8669](https://github.com/decidim/decidim/pull/8669), your `Decidim::Form`s will no longer use `Rectify::Form` or `Virtus.model` attributes because `Virtus` is discontinued and Decidim is loosening the dependency on the `virtus` gem. Instead, the attributes implementation is now based on [`ActiveModel::Attributes`](https://api.rubyonrails.org/classes/ActiveModel/Attributes/ClassMethods.html) with an integration layer within Decidim that aims to provide as much backwards compatibility as possible with the `Virtus.model` attributes that were previously used.

For most cases, no changes in the code should be needed but there are specific differences with the implementation which may require changes in the 3rd party code as well. Both `Rectify::Form` and `Virtus` will be still available in the core (through the `rectify` gem) but you should migrate away from them as soon as possible as they may be removed in future versions of Decidim.

There are specific things that you need to change regarding your Form or `Virtus.model` classes when migrating to `Decidim::AttributeObject`:

- Change all instances of `YourForm < Rectify::Form` to `YourForm < Decidim::Form`. It should be very rare to find any classes in your code that inherit directly from `Rectify::Form` but in case you have used that, replace those references with `Decidim::Form`.
- Change all instances of `include Virtus.model` to `include Decidim::AttributeObject::Model`.
- For all file objects that may be of type `String` or `ActionDispatch::Http::UploadedFile`, remove the `String` type casting from these attributes as otherwise the uploaded file objects would be converted to strings. In other words, change all `attribute :uploaded_image, String` definitions within the forms to `attribute :uploaded_image` which allows them to be of any type.
- Change all `attribute :attr_name, Hash` to `attribute :attr_name, Hash[Symbol => ExpectedType]` where `ExpectedType` is the type you are expecting the hash values to be. The new layer will default the hash key types to `Symbol` and hash value types to `Object` (= any type). The Virtus Hash attribute did not force any default types for these. It should be preferred to use the actual expected type for the values instead of `Object` (= any type) to make your code more robust and less buggy.
- Change all `attribute :attr_name, Array` to `attribute :attr_name, Array[ExpectedType]` where `ExpectedType` is the type you are expecting the array values to be. It should be preferred to use the actual expected type for the values instead of `Object` (= any type) to make your code more robust and less buggy.
- The original form attribute values are no longer available through the `@attr_name` instance variables within the Form or `Virtus.model` classes. Instead, change all these references to `@attributes["attr_name"].value` in case you want to fetch the original value of the attribute without using its accessor method. Another way is to provide an alias for the original attribute method before overriding it. If you have not overridden the original attribute accessor, simply remove the `@` character in front of the attribute name to fetch the attribute value using the original accessor method.
- When calling the `attributes` method of the model/form classes, use strings to refer to the attribute names, not symbols as you might have done with `Virtus` or `Rectify::Form`. Change all `model.attributes[:attr_name]` method calls to `model.attributes["attr_name"]`.
- When calling `model.attributes.slice(...)`, you also need to use strings to refer to the attribute keys. Change all instances of `model.attributes.slice(:attr1, :attr2)` to `model.attributes.slice("attr1", "attr2")`
- If you had overridden any of the [`Rectify::Form` methods](https://github.com/andypike/rectify/blob/v0.13.0/lib/rectify/form.rb) within your form classes, remove those overrides. For example, you might have overridden the `form_attributes_valid?` method which no longer does anything. Instead, define a custom validation in order to add extra validations to your forms.
- Very rarely, when defining a an attribute of type `Rails::Engine`, you need to change `attribute :attr_name, Rails::Engine` to `attribute :attr_name, Rails::Engine, **{}`. This is because we want to preserve the method signature against `ActiveModel::Attributes` for the `attribute` class method intead of the legacy `Virtus.model`. There is a limitation in the Ruby language that if the method has default values for the previous arguments and defines keyword arguments, the last argument will always receive a `respond_to?(:to_hash)` call to it which doesn't work for `Rails::Engine` (you can try it out in the Rails console by calling `Rails::Engine.respond_to?(:to_hash)`).
- Test all your form and command classes thoroughly to notice any differences between the two implementations. The new layer is a bit more "robust" with some of the type castings, so some things may break during the migration in case you have relied on some of the oversights within `Virtus`.

#### Custom icons new uploader

PR [\#8645](https://github.com/decidim/decidim/pull/8645) we now only allow PNG images at Favicon so we can provide higher quality versions to mobile devices.

#### Automatically change active step in participatory processes

PR [\#9026](https://github.com/decidim/decidim/pull/9026) adds the ability to automatically change the active step of participatory processess. This is an optional behavior that system admins can enable by configuring a cron job. The frequency of the cron task should be decided by the system admin and depends on each platform's use cases. A precision of 15min is enough for most cases. An example of a crontab job may be:

```bash
*/15 * * * * cd /home/user/decidim_application && RAILS_ENV=production bundle exec rake decidim_participatory_processes:change_active_step
```

Each time the job executes it checks all currently active and published participatory processes and for each, it checks the steps with the date range in the current date. If a change should be made, it deactivates the previous step and activates the next step.

Platform administrators will always have the possibility to manually change phases, although if a cron job is configured the change may be undone.

This PR also changes the Step `start_date` and `end_date`  fields to timestamps.
#### Mail Notifications digest

PR [\#8833](https://github.com/decidim/decidim/pull/8833) Users can now configure if the want to receive a real time email when they receive a notification or a periodic one with the notifications digest.


```bash
# Send notification mail digest daily
5 0 * * * cd /home/user/decidim_application && RAILS_ENV=production bundle exec rake decidim:mailers:notifications_digest_daily
# Send notification mail digest weekly on saturdays
5 0 * * 6 cd /home/user/decidim_application && RAILS_ENV=production bundle exec rake decidim:mailers:notifications_digest_weekly

### Changed

### Accept and reject cookies

Cookie consent management has been updated in [\#9271](https://github.com/decidim/decidim/pull/9271). Supported cookie categories are essential, preferences, analytics and marketing.
Iframe HTML elements that are added with the editor or meeting forms are disabled until all cookies are accepted. Scripts that require cookies could be added as follows:

```html
<script type="text/plain" data-consent="marketing">
  console.log('marketing cookies accepted');
</script>
```

Note that you need to define the `type="text/plain"` for the script that adds cookies in order to prevent the script from being executed before cookies are accepted. You should also define the metadata for all the cookies that you're using on your app initializer. See [cookie documentation](https://docs.decidim.org/en/customize/cookies.html).


Mind that we also changed the cookie consent cookie from "decidim-cc" to "decidim-consent" by default. You can change it on your initializer, or update your cookie legal notice accordingly.

### Rename data portability to download your data

"Data portability" has been renamed to "Download you data" at [\#9196](https://github.com/decidim/decidim/pull/9196), you should update your cron job via crontab -e.
```
0 0 * * * cd /home/user/decidim_application && RAILS_ENV=production bundle exec rake decidim:delete_data_portability_files
```
Changes to:
```
0 0 * * * cd /home/user/decidim_application && RAILS_ENV=production bundle exec rake decidim:delete_download_your_data_files
```


- **decidim-core**: The `Decidim::ActivitySearch` class has been rewritten as `Decidim::PublicActivities` which is now a `Rectify::Query` class instead of `Searchlight::Search` class due to the removal of Searchlight at [\#8748](https://github.com/decidim/decidim/pull/8748).
- **decidim-core**: The `Decidim::ResourceSearch` class now inherits from `Ransack::Search` instead of `Searchlight::Search` as of [\#8748](https://github.com/decidim/decidim/pull/8748). The new `ResourceSearch` class provides extra search functionality for contextual searches that require context information in addition to the search parameters, such as current user or current component. It has barely anything to do with the `ResourceSearch` class in the previous versions which contained much more logic. Please review all your search classes that were inheriting from this class. You should migrate your search filtering to Ransack.
- **decidim-debates**, **decidim-initiatives**, **decidim-meetings**: The resource search classes `Decidim::Debates::DebateSearch`, `Decidim::Intitatives::InitiativeSearch` and `Decidim::Meetings::MeetingSearch` are rewritten for the Ransack searches due to Searchlight removal at [\#8748](https://github.com/decidim/decidim/pull/8748). The role of these classes is now to pass contextual information to the searches, such as the current user. All other search filtering should happen directly through Ransack.
- **decidim-meetings**: The `visible_meetings_for` scope for the `Meeting` model has been renamed to `visible_for` in [\#8748](https://github.com/decidim/decidim/pull/8748) for consistency.
- **decidim-core**: The `official_origin`, `participants_origin`, `user_group_origin` and `meeting_origin` scopes for the `Decidim::Authorable` and `Decidim::Coauthorable` concerns have been changed to `with_official_origin`, `with_participants_origin`, `with_user_group_origin` and `with_meeting_origin` respectively in [\#8748](https://github.com/decidim/decidim/pull/8748) for consistency. See the Searchlight removal change notes for reasoning.
- **decidim-core**: Nicknames are now differents case insensitively, a rake task has been created to check every nickname and modify them if some are similar (Launch it with "bundle exec rake decidim:upgrade:fix_nickname_uniqueness"). Routing and mentions has been made case insensitive for every tab in profiles.

#### Deprecation of `Rectify::Presenter`
PR [\#8758](https://github.com/decidim/decidim/pull/8758) is deprecating the implementation of `Rectify::Presenter` in favour of `SimpleDelegator`

#### Searchlight removal causes changes in the participant searches

The `searchlight` gem has been removed in favor of Ransack as of [\#8748](https://github.com/decidim/decidim/pull/8748) in order to standardize all searches within Decidim around a single way of performing searches. Ransack was selected as the preferred search backend because it is better maintained and has a larger community of developers around it compared to Searchlight.

Ransack provides a search API that produces the search queries semi-automatically against the available database columns and ActiveRecord scopes made available for the Ransack searches while Searchlight used to require to write all the search logic manually in the search classes. Due to the inner workings of the Ransack gem and for consistency reasons, the following changes have been made for the search filtering:

- For search scopes that are doing more than matching against a specific column in the database or require special programming logic during the searches, there is a new scope convention introduced with the `with_*` and `with_any_*` scope names. The `with_*` convention should be used when providing a search scope that searches against one key, such as `with_category(1)` and the `with_any_*` convention should be used when providing a search scope that searches against one or multiple keys, such as `with_any_category(1, 2, 3)`.
  * An example of such scope is `with_any_category` provided by the `HasCategory` concern which searches against the provided category IDs or any sub-category of those category IDs. You can find all the introduced (or changed) scopes by searching for `scope :with_` within the Decidim codebase.
  * With Searchlight, these search parameters were provided e.g. as `category_id` which was then used to perform the explained search query manually in the ResourceSearch class which is now used for a different purpose. As the search now happens through Ransack and the ActiveRecord scopes, these parameters have been renamed to better explain what they do. With Ransack, matching e.g. against the `category_id_eq` key would mean that the search is done against this specific column in the record's database table and only searching for the provided search input (and not e.g. the parent categories in the category case).
- The origin scopes provided by `Decidim::Authorable` and `Decidim::Coauthorable` have been renamed with the `with_` prefix as explained above.
- All the filtering key changes have been reflected to the participant filtering views (`_filters.html.erb` in most modules) as well as the controller methods `default_filter_params` where applicable.
- The `default_filter_params` method within the participant-facing controllers now defines all the parameters that are allowed in the search queries and only these parameters are passed to the Ransack search. This limitation is made in order to protect the participant views from providing more searching options through the URL parameters than they are supposed to provide. In the past, the `Searchlight::Search` classes took care of utilizing only the allowed parameters but Ransacker does not have any middle-layer that would do the same, which is why the limitation is done at the controller side.
- The `search_collection` method now defines the base collection used for the searches within the filtering controllers. In previous versions, there used to be a method that defined a `search_klass` method that defined the `Searchlight::Search` class to be used as the basis for the search. Now, the `search_collection` defines the base collection instead against which the Ransack search is run.

3rd party developers that have developed their own modules or customizations for the core controllers or filtering views, should revisit their customizations and make sure they reflect these changes made for the controllers or filtering views. It is suggested to remove the customizations related to the filtering views/controllers and re-do from scratch what needs to be customized in order to ensure full compatibility with the changed filtering APIs. In case you had created your own `Searchlight::Search` (or `ResourceSearch`) classes, you should scrap those and start over using Ransack.

More information on using Ransack can be found from the [Ransack documentation](https://github.com/activerecord-hackery/ransack). You can find examples for filtering in the core filtering views and controllers.

### Fixed

### Removed

- **decidim-core**: The `rectify` gem has been removed from the stack as of [\#9101](https://github.com/decidim/decidim/pull/9101). If you are a library developer, replace any `Rectify::Query` with `Decidim::Query`, replace any `Rectify::Command` with `Decidim::Command`. Replace any `Rectify::Presenter` with `SimpleDelegator` (Already deprecated in [\#8758](https://github.com/decidim/decidim/pull/8758))
- **decidim-core**: The `searchlight` gem has been removed in favor of Ransach as of [\#8748](https://github.com/decidim/decidim/pull/8748). Please review the **Changed** notes regarding the required changes. Please review all your search classes that were inheriting from `Searchlight::Search`. You should migrate your search filtering to Ransack.
- **decidim-core**: The `search_params` and `default_search_params` methods within the participant-facing controllers are now removed in favor of using `filter_params` and `default_filter_params` as of [\#8748](https://github.com/decidim/decidim/pull/8748). The duplicate methods were redundant after the Ransack migration which is why they were removed. In case you had overridden these methods in your controllers, they no longer do anything. In case you were calling these methods before, you will now receive a `NoMethodError` because they are removed. Please use `filter_params` and `default_filter_params` instead.
- **decidim-accountability**, **decidim-assemblies**, **decidim-budgets**, **decidim-consultations**, **decidim-core**, **decidim-elections**, **decidim-initiatives**, **decidim-participatory_processes**, **decidim-proposals**, **decidim-sortitions**: The search service classes inheriting from `Searchlight::Search` that are no longer necessary due to the Ransack migration have been removed in all modules as of [\#8748](https://github.com/decidim/decidim/pull/8748). This includes `Decidim::Accountability::ResultSearch`, `Decidim::Assemblies::AssemblySearch`, `Decidim::Budgets::ProjectSearch`, `Decidim::Consultations::ConsultationSearch`, `Decidim::HomeActivitySearch`, `Decidim::ParticipatorySpaceSearch`, `Decidim::Elections::ElectionsSearch`, `Decidim::Votings::VotingSearch`, `Decidim::Meetings::Directory::MeetingSearch`, `Decidim::ParticipatoryProcesses::ParticipatoryProcessesSearch`, `Decidim::Proposals::CollaborativeDraftSearch`, `Decidim::Proposals::ProposalSearch` and `Decidim::Sortitions::SortitionSearch`.

## Previous versions

Please check [release/0.26-stable](https://github.com/decidim/decidim/blob/release/0.26-stable/CHANGELOG.md) for previous changes.

