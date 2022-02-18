# frozen_string_literal: true

module Decidim
  # A general presenter to render organization logic to build a manifest
  class OrganizationPresenter < SimpleDelegator
    def translated_description
      ActionView::Base.full_sanitizer.sanitize(translated_attribute(description))
    end

    def pwa_display
      "standalone"
    end

    def start_url
      "/"
    end
  end
end
