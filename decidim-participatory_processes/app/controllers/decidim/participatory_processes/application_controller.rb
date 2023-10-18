# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    class ApplicationController < Decidim::ApplicationController
      helper Decidim::ParticipatoryProcesses::ApplicationHelper
      helper ParticipatoryProcessHelper
      include NeedsPermission

      register_permissions(Decidim::ParticipatoryProcesses::ApplicationController,
                           ::Decidim::ParticipatoryProcesses::Permissions,
                           ::Decidim::Admin::Permissions,
                           ::Decidim::Permissions)

      private

      def permission_class_chain
        ::Decidim.permissions_registry.chain_for(::Decidim::ParticipatoryProcesses::ApplicationController)
      end

      def permission_scope
        :public
      end
    end
  end
end
