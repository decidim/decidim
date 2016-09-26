# frozen_string_literal: true
module Decidim
  # A custom mailer for Devise so we can tweak the invitation instructions for
  # each role.
  class DecidimDeviseMailer < Devise::Mailer
    def invitation_instructions(record, token, opts = {})
      @token = token
      devise_mail(record, record.invitation_instructions || :invitation_instructions, opts)
    end
  end
end
