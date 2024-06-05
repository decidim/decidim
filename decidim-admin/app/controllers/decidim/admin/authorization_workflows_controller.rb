# frozen_string_literal: true

module Decidim
  module Admin
    class AuthorizationWorkflowsController < Decidim::Admin::ApplicationController
      layout "decidim/admin/users"

      add_breadcrumb_item_from_menu :admin_user_menu

      def index
        enforce_permission_to :index, :authorization_workflow

        @workflows = Decidim::Verifications.admin_workflows.select do |manifest|
          current_organization.available_authorizations.include?(manifest.name.to_s)
        end

        # Decidim::Verifications::Authorizations Query
        @authorizations = Decidim::Verifications::Authorizations.new(
          organization: current_organization,
          granted: true
        ).query
      end
    end
  end
end
