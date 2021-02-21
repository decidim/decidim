# frozen_string_literal: true

module Decidim
  module Admin
    module SidebarMenuHelper
      protected

      def sidebar_menu(target_menu)
        ::Decidim::Admin::SecondaryMenuPresenter.new(target_menu, self, active_class: "is-active")
      end

      def simple_menu(target_menu)
        ::Decidim::Admin::SimpleMenuPresenter.new(target_menu, self, active_class: "is-active", container_options: { id: "components-list" })
      end
    end
  end
end
