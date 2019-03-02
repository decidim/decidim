# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This controller is the abstract class from which all other controllers of
    # this engine inherit.
    class ApplicationController < Decidim::ApplicationController
      helper Decidim::ApplicationHelper
      helper Decidim::ParticipatoryProcesses::ApplicationHelper

      include NeedsPermission

      private

      def permission_class_chain
        [
          Decidim::ParticipatoryProcesses::Permissions,
          Decidim::Admin::Permissions,
          Decidim::Permissions
        ]
      end

      def permission_scope
        :public
      end
    end
  end
end
