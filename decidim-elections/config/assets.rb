# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Shakapacker.register_path("#{base_path}/app/packs")
Decidim::Shakapacker.register_entrypoints(
  decidim_elections: "#{base_path}/app/packs/entrypoints/decidim_elections.js",
  decidim_elections_admin: "#{base_path}/app/packs/entrypoints/decidim_elections_admin.js"
)
