# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs")
Decidim::Webpacker.register_entrypoints(
  decidim_core: "#{base_path}/app/packs/entrypoints/decidim_core.js",
  decidim_sw: "#{base_path}/app/packs/entrypoints/decidim_sw.js",
  redesigned_decidim_core: "#{base_path}/app/packs/entrypoints/redesigned_decidim_core.js",
  decidim_conference_diploma: "#{base_path}/app/packs/entrypoints/decidim_conference_diploma.js",
  decidim_email: "#{base_path}/app/packs/entrypoints/decidim_email.js",
  decidim_map: "#{base_path}/app/packs/entrypoints/decidim_map.js",
  decidim_geocoding_provider_photon: "#{base_path}/app/packs/entrypoints/decidim_geocoding_provider_photon.js",
  decidim_geocoding_provider_here: "#{base_path}/app/packs/entrypoints/decidim_geocoding_provider_here.js",
  decidim_map_provider_default: "#{base_path}/app/packs/entrypoints/decidim_map_provider_default.js",
  decidim_map_provider_here: "#{base_path}/app/packs/entrypoints/decidim_map_provider_here.js",
  decidim_widget: "#{base_path}/app/packs/entrypoints/decidim_widget.js"
)
