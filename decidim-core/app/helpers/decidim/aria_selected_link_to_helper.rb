# frozen_string_literal: true

module Decidim
  # Module to add the attribute `aria-selected` to links when they are
  # pointing to the current path. Uses the `active_link_to` gem to calculate
  # this.
  #
  module AriaSelectedLinkToHelper
    # Adds the `aria-selected` attribute to a link when it's pointing to the
    # current path. The API is the same than the `link_to` one, and uses this
    # helper internally.
    #
    # text - a String with the link text
    # link - Where the link should point to. Accepts the same value than
    #   `link_to` helper.
    # options - An options Hash that will be passed to `link_to`.
    def aria_selected_link_to(text, link, options = {})
      link_to(
        text,
        link,
        options.merge(
          "aria-selected": is_active_link?(link, options[:aria_link_type] || :inclusive)
        )
      )
    end
  end
end
