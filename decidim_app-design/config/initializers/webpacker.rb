# frozen_string_literal: true

# Force to use the Webpacker instance of Decidim

DECIDIM_WEBPACKER_ROOT_PATH = Pathname.new(File.join(__dir__, "..", "..", ".."))

Webpacker.instance = ::Webpacker::Instance.new(
  root_path: DECIDIM_WEBPACKER_ROOT_PATH,
  config_path: DECIDIM_WEBPACKER_ROOT_PATH.join("config/webpacker.yml")
)
