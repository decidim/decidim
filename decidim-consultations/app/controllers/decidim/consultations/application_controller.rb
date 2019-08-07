# frozen_string_literal: true

module Decidim
  module Consultations
    # A controller that holds the logic to show consultations in a
    # public layout.
    class ApplicationController < Decidim::ApplicationController
      include NeedsPermission

      register_permissions(::Decidim::Consultations::ApplicationController,
                           Decidim::Consultations::Permissions,
                           Decidim::Admin::Permissions,
                           Decidim::Permissions)

      private

      def permission_class_chain
        ::Decidim.permissions_registry.chain_for(::Decidim::Consultations::ApplicationController)
      end

      def permission_scope
        :public
      end
    end
  end
end
