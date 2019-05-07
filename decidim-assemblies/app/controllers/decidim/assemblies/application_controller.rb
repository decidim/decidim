# frozen_string_literal: true

module Decidim
  module Assemblies
    # The main admin application controller for assemblies
    class ApplicationController < Decidim::ApplicationController
      helper Decidim::ApplicationHelper
      helper Decidim::Assemblies::AssembliesHelper
      include NeedsPermission

      register_permissions(Decidim::Assemblies::ApplicationController,
                           ::Decidim::Assemblies::Permissions,
                           ::Decidim::Admin::Permissions,
                           ::Decidim::Permissions)

      private

      def permissions_context
        super.merge(
          current_participatory_space: try(:current_participatory_space)
        )
      end

      def permission_class_chain
        ::Decidim.permissions_registry.chain_for(::Decidim::Assemblies::ApplicationController)
      end

      def permission_scope
        :public
      end
    end
  end
end
