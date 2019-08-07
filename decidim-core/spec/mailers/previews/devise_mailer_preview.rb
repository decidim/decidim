# frozen_string_literal: true

module Decidim
  class DeviseMailerPreview < ActionMailer::Preview
    def confirmation_instructions
      DecidimDeviseMailer.confirmation_instructions(User.first, "faketoken", {})
    end

    def reset_password_instructions
      DecidimDeviseMailer.reset_password_instructions(User.first, "faketoken", {})
    end
  end
end
