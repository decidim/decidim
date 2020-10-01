# frozen_string_literal: true

module Decidim
  module Elections
    module Admin
      # This controller allows the create or update trustees.
      class TrusteesParticipatorySpacesController < Admin::ApplicationController
        helper_method :trustees, :trustee

        def edit
          enforce_permission_to :update, :trustee_participatory_space, trustee_participatory_space: trustee_participatory_space

          UpdateTrusteeParticipatorySpace.call(trustee_participatory_space) do
            on(:ok) do |trustee|
              flash[:notice] = I18n.t("trustee_participatory_space.update.success", scope: "decidim.elections.admin", trustee: trustee.user.name)
            end

            on(:invalid) do  |trustee|
              flash.now[:alert] = I18n.t("trustee_participatory_space.update.invalid", scope: "decidim.elections.admin", trustee: trustee.user.name)
            end

            redirect_to trustees_path
          end
        end


        private

        def trustee_participatory_space
          @trustee_participatory_space ||= TrusteesParticipatorySpace.find_by(id: params[:id])
        end
      end
    end
  end
end
