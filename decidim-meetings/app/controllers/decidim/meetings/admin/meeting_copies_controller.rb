# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # Controller that allows managing meetings.
      #
      class MeetingCopiesController < Admin::ApplicationController
        helper_method :meeting, :blank_service

        def new
          enforce_permission_to :copy, :meeting, meeting: meeting

          @form = form(MeetingCopyForm).from_model(meeting)
        end

        def create
          enforce_permission_to :copy, :meeting, meeting: meeting

          @form = form(MeetingCopyForm).from_params(params, current_component:)

          CopyMeeting.call(@form, meeting) do
            on(:ok) do
              flash[:notice] = I18n.t("meeting_copies.create.success", scope: "decidim.admin")
              redirect_to meetings_path
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("meeting_copies.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        private

        def blank_service
          @blank_service ||= Admin::MeetingServiceForm.new
        end

        def meeting
          @meeting ||= Meeting.where(component: current_component).find(params[:meeting_id])
        end
      end
    end
  end
end
