# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Shakapacker.register_path("#{base_path}/app/packs")
Decidim::Shakapacker.register_entrypoints(
  decidim_meetings: "#{base_path}/app/packs/entrypoints/decidim_meetings.js",
  decidim_meetings_admin: "#{base_path}/app/packs/entrypoints/decidim_meetings_admin.js"
)
