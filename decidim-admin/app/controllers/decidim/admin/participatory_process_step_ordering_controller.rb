# frozen_string_literal: true
require_dependency "decidim/admin/application_controller"

module Decidim
  module Admin
    # Controller that allows managing all the Admins.
    #
    class ParticipatoryProcessStepOrderingController < ApplicationController
      def create
        authorize ParticipatoryProcessStep

        if order
          ReorderParticipatoryProcessSteps.call(collection, order) do
            on(:invalid) do
              flash.now[:alert] = I18n.t("participatory_process_steps.ordering.error", scope: "decidim.admin")
              redirect_to participatory_process_path(participatory_process)
            end
          end
        else
          flash.now[:alert] = I18n.t("participatory_process_steps.ordering.error", scope: "decidim.admin")
          redirect_to participatory_process_path(participatory_process)
        end
      end

      private

      def participatory_process
        current_organization.participatory_processes.find(params[:participatory_process_id])
      end

      def collection
        participatory_process.steps
      end

      def policy_class(_record)
        Decidim::Admin::ParticipatoryProcessPolicy
      end

      def order
        return @order if @order
        return nil unless params[:items_ids].present?

        @order = params[:items_ids]

        return nil unless @order.is_a?(Array) && @order.present?

        @order
      end
    end
  end
end
