# frozen_string_literal: true

module Decidim
  module Demographics
    class ApplicationController < Decidim::ApplicationController
      include FormFactory
      register_permissions(::Decidim::Demographics::ApplicationController,
                           ::Decidim::Demographics::Permissions,
                           ::Decidim::Permissions)

      def permission_class_chain
        ::Decidim.permissions_registry.chain_for(::Decidim::Demographics::ApplicationController)
      end
    end
  end
end
