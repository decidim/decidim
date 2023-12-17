# frozen_string_literal: true

module Decidim
  module Meetings
    module Admin
      # Controller that allows inviting users to join a meeting.
      #
      class InvitesController < Admin::ApplicationController
        helper_method :collection

        include Decidim::Meetings::Admin::Invites::Filterable

        def index
          enforce_permission_to(:read_invites, :meeting, meeting:)

          @invites = filtered_collection
          @form = form(MeetingRegistrationInviteForm).instance
        end

        def create
          enforce_permission_to(:invite_attendee, :meeting, meeting:)

          @form = form(MeetingRegistrationInviteForm).from_params(params)

          InviteUserToJoinMeeting.call(@form, meeting, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("invites.create.success", scope: "decidim.meetings.admin")
              redirect_to meeting_registrations_invites_path(meeting)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("invites.create.error", scope: "decidim.meetings.admin")
              render :index
            end
          end
        end

        private

        def meeting
          @meeting ||= Meeting.where(component: current_component).find(params[:meeting_id])
        end

        def collection
          meeting.invites
        end
      end
    end
  end
end
