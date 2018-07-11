# frozen_string_literal: true

require_dependency "decidim/admin/application_controller"

module Decidim
  module Meetings
    module Admin
      # Controller that allows inviting users to join a meeting.
      #
      class InvitesController < Admin::ApplicationController
        helper_method :invites

        def index
          enforce_permission_to :read_invites, :meeting, meeting: meeting

          @query = params[:q]
          @status = params[:status]

          @form = form(MeetingRegistrationInviteForm).instance
        end

        def create
          enforce_permission_to :invite_attendee, :meeting, meeting: meeting

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

        def invites
          @invites ||= Decidim::Meetings::Admin::Invites.for(meeting.invites, @query, @status).page(params[:page]).per(15)
        end
      end
    end
  end
end
