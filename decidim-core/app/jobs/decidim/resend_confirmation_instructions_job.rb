# frozen_string_literal: true

module Decidim
  class ResendConfirmationInstructionsJob < ApplicationJob
    queue_as :default

    def perform(user)
      user.send_reconfirmation_instructions
    end
  end
end
