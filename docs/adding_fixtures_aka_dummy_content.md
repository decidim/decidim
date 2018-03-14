# How to add dummy content to a development application?

## Proposals example

1. In decidim-proposals open `lib/decidim/proposals/component.rb`.
1. Find the `component.seeds do...` block.
1. Create your dummy content as if you were in a `db/seed.rb` script.
  - Take advantage of the Faker gem, already in decidim.
  - You can use https://github.com/decidim/decidim/blob/master/decidim-core/lib/decidim/faker/localized.rb, which uses `Faker` internally, if you need content for i18n fields.
