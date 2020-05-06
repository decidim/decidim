# Components

Components are the core contract between external modules and the core. They're used to define pieces of functionality that are pluggable to participatory spaces and can be enabled or disabled by the administrator.

## How do I create a new component?

Components are just gems with one or more Rails engines included in it. You can use as an example [decidim-pages](https://github.com/decidim/decidim/tree/master/decidim-pages).

Check out the `lib/decidim/pages` folder: It includes several files, the most important of which is `component.rb`.

## Defining a component manifest

Components are defined in a manifest, along with its engine and admin engine counterpart.

There's a DSL available to describe all this:

```ruby
# :my_component is the unique name of the component that will be globally registered.
Decidim.register_component(:my_component) do |component|
  # The user will be redirected to the component's engine when accessing it through
  # the public page of a participatory space. A component's engine is isolated
  # from the outside so it can deal with its own dependencies without having to
  # know its render path or its parent resources.
  component.engine = MyComponent::Engine

  # A component's admin engine will get rendered on the admin panel and follows
  # the same principles as the engine. It's isolated from the outside and
  # doesn't care about external dependencies. It only needs to care about its
  # underlying `component`.
  component.admin_engine = MyComponent::AdminEngine

  # Component hooks get called whenever relevant lifecycle events happen, like
  # adding a new component o destroying it. You always get passed the instance
  # so you can act on it. Creating or destroying a comoponent is transactional
  # along with its hooks, so you can decide to halt the transaction by raising
  # an exception.
  #
  # Valid hook names are :create and :destroy.
  component.on(:create) do |component|
    MyComponent::DoSomething.with(component)
  end

  # Export definitions allow components to declare any number of exportable files.
  #
  # An export definition needs a unique name, a collection, and a Serializer. If
  # no serializer is provided, a default, naive one will be used.
  #
  # Exports are then exposed via the UI, so the implementer only needs to care
  # about the export definitions.
  component.exports :component_resources do |exports|
    exports.collection do |component|
      MyComponent::Resource.where(component: component)
    end

    exports.serializer MyComponent::ResourceSerializer
  end
end
```

Every model in a component doesn't have to (and should not) know about its parent participatory space, but instead should be scoped to the components.

## Settings

Components can define settings that modify its behavior. This settings can be defined to be set for the whole life of the component (global settings), or to be set for each different step of the participatory space (step settings).

Each attribute defined can be described through properties:

* they should have a `type`: `boolean`, `integer`, `string` (short texts), `text` (long texts) or `enum`.
* they can be `required` or not
* they can have a `default` value
* `text` and `string` attributes can be `translated`, which will allow admin users to enter values for every language.
* `text` attributes can use an `editor` to edit them as HTML code
* `enum` attributes should have a `choices` attributes that list all the possible values. This could be a lambda function.
* they can be `readonly` in some cases, throught a lambda function that received the current component within the `context`.

```ruby
# :my_component is the unique name of the component that will be globally registered.
Decidim.register_component(:my_component) do |component|
  ...

  component.settings(:global) do |settings|
    settings.attribute :a_boolean_setting, type: :boolean, default: true
    settings.attribute :an_enum_setting, type: :enum, default: "all", choices: %w(all one none)
  end

  component.settings(:step) do |settings|
    settings.attribute :a_text_setting, type: :text, default: false, required: true, translated: true, editor: true
    settings.attribute :a_lambda_enum_setting, type: :enum, default: "all", choices: -> { SomeClass.enum_options }
    settings.attribute :a_readonly_setting, type: :string, readonly: ->(context) { SomeClass.readonly?(context[:component]) }
  end

  ...
end
```

Each setting should have one or more translation texts related for the admin zone:

* `decidim.components.[component_name].settings.[global|step].[attribute_name]`: Admin label for the setting.
* `decidim.components.[component_name].settings.[global|step].[attribute_name]_help`: Additional text with help for the setting use.
* `decidim.components.[component_name].settings.[global|step].[attribute_name]_readonly`: Additional text for the setting when it is readonly.
