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
