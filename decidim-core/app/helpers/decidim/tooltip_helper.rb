# frozen_string_literal: true

module Decidim
  # This helper includes some methods to help with the inclusion of tooltips
  # on the layout.
  module TooltipHelper
    def with_tooltip(title, opts = {}, &)
      content_tag(:span, data: { tooltip: "true" }) do
        capture(&).html_safe + content_tag(:div, title, id: opts[:id], class: opts[:class] || "bottom", role: "tooltip", "aria-hidden": "true")
      end
    end
  end
end
