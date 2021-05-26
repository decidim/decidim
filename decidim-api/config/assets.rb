# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs")
Decidim::Webpacker.register_entrypoint(
  :decidim_api_docs,
  "#{base_path}/app/packs/entrypoints/decidim_api_docs.js"
)
