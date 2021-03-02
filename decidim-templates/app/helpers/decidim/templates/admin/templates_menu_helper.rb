# frozen_string_literal: true

module Decidim
  module Templates
    module Admin
      module TemplatesMenuHelper
        include Decidim::Admin::SidebarMenuHelper

        def template_types_menu
          @template_types_menu ||= sidebar_menu(:admin_template_types_menu)
        end
      end
    end
  end
end
