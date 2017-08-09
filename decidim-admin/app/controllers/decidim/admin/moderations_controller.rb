# frozen_string_literal: true

module Decidim
  module Admin
    # This controller allows admins to manage moderations in a participatory process.
    class ModerationsController < Decidim::Admin::ApplicationController
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
            redirect_to moderations_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("reportable.unreport.invalid", scope: "decidim.moderations.admin")
            redirect_to moderations_path
          end
        end
      end

      def hide
        authorize! :hide, reportable

        Admin::HideResource.call(reportable) do
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

      private

      def moderations
        @moderations ||= begin
          if params[:hidden]
            participatory_process_moderations.where.not(hidden_at: nil)
          else
            participatory_process_moderations.where(hidden_at: nil)
          end
        end
      end

      def reportable
        @reportable ||= participatory_process_moderations.find(params[:id]).reportable
      end

      def participatory_process_moderations
        @participatory_process_moderations ||= Decidim::Moderation.where(participatory_process: current_participatory_process)
      end
    end
  end
end
