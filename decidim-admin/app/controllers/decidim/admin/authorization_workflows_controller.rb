# frozen_string_literal: true

module Decidim
  module Admin
    class AuthorizationWorkflowsController < Decidim::Admin::ApplicationController
      layout "decidim/admin/users"

      add_breadcrumb_item_from_menu :admin_user_menu

      def index
        enforce_permission_to :index, :authorization_workflow

        @workflows = Decidim::Verifications.workflows.select do |manifest|
          current_organization.available_authorizations.include?(manifest.name.to_s)
        end

        @revocation_counts = @workflows.index_with do |manifest|
          name = manifest.name.to_s
          {
            total: authorizations_count(name),
            impersonated: authorizations_count(name, impersonated_only: true)
          }
        end
      end

      private

      def authorizations_count(name, impersonated_only: false)
        Decidim::Verifications::Authorizations.new(
          organization: current_organization,
          name:,
          granted: true,
          impersonated_only:
        ).query.count
      end
    end
  end
end
