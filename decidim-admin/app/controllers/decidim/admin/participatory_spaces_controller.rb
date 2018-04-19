# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing participatory spaces.
    class ParticipatorySpacesController < Decidim::Admin::ApplicationController
      layout "decidim/admin/settings"
      helper_method :participatory_spaces

      def index
        authorize! :index, ParticipatorySpace
      end

      def activate
        authorize! :activate, participatory_space
        
        ActivateParticipatorySpace.call(participatory_space, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("participatory_spaces.activate.success", scope: "decidim.admin")
            redirect_to participatory_spaces_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("participatory_spaces.activate.error", scope: "decidim.admin")
            redirect_to participatory_spaces_path
          end
        end
      end

      def deactivate
        authorize! :deactivate, participatory_space
        
        DeactivateParticipatorySpace.call(participatory_space, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("participatory_spaces.deactivate.success", scope: "decidim.admin")
            redirect_to participatory_spaces_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("participatory_spaces.deactivate.error", scope: "decidim.admin")
            redirect_to participatory_spaces_path
          end
        end
      end

      def publish
        authorize! :publish, participatory_space
        
        PublishParticipatorySpace.call(participatory_space, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("participatory_spaces.publish.success", scope: "decidim.admin")
            redirect_to participatory_spaces_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("participatory_spaces.publish.error", scope: "decidim.admin")
            redirect_to participatory_spaces_path
          end
        end
      end

      def unpublish
        authorize! :unpublish, participatory_space
        
        UnpublishParticipatorySpace.call(participatory_space, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("participatory_spaces.unpublish.success", scope: "decidim.admin")
            redirect_to participatory_spaces_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("participatory_spaces.unpublish.error", scope: "decidim.admin")
            redirect_to participatory_spaces_path
          end
        end
      end

      private

      def participatory_space
        @participatory_space ||= participatory_spaces
          .find { |space| space.manifest_name == params[:id] }
      end

      def participatory_spaces
        @participatory_spaces ||= Decidim.participatory_space_manifests
          .map { |manifest| manifest.space_for(current_organization) }
          .sort_by(&:manifest_name)
      end
    end
  end
end
