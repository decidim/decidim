# frozen_string_literal: true

module Decidim
  module Votings
    # The main application controller for votings
    #
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    class ApplicationController < Decidim::ApplicationController
      include NeedsPermission

      register_permissions(::Decidim::Votings::ApplicationController,
                           Decidim::Votings::Permissions,
                           Decidim::Admin::Permissions,
                           Decidim::Permissions)

      private

      def permission_class_chain
        ::Decidim.permissions_registry.chain_for(::Decidim::Votings::ApplicationController)
      end

      def permission_scope
        :public
      end
    end
  end
end
