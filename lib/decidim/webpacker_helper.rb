require "webpacker"
require "webpacker/helper"

module Decidim
  module ApplicationHelper
    include ::Webpacker::Helper

    def decidim_javascript_pack_tag(*names, **options)
      javascript_include_tag(*sources_from_manifest_entries(names, type: :javascript), **options)
    end

    private

    def sources_from_manifest_entries(names, type:)
      names.map { |name| Decidim.webpacker.manifest.lookup!(name, type: type) }.flatten
    end
  end
end
