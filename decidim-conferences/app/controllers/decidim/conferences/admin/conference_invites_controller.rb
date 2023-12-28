# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # Controller that allows inviting users to join a conference.
      #
      class ConferenceInvitesController < Decidim::Conferences::Admin::ApplicationController
        include Concerns::ConferenceAdmin
        include Decidim::Paginable
        include Decidim::Conferences::Admin::ConferencesInvites::Filterable

        helper_method :conference

        alias conference current_participatory_space

        def index
          enforce_permission_to(:read_invites, :conference, conference: current_participatory_space)

          @conference_invites = filtered_collection
        end

        def new
          enforce_permission_to(:invite_attendee, :conference, conference: current_participatory_space)

          @form = form(ConferenceRegistrationInviteForm).instance
        end

        def create
          enforce_permission_to(:invite_attendee, :conference, conference: current_participatory_space)

          @form = form(ConferenceRegistrationInviteForm).from_params(params)

          InviteUserToJoinConference.call(@form, current_participatory_space, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("conference_invites.create.success", scope: "decidim.conferences.admin")
              redirect_to conference_conference_invites_path(current_participatory_space)
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("conference_invites.create.error", scope: "decidim.conferences.admin")
              render :new
            end
          end
        end

        private

        def collection
          current_conference.conference_invites
        end
      end
    end
  end
end
