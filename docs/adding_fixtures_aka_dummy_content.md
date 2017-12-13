# How to add dummy content to a development application?
## Proposals example
1. In decidim-proposals open `lib/decidim/proposals/feature.rb`.
1. Find the `feature.seeds do...` block.
1. Create your dummy content as if you were in a `db/seed.rb` script.
  - Take advantage of the Faker gem, already in decidim.
