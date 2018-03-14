# decidim_app-design

* In order to see the design libray in action visit https://decidim-design.herokuapp.com/

`decidim_app-design` is a full-fledged *application* that mounts the assets from `decidim`, thus allowing rapid prototyping of functionalities. It mounts the `decidim` gem present on this same repository so you can safely modify its assets and see changes real-time.

This approach has several benefits:

* Tests will break if a style breaks an existing functionality, as the applications being tested use the same methods.

* `Decidim::LayoutHelper` and others can be reused in `decidim_app-design` for extra consistency.

* Gems that provide extra assets can also be used, ensuring we're always consistent with the prototypes.

* Since it's a rails application, we can keep the assets and specific code need for prototyping separate from the actual `decidim-*` modules, preventing polluting the codebase.

## Usage

## Installation

```bash
$ bundle install
[Installs all dependencies]
Bundle complete!
$ bundle exec rails s
=> Booting Puma
=> Rails 5.1.4 application starting in development
=> Run `rails server -h` for more startup options
Puma starting in single mode...
* Version 3.11.0 (ruby 2.4.2-p198), codename: Love Song
* Min threads: 5, max threads: 5
* Environment: development
* Listening on tcp://0.0.0.0:3000
Use Ctrl-C to stop
```

Navigate to `http://localhost:3000`. You should see a navigable website with examples.

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

See [Decidim](https://github.com/decidim/decidim).
