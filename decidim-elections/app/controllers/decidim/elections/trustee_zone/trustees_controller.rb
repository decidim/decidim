# frozen_string_literal: true

module Decidim
  module Elections
    module TrusteeZone
      # Exposes the trustee zone for trustee users
      class TrusteesController < ::Decidim::ApplicationController
        include Decidim::UserProfile
        include Decidim::FormFactory

        helper_method :trustee

        def show
          enforce_permission_to :view, :trustee, trustee: trustee

          trustee.name ||= current_user.name
        end

        def update
          enforce_permission_to :update, :trustee, trustee: trustee

          form = form(TrusteeForm).from_params(params, trustee: trustee)

          UpdateTrustee.call(form) do
            on(:ok) do
              flash[:notice] = I18n.t("trustees.update.success", scope: "decidim.elections.trustee_zone")
            end

            on(:invalid) do
              flash[:alert] = form.errors.full_messages.to_sentence
            end
          end

          redirect_to trustee_path
        end

        private

        def trustee
          @trustee ||= Decidim::Elections::Trustee.for(current_user)
        end

        def permission_scope
          :trustee_zone
        end

        def permission_class_chain
          [
            Decidim::Elections::Permissions,
            Decidim::Permissions
          ]
        end
      end
    end
  end
end
