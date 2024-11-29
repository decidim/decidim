# frozen_string_literal: true

module Decidim
  module Admin
    class BlockUserController < Decidim::Admin::ApplicationController
      layout "decidim/admin/global_moderations"

      helper_method :user

      def new
        enforce_permission_to :block, :admin_user

        @form = form(BlockUserForm).from_model(user)
        @form.hide = params[:hide] || false
      end

      def create
        enforce_permission_to :block, :admin_user

        @form = form(BlockUserForm).from_params(params)

        BlockUser.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("officializations.block.success", scope: "decidim.admin")
            redirect_to moderated_users_path, notice:
          end

          on(:invalid) do
            flash[:alert] = I18n.t("officializations.block.error", scope: "decidim.admin")
            render :new
          end
        end
      end

      def destroy
        enforce_permission_to :block, :admin_user

        UnblockUser.call(user, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("officializations.unblock.success", scope: "decidim.admin")
          end

          on(:invalid) do
            flash[:alert] = I18n.t("officializations.unblock.error", scope: "decidim.admin")
          end
        end

        redirect_to moderated_users_path, notice:
      end

      def bulk_new
        enforce_permission_to :block, :admin_user

        @form = form(BlockUsersForm).from_params(params)
      end

      def bulk_create
        @form = form(BlockUsersForm).from_params(params)

        Admin::BulkBlockUsers.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("officializations.bulk_action.block.success", scope: "decidim.admin")
            redirect_to moderated_users_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("officializations.bulk_action.block.invalid", scope: "decidim.admin")
            render :bulk_new
          end
        end
      end

      def bulk_destroy
        Admin::BulkUnblockUsers.call(blocked_users, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("officializations.bulk_action.unblock.success", scope: "decidim.admin")
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("officializations.bulk_action.unblock.invalid", scope: "decidim.admin")
          end
        end
        redirect_to moderated_users_path
      end

      private

      def user
        @user ||= Decidim::UserBaseEntity.find_by(
          id: params[:user_id],
          organization: current_organization
        )
      end

      def blocked_users
        @blocked_users ||= Decidim::UserBaseEntity.where(
          id: params[:user_ids],
          organization: current_organization
        )
      end
    end
  end
end
