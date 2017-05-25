# Features

Features are the core contract between external modules and the core. They're used to define pieces of functionality that are pluggable to participatory processes and can be enabled or disabled by the administrator.

## How do I create a new feature?

Features are just gems with one or more Rails engines included in it. You can use as an example [decidim-pages](https://github.com/decidim/decidim/tree/master/decidim-pages).

Check out the `lib/decidim/pages` folder: It includes several files, the most important of which is `feature.rb`.

## Defining a feature manifest

Features are defined in a manifest, along with its engine and admin engine counterpart.

There's a DSL available to describe all this:

```ruby
# :my_feature is the unique name of the feature that will be globally registered.
Decidim.register_feature(:my_feature) do |feature|
  # The user will be redirected to the feature's engine when accessing it through
  # the public page of a participatory process. A feature's engine is isolated 
  # from the outside so it can deal with its own dependencies without having to 
  # know its render path or its parent resources.
  feature.engine = MyFeature::Engine

  # A component's admin engine will get rendered on the admin panel and follows
  # the same principles as the engine. It's isolated from the outside and 
  # doesn't care about external dependencies. It only needs to care about its
  # underlying `feature`.
  feature.admin_engine = MyFeature::AdminEngine
    
  # Feature hooks get called whenever relevant lifecycle events happen, like
  # adding a new feature o destroying it. You always get passed the instance
  # so you can act on it. Creating or destroying a comoponent is transactional
  # along with its hooks, so you can decide to halt the transaction by raising
  # an exception.
  #
  # Valid hook names are :create and :destroy.
  feature.on(:create) do |feature|
    MyFeature::DoSomething.with(feature)
  end

  # Export definitions allow features to declare any number of exportable files.
  # 
  # An export definition needs a unique name, a collection, and a Serializer. If
  # no serializer is provided, a default, naive one will be used.
  #
  # Exports are then exposed via the UI, so the implementer only needs to care
  # about the export definitions.
  feature.exports :feature_resources do |exports|
    exports.collection do |feature|
      MyFeature::Resource.where(feature: feature)
    end

    exports.serializer MyFeature::ResourceSerializer
  end
end
```

Every model in a feature doesn't have to (and should not) know about its parent participatory process, but instead should be scoped to the features. 
