# frozen_string_literal: true

module Decidim
  class ResendConfirmationInstructions < Decidim::Command
    def initialize(user)
      @user = user
      @unconfirmed_email = user.unconfirmed_email
    end

    def call
      return broadcast(:invalid) unless @unconfirmed_email

      ResendConfirmationInstructionsJob.perform_later(@user)

      broadcast(:ok)
    end
  end
end
