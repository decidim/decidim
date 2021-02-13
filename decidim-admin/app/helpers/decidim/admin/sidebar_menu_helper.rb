# frozen_string_literal: true

module Decidim
  module Admin
    module SidebarMenuHelper
      protected

      def sidebar_menu(target_menu)
        ::Decidim::Admin::SecondaryMenuPresenter.new(target_menu, self, active_class: "is-active")
      end
    end
  end
end
