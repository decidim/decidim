# frozen_string_literal: true

module Decidim
  module Admin
    class ConflictsController < Decidim::Admin::ApplicationController
      layout "decidim/admin/users"

      def index
        @conflicts = Decidim::Verifications::Conflict.joins(:current_user).where(
          decidim_users: { decidim_organization_id: current_organization.id }
        )
      end

      def edit
        conflict = Decidim::Verifications::Conflict.find(params[:id])

        @form = form(TransferUserForm).from_params(
          user: conflict.current_user,
          managed_user: conflict.managed_user,
          conflict:
        )
      end

      def update
        conflict = Decidim::Verifications::Conflict.find(params[:id])

        @form = form(TransferUserForm).from_params(
          current_user:,
          conflict:,
          reason: params[:transfer_user][:reason],
          email: params[:transfer_user][:email]
        )

        TransferUser.call(@form) do
          on(:ok) do
            flash[:notice] = I18n.t("success", scope: "decidim.admin.conflicts.transfer")
            redirect_to conflicts_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("error", scope: "decidim.admin.conflicts.transfer")
            redirect_to decidim.root_path
          end
        end
      end
    end
  end
end
