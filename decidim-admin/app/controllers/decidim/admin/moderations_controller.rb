# frozen_string_literal: true

module Decidim
  module Admin
    # This controller allows admins to manage moderations in a participatory process.
    class ModerationsController < Admin::ApplicationController
      include Concerns::ParticipatoryProcessAdmin

      helper_method :moderations

      def index
        authorize! :read, Decidim::Moderation
      end

      def unreport
        authorize! :unreport, reportable

        Admin::UnreportResource.call(reportable) do
          on(:ok) do
            flash[:notice] = I18n.t("reportable.unreport.success", scope: "decidim.moderations.admin")
            redirect_to decidim_admin.participatory_process_moderations_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("reportable.unreport.invalid", scope: "decidim.moderations.admin")
            redirect_to decidim_admin.participatory_process_moderations_path
          end
        end
      end

      def hide
        authorize! :hide, reportable

        Admin::HideResource.call(reportable) do
          on(:ok) do
            flash[:notice] = I18n.t("reportable.hide.success", scope: "decidim.moderations.admin")
            redirect_to decidim_admin.participatory_process_moderations_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("reportable.hide.invalid", scope: "decidim.moderations.admin")
            redirect_to decidim_admin.participatory_process_moderations_path
          end
        end
      end

      private

      def moderations
        @moderations ||= begin
          moderations = Decidim::Moderation.where(participatory_process: participatory_process)
          if params[:hidden]
            moderations.where.not(hidden_at: nil)
          else
            moderations.where(hidden_at: nil)
          end
        end
      end

      def reportable
        @reportable ||= Decidim::Moderation.where(participatory_process: participatory_process).find(params[:id]).reportable
      end
    end
  end
end
