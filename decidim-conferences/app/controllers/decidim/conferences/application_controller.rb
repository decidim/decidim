# frozen_string_literal: true

module Decidim
  module Conferences
    # The main application controller for conferences
    #
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    class ApplicationController < Decidim::ApplicationController
      helper Decidim::ApplicationHelper
      helper Decidim::ResourceHelper
      helper Decidim::Conferences::ConferenceHelper

      include NeedsPermission

      layout "layouts/decidim/conferences/application"

      register_permissions(::Decidim::Conferences::ApplicationController,
                           Decidim::Conferences::Permissions,
                           Decidim::Admin::Permissions,
                           Decidim::Permissions)

      private

      def fallback_layout
        "layouts/decidim/conferences/application"
      end

      def permissions_context
        super.merge(
          current_participatory_space: try(:current_participatory_space)
        )
      end

      def permission_class_chain
        ::Decidim.permissions_registry.chain_for(::Decidim::Conferences::ApplicationController)
      end

      def permission_scope
        :public
      end
    end
  end
end
