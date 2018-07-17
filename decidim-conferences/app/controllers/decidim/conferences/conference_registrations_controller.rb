# frozen_string_literal: true

module Decidim
  module Conferences
    # Exposes the registration resource so users can join and leave conferences.
    class ConferenceRegistrationsController < Decidim::Conferences::ApplicationController
      def create
        enforce_permission_to :join, :conference, conference: conference

        JoinConference.call(conference, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("conference_registrations.create.success", scope: "decidim.conferences")
            redirect_after_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("conference_registrations.create.invalid", scope: "decidim.conferences")
            redirect_after_path
          end
        end
      end

      def destroy
        enforce_permission_to :leave, :conference, conference: conference

        LeaveConference.call(conference, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("conference_registrations.destroy.success", scope: "decidim.conferences")
            redirect_after_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("conference_registrations.destroy.invalid", scope: "decidim.conferences")
            redirect_after_path
          end
        end
      end

      def decline_invitation
        enforce_permission_to :decline_invitation, :conference, conference: conference

        DeclineInvitation.call(conference, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("conference_registrations.decline_invitation.success", scope: "decidim.conferences")
            redirect_after_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("conference_registrations.decline_invitation.invalid", scope: "decidim.conferences")
            redirect_after_path
          end
        end
      end

      private

      def conference
        @conference ||= Conference.find_by(slug: params[:conference_slug])
      end

      def redirect_after_path
        referer = request.headers["Referer"]
        return redirect_to(conference_path(conference)) if referer =~ /invitation_token/
        redirect_back fallback_location: conference_path(conference)
      end
    end
  end
end
