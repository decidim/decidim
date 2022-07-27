# frozen_string_literal: true

module Decidim
  module Admin
    class BlockUserController < Decidim::Admin::ApplicationController
      layout "decidim/admin/users"

      helper_method :user

      def new
        enforce_permission_to :block, :admin_user

        @form = form(BlockUserForm).from_model(user)
      end

      def create
        enforce_permission_to :block, :admin_user

        @form = form(BlockUserForm).from_params(params)

        BlockUser.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("officializations.block.success", scope: "decidim.admin")
            redirect_to officializations_path(q: { name_or_nickname_or_email_cont: user.name }), notice:
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

        redirect_to officializations_path(q: { name_or_nickname_or_email_cont: user.name }), notice:
      end

      private

      def user
        @user ||= Decidim::User.find_by(
          id: params[:user_id],
          organization: current_organization
        )
      end
    end
  end
end
