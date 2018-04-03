# frozen_string_literal: true

module Decidim
  module Pages
    module Admin
      # Base controller for the administration of this module. It inherits from
      # Decidim's admin base controller in order to inherit the layout and other
      # convenience methods relevant to a this component.
      class ApplicationController < Decidim::Admin::Components::BaseController
        include NeedsPermission

        private

        def permission_class
          Decidim::Pages::Permissions
        end

        def permission_scope
          :admin
        end
      end
    end
  end
end
