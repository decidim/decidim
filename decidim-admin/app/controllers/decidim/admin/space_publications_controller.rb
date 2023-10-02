# frozen_string_literal: true

module Decidim
  module Admin
    # Base controller that can be inherited by other spaces to publish and unpublish the Participatory Space
    #
    class SpacePublicationsController < Decidim::Admin::ApplicationController
      def create
        enforce_permission_to_publish

        publish_command.call(current_participatory_space, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("create.success", scope: i18n_scope)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("create.error", scope: i18n_scope)
          end

          redirect_back(fallback_location:)
        end
      end

      def destroy
        enforce_permission_to_publish

        unpublish_command.call(current_participatory_space, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("destroy.success", scope: i18n_scope)
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("destroy.error", scope: i18n_scope)
          end

          redirect_back(fallback_location:)
        end
      end

      private

      def publish_command = Decidim::Admin::ParticipatorySpace::Publish

      def unpublish_command = Decidim::Admin::ParticipatorySpace::Unpublish

      def current_participatory_space = raise "Not implemented"

      def enforce_permission_to_publish = raise "Not implemented"

      def i18n_scope = raise "Not implemented"
    end
  end
end
