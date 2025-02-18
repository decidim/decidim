# frozen_string_literal: true

module Decidim
  module Admin
    class ModeratedUsersController < Decidim::Admin::ApplicationController
      include Decidim::ModeratedUsers::Admin::Filterable

      helper_method :moderated_users

      layout "decidim/admin/global_moderations"

      before_action :set_moderation_breadcrumb_item

      def index
        enforce_permission_to :read, :moderate_users

        @moderated_users = filtered_collection
      end

      def ignore
        enforce_permission_to :unreport, :moderate_users

        Admin::UnreportUser.call(reportable, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("reportable.unreport.success", scope: "decidim.moderations.admin")
            redirect_to moderated_users_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("reportable.unreport.invalid", scope: "decidim.moderations.admin")
            redirect_to moderated_users_path
          end
        end
      end

      def bulk_unreport
        Admin::BulkUnreportUsers.call(current_user, reportables) do
          on(:ok) do
            flash[:notice] = I18n.t("reportable.bulk_action.ignore.success", scope: "decidim.moderations.admin")
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("reportable.bulk_action.ignore.invalid", scope: "decidim.moderations.admin")
          end
        end
        redirect_to moderated_users_path
      end

      private

      def moderated_users
        @moderated_users ||= filtered_collection
      end

      def reportable
        @reportable ||= base_query_finder.find(params[:id]).user
      end

      def reportables
        @reportables ||= Decidim::UserBaseEntity.where(
          id: params[:user_ids],
          organization: current_organization
        )
      end

      def base_query_finder
        Decidim::Admin::ModerationStats.new(current_user).user_reports
      end

      def collection
        @collection ||= if params[:blocked]
                          base_query_finder.blocked
                        else
                          base_query_finder.unblocked
                        end
      end

      def set_moderation_breadcrumb_item
        controller_breadcrumb_items << {
          label: I18n.t("menu.reported_users", scope: "decidim.admin"),
          url: decidim_admin.moderated_users_path,
          active: true
        }
      end
    end
  end
end
