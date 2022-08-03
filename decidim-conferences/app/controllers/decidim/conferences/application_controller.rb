# frozen_string_literal: true

module Decidim
  module Conferences
    # The main admin application controller for conferences
    class ApplicationController < Decidim::ApplicationController
      helper Decidim::ApplicationHelper
      helper Decidim::ResourceHelper
      helper Decidim::Conferences::ConferenceHelper

      include NeedsPermission
      include RedesignLayout
      redesign active: true

      register_permissions(::Decidim::Conferences::ApplicationController,
                           Decidim::Conferences::Permissions,
                           Decidim::Admin::Permissions,
                           Decidim::Permissions)

      private

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
