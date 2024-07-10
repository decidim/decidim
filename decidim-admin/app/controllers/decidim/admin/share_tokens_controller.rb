# frozen_string_literal: true

module Decidim
  module Admin
    class ShareTokensController < Decidim::Admin::ApplicationController
      include Decidim::ComponentPathHelper
      helper_method :share_token, :share_tokens, :component

      def index; end

      def destroy
        enforce_permission_to(:destroy, :share_token, share_token:)

        Decidim::Commands::DestroyResource.call(share_token, current_user) do
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

      def component
        @component ||= current_participatory_space.components.find(params[:component_id])
      end

      def share_tokens
        Decidim::ShareToken.where(
          organization: current_organization
        )
      end

      def share_token
        @share_token ||= share_tokens.find(params[:id])
      end
    end
  end
end
