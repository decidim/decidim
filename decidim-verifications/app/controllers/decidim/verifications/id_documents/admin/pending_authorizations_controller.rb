# frozen_string_literal: true

module Decidim
  module Verifications
    module IdDocuments
      module Admin
        class PendingAuthorizationsController < Decidim::Admin::ApplicationController
          layout "decidim/admin/users"

          def index
            authorize! :index, Authorization

            @pending_authorizations = pending_authorizations
          end

          private

          def pending_authorizations
            Authorizations
              .new(name: "id_documents", granted: false)
              .query
              .where("verification_metadata->'rejected' IS NULL")
          end
        end
      end
    end
  end
end
