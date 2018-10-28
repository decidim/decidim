# frozen_string_literal: true

require_dependency "decidim/admin/application_controller"

module Decidim
  module Conferences
    module Admin
      # Controller that allows to manage the conference users registrations.
      #
      class ConferenceRegistrationsController < Decidim::Conferences::Admin::ApplicationController
        include Concerns::ConferenceAdmin

        helper_method :conference

        def index
          enforce_permission_to :read_conference_registrations, :conference, conference: conference

          @conference_registrations = Decidim::Conferences::ConferenceRegistration.where(conference: conference).page(params[:page]).per(15)
        end

        def export
          enforce_permission_to :export_conference_registrations, :conference, conference: conference

          ExportConferenceRegistrations.call(conference, params[:format], current_user) do
            on(:ok) do |export_data|
              send_data export_data.read, type: "text/#{export_data.extension}", filename: export_data.filename("conference_registrations")
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
