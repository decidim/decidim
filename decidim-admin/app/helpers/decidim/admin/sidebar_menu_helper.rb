# frozen_string_literal: true

module Decidim
  module Admin
    module SidebarMenuHelper
      def sidebar_menu(target_menu)
        ::Decidim::Admin::SecondaryMenuPresenter.new(target_menu, self, active_class: "is-active")
      end

      def simple_menu(target_menu:, options: {})
        options = { active_class: "is-active" }.merge(options)
        ::Decidim::Admin::SimpleMenuPresenter.new(target_menu, self, options)
      end
    end
  end
end
