# Features and components

Features and components are the core contract between external modules and the core. They're used to define pieces of functionality that are pluggable to participatory processes and can be enabled or disabled by the administrator.

## How do I create a new feature?

Features are just gem with one or more rails engines included in it. You can use as an example [decidim-pages](https://github.com/AjuntamentdeBarcelona/decidim/tree/master/decidim-pages).

Check out the `lib/decidim/pages` folder: It includes several files, the most important of which is `feature.rb`.

## Defining a feature manifest

Features are defined in a manifest, along with its components. You can think of a feature as the abstract functionality (proposals, meetings) while their components are the way they're exposed to the end user.

There's a DSL available to describe all this:

```ruby
# :my_feature is the unique name of the feature that will be globally registered.
Decidim.register_feature(:my_feature) do |feature|
  # A feature can have many components. Their names have to be globally unique as
  # well.
  feature.component :my_custom_component do |component|
    # The user will be redirected to the component's engine. A component's engine 
    # is isolated from the outside so it can deal with its own dependencies
    # without having to know its render path or its parent resources.
    component.engine = MyFeature::MyCustomComponentEngine

    # A component's admin engine will get rendered on the admin panel and follows
    # the same principles as the engine. It's isolated from the outside and 
    # doesn't care about external dependencies. It only needs to care about its
    # underlying `feature`.
    component.admin_engine = MyFeature::MyCustomComponentAdminEngine
    
    # Component hooks get called whenever relevant lifecycle events happen, like
    # adding a new component o destroying it. You always get passed the instance
    # so you can act on it. Creating or destroying a comoponent is transactional
    # along with its hooks, so you can decide to halt the transaction by raising
    # an exception.
    #
    # Valid hook names are :create and :destroy.
    component.on(:create) do |instance|
      MyFeature::DoSomething.with(instance)
    end
  end
end
```

Every model in a feature doesn't have to (and should not) know about its parent participatory process, but instead should be scoped to the features. This is a way to decouple dependencies and have a way to run, for example, multiple, separate *proposals* processes in the same *participatory process*.
