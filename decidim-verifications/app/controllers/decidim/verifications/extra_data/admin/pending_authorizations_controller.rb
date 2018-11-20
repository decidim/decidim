# frozen_string_literal: true

module Decidim
  module Verifications
    module ExtraData
      module Admin
        class PendingAuthorizationsController < Decidim::Admin::ApplicationController
          layout "decidim/admin/users"

          def index
            enforce_permission_to :index, :authorization

            @pending_authorizations = pending_authorizations
          end

          private

          def pending_authorizations
            Authorizations
              .new(organization: current_organization, name: "extra_data", granted: false)
              .query
              .where("verification_metadata->'rejected' IS NULL")
          end
        end
      end
    end
  end
end
