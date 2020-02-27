# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      module FilterableHelper
        def extra_dropdown_submenu_options_items(filter)
          options = case filter
                    when :state_eq
                      content_tag(:li, filter_link_value(:state_null, true))
                    end
          [options].compact
        end
      end
    end
  end
end
