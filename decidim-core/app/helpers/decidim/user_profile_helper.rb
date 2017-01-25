# frozen_string_literal: true
module Decidim
  module UserProfileHelper
    def user_profile_tab(text, link, options = {})
      active = is_active_link?(link, (options[:aria_link_type] || :inclusive))

      content_tag(:li, class: "tabs-title#{active ? " is-active" : nil}") do
        aria_selected_link_to(text, link, options)
      end
    end
  end
end
