# frozen_string_literal: true

module Decidim
  module Admin
    # This controller allows admins to manage moderations in a participatory process.
    class ModerationsController < Decidim::Admin::ApplicationController
      helper_method :moderations, :check_permission_to, :allowed_to?

      def index
        ensure_access_to :read, Decidim::Moderation
      end

      def unreport
        ensure_access_to :unreport

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
        ensure_access_to :hide

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

      private

      # Overwrites the method provided by the `Decidim::NeedsPermission` concern
      # that checks whether the user can perform the action or not.
      #
      # Returns false to ensure there are no false positives.
      def allowed_to?(*)
        false
      end

      # A convenience method so that spaces can override how to deal with
      # permissions/abilities to perform the action.
      def ensure_access_to(action, subject = reportable)
        authorize! action, subject
      end

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
