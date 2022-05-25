# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This controller allows an admin to manage timeline entries for a Result
      class TimelineEntriesController < Admin::ApplicationController
        helper_method :result, :timeline_entries

        def new
          enforce_permission_to :create, :timeline_entry

          @form = form(TimelineEntryForm).instance
        end

        def create
          enforce_permission_to :create, :timeline_entry

          @form = form(TimelineEntryForm).from_params(params)
          @form.decidim_accountability_result_id = params[:result_id]

          CreateTimelineEntry.call(@form, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("timeline_entries.create.success", scope: "decidim.accountability.admin")
              redirect_to result_timeline_entries_path(params[:result_id])
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("timeline_entries.create.invalid", scope: "decidim.accountability.admin")
              render action: "new"
            end
          end
        end

        def edit
          enforce_permission_to :update, :timeline_entry, timeline_entry: timeline_entry

          @form = form(TimelineEntryForm).from_model(timeline_entry)
        end

        def update
          enforce_permission_to :update, :timeline_entry, timeline_entry: timeline_entry

          @form = form(TimelineEntryForm).from_params(params)

          UpdateTimelineEntry.call(@form, timeline_entry, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("timeline_entries.update.success", scope: "decidim.accountability.admin")
              redirect_to result_timeline_entries_path(params[:result_id])
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("timeline_entries.update.invalid", scope: "decidim.accountability.admin")
              render action: "edit"
            end
          end
        end

        def destroy
          enforce_permission_to :destroy, :timeline_entry, timeline_entry: timeline_entry

          Decidim.traceability.perform_action!("delete", timeline_entry, current_user) do
            timeline_entry.destroy!
          end

          flash[:notice] = I18n.t("timeline_entries.destroy.success", scope: "decidim.accountability.admin")

          redirect_to result_timeline_entries_path(params[:result_id])
        end

        private

        def timeline_entries
          @timeline_entries ||= result.timeline_entries.page(params[:page]).per(15)
        end

        def timeline_entry
          @timeline_entry ||= timeline_entries.find(params[:id])
        end

        def result
          @result ||= Result.where(component: current_component).find(params[:result_id])
        end
      end
    end
  end
end
