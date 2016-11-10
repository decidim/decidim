# frozen_string_literal: true
module Decidim
  module Admin
    # Custom helpers, scoped to the admin panel.
    #
    module AriaSelectedLinkToHelper
      def aria_selected_link_to(text, link, options = {})
        link_to(
          text,
          link,
          options.merge(
            "aria-selected": is_active_link?(link, :exclusive)
          )
        )
      end
    end
  end
end
