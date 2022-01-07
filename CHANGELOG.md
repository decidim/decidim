# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

#### Register assets paths
To prevent Zeitwerk from trying to autoload classes from the `app/packs` folder, it's necesary to register these paths for each module and for the application using the method `Decidim.register_assets_path` on initializers. This is explained in the webpacker migration guides for [applications](https://github.com/decidim/decidim/blob/develop/docs/modules/develop/pages/guide_migrate_webpacker_app.adoc#help-decidim-to-know-the-applications-assets-folder) and [modules](https://github.com/decidim/decidim/blob/develop/docs/modules/develop/pages/guide_migrate_webpacker_module.adoc#help-decidim-to-know-the-modules-assets-folder)), and was implemented in [\#8449](https://github.com/decidim/decidim/pull/8449).

#### Unconfirmed access disabled by default
As per [\#8233](https://github.com/decidim/decidim/pull/8233), by default all participants must confirm their email account to sign in. Implementors can change this setting as a [initializer configuration](https://docs.decidim.org/en/configure/initializer/#_unconfirmed_access_for_users):

```ruby
Decidim.configure do |config|
  config.unconfirmed_access_for = 2.days
end
```

#### User workflows change to prevent user enumeration attacks

Until now it was possible to see if an email account was registered in Decidim, by using features like "Forgot your password", as the response changed if the email existed ("`You will receive an email with instructions on how to reset your password in a few minutes`") that's different to a non-existing user account ("`could not be found. Did you sign up previously?`"). This allows User Enumration attacks, where a malicious actor can check if anyone has an acount in the platform. As per [\#8537](https://github.com/decidim/decidim/pull/8537), anyone has the same answer always "`If your email address exists in our database, you will receive a password recovery link at your email address in a few minutes`".

#### Blocked user in global search

PR [\#8658](https://github.com/decidim/decidim/pull/8658) Blocked users are present in global search, to update the search and make them disappear, Run in a rails console or create a migration with:

```ruby
  Decidim::User.find_each(&:try_update_index_for_search_resource)
```

Please be aware that it could take a while if your database has a lot of Users.

#### `Decidim::Form`s no longer use `Rectify::Form` and `Virtus` should be no longer used

As per [\#8669], your `Decidim::Form`s will no longer use `Rectify::Form` or `Virtus.model` attributes because `Virtus` is discontinued and Decidim is loosening the dependency on the `virtus` gem. Instead, the attributes implementation is now based on [`ActiveModel::Attributes`](https://api.rubyonrails.org/classes/ActiveModel/Attributes/ClassMethods.html) with an integration layer within Decidim that aims to provide as much backwards compatibility as possible with the `Virtus.model` attributes that were previously used.

For most cases, no changes in the code should be needed but there are specific differences with the implementation which may require changes in the 3rd party code as well. Both `Rectify::Form` and `Virtus` will be still available in the core (through the `rectify` gem) but you should migrate away from them as soon as possible as they may be removed in future versions of Decidim.

There are specific things that you need to change regarding your Form or `Virtus.model` classes when migrating to `Decidim::AttributeObject`:

- Change all instances of `YourForm < Rectify::Form` to `YourForm < Decidim::Form`. It should be very rare to find any classes in your code that inherit directly from `Rectify::Form` but in case you have used that, replace those references with `Decidim::Form`.
- Change all instances `include Virtus.model` to `include Decidim::AttributeObject::Model`.
- Change all `attribute :attr_name, Hash` to `attribute :attr_name, Hash[Symbol => ExpectedType]` where `ExpectedType` is the type you are expecting the hash values to be. The new layer will default the hash key types to `Symbol` and hash value types to `Object` (= any type). The Virtus Hash attribute did not force any default types for these. It should be preferred to use the actual expected type for the values instead of `Object` (= any type) to make your code more robutst and less buggy.
- Change all `attribute :attr_name, Array` to `attribute :attr_name, Array[ExpectedType]` where `ExpectedType` is the type you are expecting the array values to be. It should be preferred to use the actual expected type for the values instead of `Object` (= any type) to make your code more robutst and less buggy.
- The original form attribute values are no longer available through the `@attr_name` instance variables within the Form or `Virtus.model` classes. Instead, change all these references to `@attributes["attr_name"].value` in case you want to fetch the original value of the attribute without using its accessor method. Another way is to provide an alias for the original attribute method before overriding it. If you have not overridden the original attribute accessor, simply remove the `@` character in front of the attribute name to fetch the attribute value using the original accessor method.
- When calling the `attributes` method of the model/form classes, use strings to refer to the attribute names, not symbols as you might have done with `Virtus` or `Rectify::Form`. Change all `model.attributes[:attr_name]` method calls to `model.attributes["attr_name"]`.
- When calling `model.attributes.splice(...)`, you also need to use strings to refer to the attribute keys. Change all instances of `model.attributes.splice(:attr1, :attr2)` to `model.attributes.splice("attr1", "attr2")`
- Very rarely, when defining a an attribute of type `Rails::Engine`, you need to change `attribute :attr_name, Rails::Engine` to `attribute :attr_name, Rails::Engine, {}`. This is because we want to preserve the method signature against `ActiveModel::Attributes` for the `attribute` class method intead of the legacy `Virtus.model`. There is a limitation in the Ruby language that if the method has default values for the previous arguments and defines keyword arguments, the last argument will always receive a `respond_to?(:to_hash)` call to it which doesn't work for `Rails::Engine` (you can try it out in the Rails console by calling `Rails::Engine.respond_to?(:to_hash)`).
- If you had overridden any of the [`Rectify::Form` methods](https://github.com/andypike/rectify/blob/v0.13.0/lib/rectify/form.rb) within your form classes, remove those overrides. For example, you might have overridden the `form_attributes_valid?` method which no longer does anything. Instead, define a custom validation in order to add extra validations to your forms.
- Test all your form and command classes thoroughly to notice any differences between the two implementations. The new layer is a bit more "robust" with some of the type castings, so some things may break during the migration in case you have relied on some of the oversights within `Virtus`.

### Added
* [#8012](https://github.com/decidim/decidim/pull/8012) Participatory space to comments, to fix the statistics. Use
`rake decidim_comments:update_participatory_process_in_comments` to migrate existing comments to the new structure.

### Changed

### Fixed

### Removed

## Previous versions

Please check [release/0.25-stable](https://github.com/decidim/decidim/blob/release/0.25-stable/CHANGELOG.md) for previous changes.

#### Base64 images migration

PR [\#8250](https://github.com/decidim/decidim/pull/8250) Replaces the default base64 editor images attachment with the use of ActiveStorage attachments. Also adds a task to parse all editor contents and replace existing base64 images with attachments. The task parses all the attributes which can be edited from admin using the WYSIWYG editor. The task requires an argument with the email of an admin used to create EditorImage instances. To run this task execute:

```
rails decidim:active_storage_migrations:migrate_inline_images_to_active_storage[admin_email]
```
