# Decidim::Generators

This gem provides several generators to create decidim applications & components

## Installation

```console
gem install decidim-generators
```

## Usage

### Generating decidim applications

Use the command

```console
decidim my_new_application
```

to generate a fresh new decidim application.

### Generating decidim components

This repo helps you generating the scheleton of a decidim component. It will
generate a folder with a plugin's code skeleton that you then need to properly
require in your final decidim application in order to use it. To do that, you
need to include the plugin in your application's `Gemfile`.

For example, if you generated your component at
`~/decidim-module-experimental_component`, you'll need to edit your `Gemfile` like
this in order for the component to be used:

```ruby
gem "decidim-experimental_plugin", path: "~/decidim-module-experimental_plugin"
```

Once you do that, and boot your application, you'll see the new component being
offered in the "New component" selector on the "Components" section of any
participatory space in the admin dashboard.

#### Generate a new component

```console
decidim --component my_component
```

#### Generate a new component in a specific folder

You may do this when you want to point to an existing folder or give it a custom
name.

```console
decidim --component my_component --destination_folder ../decidim-module-my_component
```

#### Generate a new component as a external plugin

You may do this when your plugin is meant to live outside of decidim's core
repo. The generated application has some particularities as opposed to a plugin
living in the core repo. For example:

* It has its own Gemfile.
* The dummy application path is different.

```console
decidim --component my_component --external
```

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

See [Decidim](https://github.com/decidim/decidim).
