# Fixing locales

Sometimes in production environments you are force to change the locales available for an organization.

However, this may be delicate, specially if you need to remove them.

## Change the available languages of an organization

When you create an organization, you choose the available languages for it (through the `/system/` url). However, when trying to edit it, the language selector is not available anymore. Here is a way to update that locales manually:

First, make sure that your initializer file has all the locales you want:

Edit the file `config/initializers/decidim.rb` and be sure to include all the necessary locales:

```ruby
...
# Change these lines to set your preferred locales
  config.default_locale = :en
  config.available_locales = [:en, :ca, :es, :fr, :pt]
..
```

Then you need to access the rails console and update the organization locales manually.

Access to your rails console and select your organization. If you have only one organization you can just run the command:

```ruby
o=Decidim::Organization.first
```

Check your current locales:

```ruby
o.available_locales
=> ["en", "ca", "es"]
```

Then add or remove locales and save the organization.

```ruby
o.available_locales += ["fr", "pt"]
=> ["en", "ca", "es", "pt", "fr"]
o.save!
```

If you want to change the default locale:

```ruby
o.default_locale = "fr"
o.save!
```

> If you need to remove locales from an organization read the next section!

## Fixing errors in locales

In certain cases (ie. when removing locales from an organization) some operations in Decidim may lead to errors 500 in the browser.

In order to solve that you can make use of these rake tasks:

### Synchronize Locales

```bash
bundle exec rake decidim:locales:sync_all
```

Run this task if you have changed `available_locales` or `default_locale` in `config/initializers/decidim.rb` and you think that some organization have values not supported by the Decidim installation.

Examples:

* `Decidim.available_locales` is set to `[:en, :ca, :fr]` and your organization has `available_locales` to `[:es, :ca]`, running this script will change it to `[:ca]` as `:es` is not supported.
* `organization.default_locale` is set to `:fr` and your `available_locales` to `[:en, :es]`, running this script will change `organization.default_locale` to `:en`.

It is safe to run this task as it respects organizations with less languages than the supported.

### Repair the search index

In order to provide a global search in Decidim, many content is indexed in a search table, each locale separately.
This means that, if you remove languages, some content can be orphan as the original resource do not exist anymore.
This leads to server 500 errors.

To repair the search index you can run the rake task:

```bash
bundle exec rake decidim:locales:rebuild_search
```

Be aware that this might take a long time as it will remove and recreate the whole search index for all organizations.
