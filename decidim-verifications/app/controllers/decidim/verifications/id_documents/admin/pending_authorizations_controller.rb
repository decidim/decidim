# frozen_string_literal: true

module Decidim
  module Verifications
    module IdDocuments
      module Admin
        class PendingAuthorizationsController < Decidim::Admin::ApplicationController
          layout "decidim/admin/users"

          helper_method :has_offline_method?

          def index
            enforce_permission_to :index, :authorization

            @pending_online_authorizations = pending_online_authorizations
          end

          private

          def pending_online_authorizations
            Authorizations
              .new(organization: current_organization, name: "id_documents", granted: false)
              .query
              .where("verification_metadata->'rejected' IS NULL")
              .select { |auth| auth.verification_metadata["verification_type"] == "online" }
          end

          def has_offline_method?
            available_methods.include?("offline")
          end

          def available_methods
            @available_methods ||= current_organization.id_documents_methods
          end
        end
      end
    end
  end
end
