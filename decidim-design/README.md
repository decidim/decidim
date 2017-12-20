# decidim-design

`decidim-design` is a full-fledged *application* that mounts the assets from `decidim`, thus allowing rapid prototyping of functionalities. It mounts the `decidim` gem present on this same repository so you can safely modify its assets and see changes real-time.

This approach has several benefits:

* Tests will break if a style breaks an existing functionality, as the applications being tested use the same methods.

* `Decidim::LayoutHelper` and others can be reused in `decidim-design` for extra consistency.

* Gems that provide extra assets can also be used, ensuring we're always consistent with the prototypes.

* Since it's a rails application, we can keep the assets and specific code need for prototyping separate from the actual `decidim-*` gems, preventing polluting the codebase.

## Usage

## Installation

```
$ bundle install
$ bundle exec rails s
```

Navigate to `http://localhost:3000`. You should see a navigable website with examples.

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

See [Decidim](https://github.com/decidim/decidim).
