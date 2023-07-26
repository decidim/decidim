# frozen_string_literal: true

module Decidim
  module Admin
    module Concerns
      module HasBreadcrumbItems
        extend ActiveSupport::Concern

        class_methods do
          def add_breadcrumb_item_from_menu(target_menu, opts = {})
            before_action -> { secondary_breadcrumb_menus << target_menu }, opts
          end
        end

        included do
          def secondary_breadcrumb_menus
            @secondary_breadcrumb_menus ||= []
          end

          def controller_breadcrumb_items
            @controller_breadcrumb_items ||= []
          end
        end
      end
    end
  end
end
