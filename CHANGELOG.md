# Change Log

## [Unreleased](https://github.com/decidim/decidim/tree/HEAD)

DEPRECATION NOTE: The `description` field in the categories admin forms has been removed (this applies to any participatory space using categories). For now it's still available in the database, so you can extract it with the following command in the Rails console:

```ruby
Decidim::Category.pluck(:id, :name, :description)
```

In the next version (v0.28.0) it will be fully removed from the database.

### Added

- **decidim-core**, **decidim-budgets**: Reminders for pending orders in budgets [#8621](https://github.com/decidim/decidim/pull/8621). To generate reminders:

```bash
bundle exec rake decidim:reminders:all
```

Or add cronjob:

```bash
4 0 * * * cd /home/user/decidim_application && RAILS_ENV=production bundle exec rake decidim:reminders:all
```

#### New Api Documentation engine
PR [\#8631](https://github.com/decidim/decidim/pull/8631) Replaces graphql-docs npm package with gem. In this PR we have also added 3 configurable paramaters:

```ruby
# defines the schema max_per_page to configure GraphQL pagination
Decidim::Api.schema_max_per_page = 50

# defines the schema max_complexity to configure GraphQL query complexity
Decidim::Api.schema_max_complexity = 5000

# defines the schema max_depth to configure GraphQL query max_depth
Decidim::Api.schema_max_depth = 15
```

The static documentation will be rendered into : ```app/views/static/api/docs``` which is being refreshed automatically when you will run ```rake decidim:upgrade```.

#### `Decidim::Form`s no longer use `Rectify::Form` and `Virtus` should be no longer used

As per [\#8669], your `Decidim::Form`s will no longer use `Rectify::Form` or `Virtus.model` attributes because `Virtus` is discontinued and Decidim is loosening the dependency on the `virtus` gem. Instead, the attributes implementation is now based on [`ActiveModel::Attributes`](https://api.rubyonrails.org/classes/ActiveModel/Attributes/ClassMethods.html) with an integration layer within Decidim that aims to provide as much backwards compatibility as possible with the `Virtus.model` attributes that were previously used.

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
- Very rarely, when defining a an attribute of type `Rails::Engine`, you need to change `attribute :attr_name, Rails::Engine` to `attribute :attr_name, Rails::Engine, {}`. This is because we want to preserve the method signature against `ActiveModel::Attributes` for the `attribute` class method intead of the legacy `Virtus.model`. There is a limitation in the Ruby language that if the method has default values for the previous arguments and defines keyword arguments, the last argument will always receive a `respond_to?(:to_hash)` call to it which doesn't work for `Rails::Engine` (you can try it out in the Rails console by calling `Rails::Engine.respond_to?(:to_hash)`).
- Test all your form and command classes thoroughly to notice any differences between the two implementations. The new layer is a bit more "robust" with some of the type castings, so some things may break during the migration in case you have relied on some of the oversights within `Virtus`.

### Added
* [#8012](https://github.com/decidim/decidim/pull/8012) Participatory space to comments, to fix the statistics. Use
`rake decidim_comments:update_participatory_process_in_comments` to migrate existing comments to the new structure.
You can manually regenerate the docs by running: ```rake decidim_api:generate_docs```

### Changed

### Fixed

### Removed

## Previous versions

Please check [release/0.26-stable](https://github.com/decidim/decidim/blob/release/0.26-stable/CHANGELOG.md) for previous changes.

