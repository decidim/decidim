# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      module FilterableHelper
        def extra_dropdown_submenu_options_items(_filter, _i18n_scope)
          options = nil
          # options = case filter
          #           when :state_eq
          #             tag.li(filter_link_value(:state_null, true, i18n_scope))
          #           end
          [options].compact
        end
      end
    end
  end
end
