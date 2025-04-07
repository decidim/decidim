# frozen_string_literal: true

module Decidim
  module Admin
    # This controller allows admins to manage moderations in a participatory process.
    class ModerationsController < Decidim::Admin::ApplicationController
      include Decidim::Moderations::Admin::Filterable

      helper_method :moderations, :allowed_to?, :query, :authorization_scope

      before_action :set_moderation_breadcrumb_item

      def index
        enforce_permission_to :read, authorization_scope
      end

      def show
        enforce_permission_to :read, authorization_scope
        @moderation = collection.find(params[:id])
      end

      def unreport
        enforce_permission_to :unreport, authorization_scope

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
        enforce_permission_to :hide, authorization_scope

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
        enforce_permission_to :unhide, authorization_scope

        Admin::UnhideResource.call(reportable, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("reportable.unhide.success", scope: "decidim.moderations.admin")
            redirect_to moderations_path(hidden: true)
          end

          on(:parent_invalid) do
            flash[:alert] = I18n.t("reportable.unhide.parent_invalid", scope: "decidim.moderations.admin")
            redirect_to moderations_path(hidden: true)
          end

          on(:invalid) do
            flash[:alert] = I18n.t("reportable.unhide.invalid", scope: "decidim.moderations.admin")
            redirect_to moderations_path(hidden: true)
          end
        end
      end

      def bulk_action
        Admin::BulkAction.call(current_user, params[:bulk_action], selected_moderations) do
          on(:ok) do |ok, ko|
            flash[:notice] = I18n.t("reportable.bulk_action.#{params[:bulk_action]}.success", scope: "decidim.moderations.admin", count_ok: ok.count) if ok.count.positive?
            flash[:alert] = I18n.t("reportable.bulk_action.#{params[:bulk_action]}.failed", scope: "decidim.moderations.admin", errored: ko.join(", ")) if ko.present? && ko.any?
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("reportable.bulk_action.#{params[:bulk_action]}.invalid", scope: "decidim.moderations.admin")
          end
        end
        redirect_to moderations_path
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

      def selected_moderations
        @selected_moderations ||= participatory_space_moderations.where(id: params[:moderation_ids])
      end

      def participatory_space_moderations
        @participatory_space_moderations ||= Decidim::Moderation.where(participatory_space: current_participatory_space)
      end

      # Private: Defines the resource that permissions will check. This is
      # added so that the `GlobalModerationController` can overwrite this method
      # and define the custom permission resource, so that the permission system
      # is not overridden.
      def authorization_scope
        :moderation
      end

      def set_moderation_breadcrumb_item
        controller_breadcrumb_items << {
          label: I18n.t("menu.content", scope: "decidim.admin"),
          url: decidim_admin.moderations_path,
          active: true
        }
      end
    end
  end
end
