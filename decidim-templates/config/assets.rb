# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs")
Decidim::Webpacker.register_entrypoints(
  decidim_templates: "#{base_path}/app/packs/entrypoints/decidim_templates.js",
  decidim_templates_admin: "#{base_path}/app/packs/entrypoints/decidim_templates_admin.js"
)
