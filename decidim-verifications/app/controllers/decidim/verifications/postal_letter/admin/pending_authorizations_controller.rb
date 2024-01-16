# frozen_string_literal: true

module Decidim
  module Verifications
    module PostalLetter
      module Admin
        class PendingAuthorizationsController < Decidim::Admin::ApplicationController
          layout "decidim/admin/users"

          include Decidim::Admin::WorkflowsBreadcrumb

          add_breadcrumb_item_from_menu :workflows_menu

          def index
            enforce_permission_to :index, :authorization

            @pending_authorizations = AuthorizationPresenter.for_collection(
              pending_authorizations
            )
          end

          private

          def pending_authorizations
            Authorizations.new(organization: current_organization, name: "postal_letter", granted: false)
          end
        end
      end
    end
  end
end
