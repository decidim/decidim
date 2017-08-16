# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing user groups at the admin panel.
    #
    class UserGroupsController < Decidim::Admin::ApplicationController
      layout "decidim/admin/users"

      def index
        authorize! :index, UserGroup
        @query = params[:q]
        @state = params[:state]

        @user_groups = Decidim::Admin::UserGroupsEvaluation.for(collection, @query, @state)
                                                           .page(params[:page]).per(15)
      end

      def verify
        @user_group = collection.find(params[:id])
        authorize! :verify, @user_group

        VerifyUserGroup.call(@user_group) do
          on(:ok) do
            flash[:notice] = I18n.t("user_group.verify.success", scope: "decidim.admin")
            redirect_back(fallback_location: decidim_admin.user_groups_path)
          end

          on(:invalid) do
            flash[:alert] = I18n.t("user_group.verify.invalid", scope: "decidim.admin")
            redirect_back(fallback_location: decidim_admin.user_groups_path)
          end
        end
      end

      def reject
        @user_group = collection.find(params[:id])
        authorize! :reject, @user_group

        RejectUserGroup.call(@user_group) do
          on(:ok) do
            flash[:notice] = I18n.t("user_group.reject.success", scope: "decidim.admin")
            redirect_back(fallback_location: decidim_admin.user_groups_path)
          end

          on(:invalid) do
            flash[:alert] = I18n.t("user_group.reject.invalid", scope: "decidim.admin")
            redirect_back(fallback_location: decidim_admin.user_groups_path)
          end
        end
      end

      private

      def collection
        UserGroup
          .includes(:memberships)
          .where(decidim_user_group_memberships: { decidim_user_id: current_organization.users })
      end
    end
  end
end
