# frozen_string_literal: true

module Decidim
  # A command with all the business logic to create a user through the sign up form.
  class CreateRegistration < Rectify::Command
    # Public: Initializes the command.
    #
    # form - A form object with the params.
    def initialize(form)
      @form = form
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the form wasn't valid and we couldn't proceed.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) if form.invalid?

      if pending_invitation_exist?
        update_user
        send_confirmations_instructions_email
      else
        create_user
      end
      broadcast(:ok, @user)
    rescue ActiveRecord::RecordInvalid
      broadcast(:invalid)
    end

    private

    attr_reader :form

    def pending_invitation_exist?
      @user = User.invitation_not_accepted.find_by(email: form.email)
    end

    def update_user
      @user.update!(
        name: form.name,
        nickname: form.nickname,
        password: form.password,
        password_confirmation: form.password_confirmation,
        tos_agreement: form.tos_agreement,
        newsletter_notifications_at: form.newsletter_at,
        email_on_notification: true,
        accepted_tos_version: form.current_organization.tos_version
      )
    end

    def send_confirmations_instructions_email
      @user.send_confirmation_instructions
    end

    def create_user
      @user = User.create!(
        email: form.email,
        name: form.name,
        nickname: form.nickname,
        password: form.password,
        password_confirmation: form.password_confirmation,
        organization: form.current_organization,
        tos_agreement: form.tos_agreement,
        newsletter_notifications_at: form.newsletter_at,
        email_on_notification: true,
        accepted_tos_version: form.current_organization.tos_version
      )
    end
  end
end
