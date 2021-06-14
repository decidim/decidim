# frozen_string_literal: true

module Decidim
  module Votings
    # A controller that holds the logic to show votings in a
    # public layout.
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
