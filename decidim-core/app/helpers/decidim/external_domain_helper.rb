# frozen_string_literal: true

module Decidim
  module ExternalDomainHelper
    # Redesign: deprecated once the redesign has been completed
    def highlight_domain
      tag.div do
        content_tag(:span, "#{@url_parts[:protocol]}//") +
          content_tag(:span, @url_parts[:domain], class: "alert") +
          content_tag(:span, @url_parts[:path])
      end
    end
  end
end
