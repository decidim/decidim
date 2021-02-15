# frozen_string_literal: true

module Decidim
  module ExternalLinkPageHelper
    def highlight_domain(url)
      parts = url.match %r{^(([a-z]+):)?//([^/]+)(/.*)?$}
      content_tag :p do
        content_tag(:span, "#{parts[1]}//") +
          content_tag(:span, parts[3], class: "highlight") +
          content_tag(:span, parts[4])
      end
    end
  end
end
