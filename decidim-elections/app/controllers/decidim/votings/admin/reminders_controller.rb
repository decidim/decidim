# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # This controller allows to send reminders.
      # It is targeted for customizations for reminder things that lives under
      # votings.
      class RemindersController < Decidim::Admin::RemindersController
        include VotingAdmin
      end
    end
  end
end
