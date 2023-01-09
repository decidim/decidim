# frozen_string_literal: true

module Decidim
  # This helper includes some methods to help with the inclusion of tooltips
  # on the layout.
  module TooltipHelper
    # deprecated
    def with_tooltip(title, &)
      content_tag(:span, data: { tooltip: true, disable_hover: false, keep_on_hover: true, click_open: false },
                         title:, &)
    end

    def decidim_tooltip(opts = {}, &)
      content_tag(:div, class: opts[:class] || "bottom", role: "tooltip", &)
    end
  end
end
