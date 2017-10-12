# frozen_string_literal: true

module Decidim
  module Verifications
    module PostalLetter
      module Admin
        class PendingAuthorizationsController < Decidim::Admin::ApplicationController
          layout "decidim/admin/users"

          def index
            authorize! :index, Authorization

            @pending_authorizations = AuthorizationPresenter.for_collection(
              pending_authorizations
            )
          end

          private

          def pending_authorizations
            Authorizations.new(name: "postal_letter", granted: false)
          end
        end
      end
    end
  end
end
