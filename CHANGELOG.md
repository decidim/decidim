# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

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

### Fixed

### Removed

## Previous versions

Please check [release/0.27-stable](https://github.com/decidim/decidim/blob/release/0.27-stable/CHANGELOG.md) for previous changes.
