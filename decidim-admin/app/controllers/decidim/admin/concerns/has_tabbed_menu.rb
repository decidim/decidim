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

          def tab_menu_name = raise NotImplementedError
        end
      end
    end
  end
end
