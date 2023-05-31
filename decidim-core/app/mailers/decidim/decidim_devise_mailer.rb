# frozen_string_literal: true

module Decidim
  # A custom mailer for Devise so we can tweak the invitation instructions for
  # each role and use a localised version.
  class DecidimDeviseMailer < ::Devise::Mailer
    include LocalisedMailer

    layout "decidim/mailer"

    # Sends an email with the invitation instructions to a new user.
    #
    # user  - The User that has been invited.
    # token - The String to be sent as a token to verify the invitation.
    # opts  - A Hash with options to send the email (optional).
    def invitation_instructions(user, token, opts = {})
      with_user(user) do
        @token = token
        @organization = user.organization
        @opts = opts

        opts[:subject] = I18n.t("devise.mailer.#{opts[:invitation_instructions]}.subject", organization: user.organization.name) if opts[:invitation_instructions]
      end

      devise_mail(user, opts[:invitation_instructions] || :invitation_instructions, opts)
    end

    private

    # Overwrite devise_mail so we can inject the organization from the user.
    def devise_mail(user, action, opts = {}, &)
      with_user(user) do
        @organization = user.organization
        super
      end
    end
  end
end
