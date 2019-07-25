# frozen_string_literal: true

module Decidim
  module Initiatives
    # The main admin application controller for initiatives
    class ApplicationController < Decidim::ApplicationController
      include NeedsPermission

      register_permissions(::Decidim::Initiatives::ApplicationController,
                           ::Decidim::Initiatives::Permissions,
                           ::Decidim::Admin::Permissions,
                           ::Decidim::Permissions)

      def permissions_context
        super.merge(
          current_participatory_space: try(:current_participatory_space)
        )
      end

      def permission_class_chain
        ::Decidim.permissions_registry.chain_for(::Decidim::Initiatives::ApplicationController)
      end

      def permission_scope
        :public
      end
    end
  end
end
