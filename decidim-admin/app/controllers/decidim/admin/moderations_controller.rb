# frozen_string_literal: true

module Decidim
  module Admin
    # This controller allows admins to manage moderations in a participatory process.
    class ModerationsController < Decidim::Admin::ApplicationController
      helper_method :downstream_moderations
      helper_method :upstream_moderations

      def index
        authorize! :read, Decidim::Moderation
        @upstream =  true if params[:moderation_type] == "upstream"
        @downstream = true if params[:moderation_type] == "downstream"
      end

      def authorize
        authorize! :authorize, Decidim::Moderation
        @moderation = Decidim::Moderation.find(params[:id])
        @moderation.authorize!
        redirect_to moderations_path(moderation_type: "upstream")
      end

      # This action is use to hide or to set as refused moderated object
      def hide
        authorize! :hide, reportable
        if params[:refuse]
          reportable.moderation.refuse!
          redirect_to moderations_path(moderation_type: "upstream")
        else
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

      private


      def downstream_moderations
        @downstream_moderations ||= begin
          if params[:hidden] && params[:moderation_type] == "downstream"
            participatory_space_moderations.where.not(hidden_at: nil, report_count: 0).order("created_at").reverse
          elsif params[:moderation_type] == "downstream"
            participatory_space_moderations.where(hidden_at: nil).where.not( report_count: 0).order("created_at").reverse
          end
        end
      end

      def upstream_moderations
        @upstream_moderations ||= begin
          if params[:moderated] && params[:moderation_type] == "upstream"
            participatory_space_moderations.where.not(upstream_moderation: "unmoderate").order("created_at").reverse
          elsif params[:moderation_type] == "upstream"
            participatory_space_moderations.where(upstream_moderation: "unmoderate").order("created_at").reverse
          end
        end
      end

      # def filtered_upstream_moderation
      #   moderation_ids = participatory_space_moderations.map(&:get_upstream_moderation)

      # end

      def reportable
        @reportable ||= participatory_space_moderations.find(params[:id]).reportable
      end

      def participatory_space_moderations
        @participatory_space_moderations ||= Decidim::Moderation.where(participatory_space: current_participatory_space)
      end
    end
  end
end
