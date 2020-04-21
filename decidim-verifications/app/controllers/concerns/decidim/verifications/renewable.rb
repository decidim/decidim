# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Verifications
    # Common logic to renew authorizations
    module Renewable
      extend ActiveSupport::Concern
      included do
        def renew
          enforce_permission_to :renew, :authorization, authorization: authorization

          DestroyUserAuthorization.call(authorization) do
            on(:ok, authorization) do
              flash[:notice] = t("authorizations.destroy.success", scope: "decidim.verifications")
              redirect_to new_authorization_path(handler: authorization.name)
            end

            on(:invalid) do
              flash[:alert] = t("authorizations.destroy.error", scope: "decidim.verifications")
              redirect_to authorizations_path
            end
          end
        end

        def renew_modal
          enforce_permission_to :renew, :authorization, authorization: authorization

          respond_to do |format|
            format.html { render layout: nil }
          end
        end
      end
    end
  end
end
