# frozen_string_literal: true

module Decidim
  module Admin
    class AuthorizationWorkflowsController < Decidim::Admin::ApplicationController
      layout "decidim/admin/users"

      def index
        enforce_permission_to :index, :authorization_workflow

        @workflows = Decidim::Verifications.admin_workflows

        # Decidim::Verifications::Authorizations Query
        @authorizations = Decidim::Verifications::Authorizations.new(
          organization: current_organization,
          granted: true
        ).query
      end
    end
  end
end
