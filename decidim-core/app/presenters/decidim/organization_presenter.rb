# frozen_string_literal: true

module Decidim
  # A general presenter to render organization logic to build a manifest
  class OrganizationPresenter < SimpleDelegator
    def html_name
      name.html_safe
    end

    def translated_description
      ActionView::Base.full_sanitizer.sanitize(translated_attribute(description)).html_safe
    end

    def pwa_display
      "standalone"
    end

    def start_url
      "/"
    end
  end
end
