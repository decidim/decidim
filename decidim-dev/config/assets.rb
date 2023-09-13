# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs")
Decidim::Webpacker.register_entrypoints(
  decidim_dev: "#{base_path}/app/packs/entrypoints/decidim_dev.js",
  decidim_dev_test_custom_map: "#{base_path}/app/packs/entrypoints/decidim_dev_test_custom_map.js"
)
