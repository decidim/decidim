# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs")
Decidim::Webpacker.register_entrypoints(
  decidim_proposals: "#{base_path}/app/packs/entrypoints/decidim_proposals.js",
  decidim_proposals_admin: "#{base_path}/app/packs/entrypoints/decidim_proposals_admin.js"
)
