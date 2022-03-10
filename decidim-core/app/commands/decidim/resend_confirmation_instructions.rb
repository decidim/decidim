# frozen_string_literal: true

module Decidim
  class ResendConfirmationInstructions < Decidim::Command
    def initialize(user)
      @user = user
      @unconfirmed_email = user.unconfirmed_email
    end

    def call
      current_user.send_confirmation_instructions

      broadcast(:ok, @unconfirmed_email)
    end
  end
end
