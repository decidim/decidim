# frozen_string_literal: true

module Decidim
  module Admin
    module Concerns
      module HasTabbedMenu
        extend ActiveSupport::Concern

        included do
          helper_method :tab_menu_name, :has_tab_menu?

          private

          def has_tab_menu? = true

          def tab_menu_name = raise NotImplementedError, "Need to define a `tab_menu_name` with the name from the `Decidim.menu` definition"
        end
      end
    end
  end
end
