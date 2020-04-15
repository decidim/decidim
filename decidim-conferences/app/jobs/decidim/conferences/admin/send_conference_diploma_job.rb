# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      class SendConferenceDiplomaJob < ApplicationJob
        queue_as :conference_diplomas

        def perform(conference)
          confirmed_registrations = conference.conference_registrations.confirmed
          return unless confirmed_registrations.any?

          confirmed_registrations.each do |registration_confirmed|
            SendConferenceDiplomaMailer.diploma(conference, registration_confirmed.user).deliver_later
          end
        end
      end
    end
  end
end
