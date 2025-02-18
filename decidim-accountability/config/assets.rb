# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs")
Decidim::Webpacker.register_entrypoints(
  decidim_accountability: "#{base_path}/app/packs/entrypoints/decidim_accountability.js",
  decidim_accountability_admin_form: "#{base_path}/app/packs/entrypoints/decidim_accountability_admin_form.js",
  decidim_accountability_admin_imports: "#{base_path}/app/packs/entrypoints/decidim_accountability_admin_imports.js",
  decidim_accountability_admin_index: "#{base_path}/app/packs/entrypoints/decidim_accountability_admin_index.js"
)
