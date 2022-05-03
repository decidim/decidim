# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

Decidim::Webpacker.register_path("#{base_path}/app/packs")
Decidim::Webpacker.register_entrypoints(
  decidim_meetings: "#{base_path}/app/packs/entrypoints/decidim_meetings.js",
  decidim_meetings_admin: "#{base_path}/app/packs/entrypoints/decidim_meetings_admin.js"
)

Decidim::Webpacker.register_stylesheet_import("stylesheets/decidim/meetings/meetings")
Decidim::Webpacker.register_stylesheet_import("stylesheets/decidim/meetings/redesigned_meetings")
