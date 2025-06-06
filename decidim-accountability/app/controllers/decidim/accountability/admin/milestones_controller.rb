# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This controller allows an admin to manage milestones for a Result
      class MilestonesController < Admin::ApplicationController
        helper_method :result, :milestones

        def new
          enforce_permission_to :create, :milestone

          @form = form(MilestoneEntryForm).instance
        end

        def create
          enforce_permission_to :create, :milestone

          @form = form(MilestoneEntryForm).from_params(params)
          @form.decidim_accountability_result_id = params[:result_id]

          CreateMilestoneEntry.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("milestone_entries.create.success", scope: "decidim.accountability.admin")
              redirect_to result_milestones_path(params[:result_id])
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("milestone_entries.create.invalid", scope: "decidim.accountability.admin")
              render action: "new"
            end
          end
        end

        def edit
          enforce_permission_to(:update, :milestone, milestone:)

          @form = form(MilestoneEntryForm).from_model(milestone)
        end

        def update
          enforce_permission_to(:update, :milestone, milestone:)

          @form = form(MilestoneEntryForm).from_params(params)

          UpdateMilestoneEntry.call(@form, milestone) do
            on(:ok) do
              flash[:notice] = I18n.t("milestone_entries.update.success", scope: "decidim.accountability.admin")
              redirect_to result_milestones_path(params[:result_id])
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("milestone_entries.update.invalid", scope: "decidim.accountability.admin")
              render action: "edit"
            end
          end
        end

        def destroy
          enforce_permission_to(:destroy, :milestone, milestone:)

          Decidim::Commands::DestroyResource.call(milestone, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("milestone_entries.destroy.success", scope: "decidim.accountability.admin")

              redirect_to result_milestones_path(params[:result_id])
            end
          end
        end

        private

        def milestones
          @milestones ||= result.milestones.page(params[:page]).per(15)
        end

        def milestone
          @milestone ||= milestones.find(params[:id])
        end

        def result
          @result ||= Result.where(component: current_component).find(params[:result_id])
        end
      end
    end
  end
end
