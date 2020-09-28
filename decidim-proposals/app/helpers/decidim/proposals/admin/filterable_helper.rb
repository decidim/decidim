# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      module FilterableHelper
        def extra_dropdown_submenu_options_items(filter, i18n_scope)
          options = case filter
                    when :state_eq
                      tag.li(filter_link_value(:state_null, true, i18n_scope))
                    end
          [options].compact
        end
      end
    end
  end
end
