# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # This controller allows an admin to manage minutes from a Meeting
      class MinutesController < Admin::ApplicationController
        helper_method :current_meeting, :minutes

        def new
          enforce_permission_to :create, :minutes, meeting: current_meeting

          @form = form(MinutesForm).instance
        end

        def create
          enforce_permission_to :create, :minutes, meeting: current_meeting

          @form = form(MinutesForm).from_params(params)

          CreateMinutes.call(@form, current_meeting) do
            on(:ok) do
              flash[:notice] = I18n.t("minutes.create.success", scope: "decidim.meetings.admin")
              redirect_to meetings_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("minutes.create.invalid", scope: "decidim.meetings.admin")
              render action: "new"
            end
          end
        end

        def edit
          enforce_permission_to :update, :minutes, minutes: minutes, meeting: current_meeting

          @form = form(MinutesForm).from_model(minutes)
        end

        def update
          enforce_permission_to :update, :minutes, minutes: minutes, meeting: current_meeting

          @form = form(MinutesForm).from_params(params)
          UpdateMinutes.call(@form, current_meeting, minutes) do
            on(:ok) do
              flash[:notice] = I18n.t("minutes.update.success", scope: "decidim.meetings.admin")
              redirect_to meetings_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("minutes.update.invalid", scope: "decidim.meetings.admin")
              render action: "edit"
            end
          end
        end

        private

        def current_meeting
          @current_meeting ||= Meeting.where(component: current_component).find(params[:meeting_id])
        end

        def minutes
          @minutes ||= Minutes.where(meeting: current_meeting).find(params[:id])
        end
      end
    end
  end
end
