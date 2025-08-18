# frozen_string_literal: true

module Decidim
  # This helper includes some methods to help with the inclusion of tooltips
  # on the layout.
  module TooltipHelper
    def with_tooltip(title, opts = {}, &)
      content_tag(:span,
                  title:,
                  class: "inline-block",
                  data: { controller: :tooltip,
                          "tooltip-tooltip-value": content_tag(:p, title, id: opts[:id], class: opts[:class] || "bottom", role: "tooltip", "aria-hidden": "true") }) do
        capture(&).html_safe
      end
    end
  end
end
