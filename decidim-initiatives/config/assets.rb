# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs")
Decidim::Webpacker.register_entrypoints(
  decidim_initiatives: "#{base_path}/app/packs/entrypoints/decidim_initiatives.js",
  decidim_initiatives_admin: "#{base_path}/app/packs/entrypoints/decidim_initiatives_admin.js",
  decidim_initiatives_print: "#{base_path}/app/packs/entrypoints/decidim_initiatives_print.js",
  decidim_initiatives_initiatives_votes: "#{base_path}/app/packs/entrypoints/decidim_initiatives_initiatives_votes.js"
)
