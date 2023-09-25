# frozen_string_literal: true

module Decidim
  module Admin
    module IconWithTooltipHelper
      # This helper adds the necessary boilerplate for the admin icon with tooltip.
      #
      # icon_name - A String representing the icon name
      # title     - A String that will be shown when hovering the icon.
      #             class  - Any extra class that will be added to the link.
      #             data   - This option can be used to add custom data attributes.
      def icon_with_tooltip(icon_name, title, options = {})
        with_tooltip(title, options.merge(class: "top")) do
          content_tag(:span, data: { tooltip: true, disable_hover: false, click_open: false },
                             title:) do
            icon(icon_name, aria_label: title, role: "img")
          end
        end
      end
    end
  end
end
