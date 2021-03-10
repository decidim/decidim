# frozen_string_literal: true

# Force to use the Webpacker instance of Decidim

# RELATIVE_PATH is left blank because the Decidim generator will be replacing this line
# with the path of the application generated. The path is different for the dummy spec app
# and for the development_app
RELATIVE_PATH = ""
DECIDIM_WEBPACKER_ROOT_PATH = Pathname.new(File.join(__dir__, "..", "..", *RELATIVE_PATH))

Webpacker.instance = ::Webpacker::Instance.new(
  root_path: DECIDIM_WEBPACKER_ROOT_PATH,
  config_path: DECIDIM_WEBPACKER_ROOT_PATH.join("config/webpacker.yml")
)
