# frozen_string_literal: true

require_dependency "decidim/admin/application_controller"

module Decidim
  module Conferences
    module Admin
      # Controller that allows inviting users to join a conference.
      #
      class ConferenceInvitesController < Decidim::Conferences::Admin::ApplicationController
        include Concerns::ConferenceAdmin

        helper_method :conference

        def index
          enforce_permission_to :read_invites, :conference, conference: conference

          @query = params[:q]
          @status = params[:status]
          @conference_invites = Decidim::Conferences::Admin::ConferenceInvites.for(conference.conference_invites, @query, @status).page(params[:page]).per(15)
        end

        def new
          enforce_permission_to :invite_attendee, :conference, conference: conference

          @form = form(ConferenceRegistrationInviteForm).instance
        end

        def create
          enforce_permission_to :invite_attendee, :conference, conference: conference

          @form = form(ConferenceRegistrationInviteForm).from_params(params)

          InviteUserToJoinConference.call(@form, conference, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("conference_invites.create.success", scope: "decidim.conferences.admin")
              redirect_to conference_conference_invites_path(conference)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("conference_invites.create.error", scope: "decidim.conferences.admin")
              render :new
            end
          end
        end

        private

        def conference
          @conference ||= Decidim::Conference.find_by(slug: params[:conference_slug])
        end
      end
    end
  end
end
