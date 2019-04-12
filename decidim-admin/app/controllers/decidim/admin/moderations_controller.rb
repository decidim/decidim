# frozen_string_literal: true

module Decidim
  module Admin
    # This controller allows admins to manage moderations in a participatory process.
    class ModerationsController < Decidim::Admin::ApplicationController
      helper_method :moderations, :allowed_to?

      def index
        enforce_permission_to :read, :moderation
      end

      def unreport
        enforce_permission_to :unreport, :moderation

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
        enforce_permission_to :hide, :moderation

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
        enforce_permission_to :unhide, :moderation

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

      def moderations
        @moderations ||= begin
          if params[:hidden]
            participatory_space_moderations.where.not(hidden_at: nil)
          else
            participatory_space_moderations.where(hidden_at: nil)
          end
        end
      end

      def reportable
        @reportable ||= participatory_space_moderations.find(params[:id]).reportable
      end

      def participatory_space_moderations
        @participatory_space_moderations ||= Decidim::Moderation.where(participatory_space: current_participatory_space)
      end
    end
  end
end
