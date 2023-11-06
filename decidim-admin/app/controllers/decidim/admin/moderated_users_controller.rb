# frozen_string_literal: true

module Decidim
  module Admin
    class ModeratedUsersController < Decidim::Admin::ApplicationController
      include Decidim::ModeratedUsers::Admin::Filterable

      layout "decidim/admin/global_moderations"

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

      private

      def reportable
        @reportable ||= base_query_finder.find(params[:id]).user
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
    end
  end
end
