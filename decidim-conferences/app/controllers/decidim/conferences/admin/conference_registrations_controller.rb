# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # Controller that allows to manage the conference users registrations.
      #
      class ConferenceRegistrationsController < Decidim::Conferences::Admin::ApplicationController
        include Concerns::ConferenceAdmin
        include Decidim::Paginable

        helper_method :conference

        alias conference current_participatory_space

        def index
          enforce_permission_to(:read_conference_registrations, :conference, conference: current_participatory_space)

          @conference_registrations = paginate(current_participatory_space.conference_registrations)
        end

        def export
          enforce_permission_to(:export_conference_registrations, :conference, conference: current_participatory_space)

          ExportConferenceRegistrations.call(current_participatory_space, params[:format], current_user) do
            on(:ok) do |export_data|
              send_data export_data.read, type: "text/#{export_data.extension}", filename: export_data.filename("conference_registrations")
            end
          end
        end

        def confirm
          enforce_permission_to(:confirm, :conference_registration, conference_registration:)

          ConfirmConferenceRegistration.call(conference_registration, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("conference_registration.confirm.success", scope: "decidim.admin")
            end

            on(:invalid) do
              flash[:alert] = I18n.t("conference_registration.confirm.error", scope: "decidim.admin")
            end

            redirect_back(fallback_location: conference_conference_registrations_path)
          end
        end

        private

        def conference_registration
          return if params[:id].blank?

          @conference_registration ||= current_participatory_space.conference_registrations.find_by(id: params[:id])
        end
      end
    end
  end
end
