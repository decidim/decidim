# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs")
Decidim::Webpacker.register_entrypoints(
  decidim_assemblies: "#{base_path}/app/packs/entrypoints/decidim_assemblies.js",
  decidim_assemblies_admin: "#{base_path}/app/packs/entrypoints/decidim_assemblies_admin.js",
  decidim_assemblies_admin_list: "#{base_path}/app/packs/entrypoints/decidim_assemblies_admin_list.js"
)
