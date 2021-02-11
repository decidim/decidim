# frozen_string_literal: true

module Decidim
  module Admin
    class ModeratedUsersController < Decidim::Admin::ApplicationController
      include Decidim::Moderations::Admin::Filterable

      layout "decidim/admin/users"

      def index
        enforce_permission_to :read, :moderate_users

        @moderated_users = filtered_collection.page(params[:page]).per(15)
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
        @reportable ||= UserModeration.find(params[:id]).user
      end

      def collection
        target_scope = params[:blocked] && params[:blocked] == "true" ? :blocked : :unblocked
        UserModeration.send(target_scope)
      end
    end
  end
end
