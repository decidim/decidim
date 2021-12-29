# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing user groups at the admin panel.
    #
    class UserGroupsController < Decidim::Admin::ApplicationController
      include UserGroups
      include Decidim::Admin::UserGroups::Filterable

      before_action :enforce_user_groups_enabled

      layout "decidim/admin/users"

      def index
        enforce_permission_to :index, :user_group

        @user_groups = filtered_collection
      end

      def verify
        @user_group = collection.find(params[:id])
        enforce_permission_to :verify, :user_group, user_group: @user_group

        VerifyUserGroup.call(@user_group, current_user) do
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
        enforce_permission_to :reject, :user_group, user_group: @user_group

        RejectUserGroup.call(@user_group, current_user) do
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

      def filtered_collection
        paginate(query.result)
      end

      def base_query
        Decidim::Admin::UserGroupsEvaluation.for(collection, @query, @state)
      end

      def collection
        UserGroup
          .left_outer_joins(:memberships)
          .select("decidim_users.*, COUNT(decidim_user_group_memberships.decidim_user_group_id) as users_count")
          .where(decidim_user_group_memberships: { decidim_user_id: current_organization.users })
          .group(Arel.sql("decidim_users.id"))
      end
    end
  end
end
