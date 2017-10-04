# frozen_string_literal: true

module Decidim
  module Admin
    class AuthorizationWorkflowsController < Decidim::Admin::ApplicationController
      skip_authorization_check

      layout "decidim/admin/users"

      def index
        @workflows = Decidim::Verifications.admin_workflows
      end
    end
  end
end
