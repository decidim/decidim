# frozen_string_literal: true

module Decidim
  module Initiatives
    # The main application controller for initiatives
    #
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    class ApplicationController < Decidim::ApplicationController
      include NeedsPermission
      register_permissions(::Decidim::Initiatives::ApplicationController,
                           ::Decidim::Initiatives::Permissions,
                           ::Decidim::Admin::Permissions,
                           ::Decidim::Permissions)

      before_action do
        if Decidim::InitiativesType.joins(:scopes).where(organization: current_organization).all.empty?
          flash[:alert] = t("index.uninitialized", scope: "decidim.initiatives")
          redirect_to(decidim.root_path)
        end
      end

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
