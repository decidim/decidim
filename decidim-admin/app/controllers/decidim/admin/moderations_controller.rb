# frozen_string_literal: true

module Decidim
  module Admin
    # This controller allows admins to manage moderations in a participatory process.
    class ModerationsController < Decidim::Admin::ApplicationController
      include Decidim::Moderations::Admin::Filterable

      helper_method :moderations, :allowed_to?, :query, :permission_resource

      def index
        enforce_permission_to :read, permission_resource
      end

      def show
        enforce_permission_to :read, permission_resource
        @moderation = collection.find(params[:id])
      end

      def unreport
        enforce_permission_to :unreport, permission_resource

        Admin::UnreportResource.call(reportable, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("reportable.unreport.success", scope: "decidim.moderations.admin")
            redirect_to moderations_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("reportable.unreport.invalid", scope: "decidim.moderations.admin")
            redirect_to moderations_path
          end
        end
      end

      def hide
        enforce_permission_to :hide, permission_resource

        Admin::HideResource.call(reportable, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("reportable.hide.success", scope: "decidim.moderations.admin")
            redirect_to moderations_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("reportable.hide.invalid", scope: "decidim.moderations.admin")
            redirect_to moderations_path
          end
        end
      end

      def unhide
        enforce_permission_to :unhide, permission_resource

        Admin::UnhideResource.call(reportable, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("reportable.unhide.success", scope: "decidim.moderations.admin")
            redirect_to moderations_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("reportable.unhide.invalid", scope: "decidim.moderations.admin")
            redirect_to moderations_path
          end
        end
      end

      private

      def ransack_params
        query_params[:q] || { s: "created_at desc" }
      end

      # Private: This method is used by the `Filterable` concern as the base query
      #          without applying filtering and/or sorting options.
      def collection
        @collection ||= if params[:hidden]
                          participatory_space_moderations.hidden
                        else
                          participatory_space_moderations.not_hidden
                        end
      end

      # Private: Returns a collection of `Moderation` filtered and/or sorted by
      #          some criteria. The `filtered_collection` is provided by the
      #          `Filterable` concern.
      def moderations
        @moderations ||= filtered_collection
      end

      def reportable
        @reportable ||= participatory_space_moderations.find(params[:id]).reportable
      end

      def participatory_space_moderations
        @participatory_space_moderations ||= Decidim::Moderation.where(participatory_space: current_participatory_space)
      end

      # Private: Defines the resource that permissions will check. This is
      # added so that the `GlobalModerationController` can overwrite this method
      # and define the custom permission resource, so that the permission system
      # is not overridden.
      def permission_resource
        :moderation
      end
    end
  end
end
