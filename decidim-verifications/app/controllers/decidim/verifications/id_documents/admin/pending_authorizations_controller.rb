# frozen_string_literal: true

module Decidim
  module Verifications
    module IdDocuments
      module Admin
        class PendingAuthorizationsController < Decidim::Admin::ApplicationController
          layout "decidim/admin/users"

          def index
            authorize! :index, Authorization

            @pending_authorizations =
              Authorizations.new(name: "id_documents", granted: false)
          end
        end
      end
    end
  end
end
