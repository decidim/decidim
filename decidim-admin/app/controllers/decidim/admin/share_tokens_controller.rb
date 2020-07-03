# frozen_string_literal: true

module Decidim
  module Admin
    class ShareTokensController < Decidim::Admin::ApplicationController
      def destroy
        enforce_permission_to :destroy, :share_token, share_token: share_token

        DestroyShareToken.call(share_token, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("share_tokens.destroy.success", scope: "decidim.admin")
          end
          on(:invalid) do
            flash[:error] = I18n.t("share_tokens.destroy.error", scope: "decidim.admin")
          end
        end

        redirect_back(fallback_location: root_path)
      end

      private

      def share_token
        @share_token ||= Decidim::ShareToken.where(
          organization: current_organization
        ).find(params[:id])
      end
    end
  end
end
