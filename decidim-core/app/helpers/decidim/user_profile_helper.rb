# frozen_string_literal: true

module Decidim
  # Helpers used in controllers implementing the `Decidim::UserProfile` concern.
  module UserProfileHelper
    # Public: Shows a menu tab with a section. It highlights automatically bye
    # detecting if the current path is a subset of the provided route.
    #
    # text - The text to show in the tab.
    # link - The path to link to.
    # options - Extra options.
    #           aria_link_type - :inclusive or :exact, depending on the type of
    #                            highlighting desired.
    #
    # Returns a String with the menu tab.
    def user_profile_tab(text, link, options = {})
      active = is_active_link?(link, (options[:aria_link_type] || :inclusive))

      content_tag(:li, class: "tabs-title#{active ? " is-active" : nil}") do
        aria_selected_link_to(text, link, options)
      end
    end
  end
end
