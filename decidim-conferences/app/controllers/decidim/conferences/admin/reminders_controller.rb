# frozen_string_literal: true

module Decidim
  module Conferences
    module Admin
      # This controller allows to send reminders.
      # It is targeted for customizations for reminder things that lives under
      # a conference.
      class RemindersController < Decidim::Admin::RemindersController
        include Concerns::ConferenceAdmin
      end
    end
  end
end
