# frozen_string_literal: true

require_dependency "decidim/admin/application_controller"

module Decidim
  module Meetings
    module Admin
      # Controller that allows inviting users to join a meeting.
      #
      class InvitesController < Admin::ApplicationController
        def new
          @form = form(MeetingRegistrationInviteForm).instance
        end

        def create
          @form = form(MeetingRegistrationInviteForm).from_params(params)

          InviteUserToJoinMeeting.call(@form, meeting, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("invites.create.success", scope: "decidim.meetings.admin")
              redirect_to edit_meeting_registrations_path(meeting)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("invites.create.error", scope: "decidim.meetings.admin")
              render :new
            end
          end
        end

        private

        def meeting
          @meeting ||= Meeting.where(feature: current_feature).find(params[:meeting_id])
        end
      end
    end
  end
end
