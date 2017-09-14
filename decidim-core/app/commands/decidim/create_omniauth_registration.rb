# frozen_string_literal: true

module Decidim
  # A command with all the business logic to create a user from omniauth
  class CreateOmniauthRegistration < Rectify::Command
    # Public: Initializes the command.
    #
    # form - A form object with the params.
    def initialize(form, verified_email = nil)
      @form = form
      @verified_email = verified_email
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the form wasn't valid and we couldn't proceed.
    #
    # Returns nothing.
    def call
      verify_oauth_signature!

      begin
        return broadcast(:ok, existing_identity.user) if existing_identity
        return broadcast(:invalid) if form.invalid?

        transaction do
          create_or_find_user
          create_identity
        end

        broadcast(:ok, @user)
      rescue ActiveRecord::RecordInvalid => error
        broadcast(:error, error.record)
      end
    end

    private

    attr_reader :form, :verified_email

    def create_or_find_user
      generated_password = SecureRandom.hex

      @user = User.find_or_initialize_by(
        email: verified_email,
        organization: organization
      )

      unless @user.persisted?
        @user.email = (verified_email || form.email)
        @user.name = form.name
        @user.password = generated_password
        @user.password_confirmation = generated_password
        @user.skip_confirmation! if verified_email
      end

      @user.tos_agreement = "1"
      @user.save!
    end

    def create_identity
      @user.identities.create!(
        provider: form.provider,
        uid: form.uid,
        organization: organization
      )
    end

    def organization
      @form.current_organization
    end

    def existing_identity
      @existing_identity ||= Identity.where(
        user: organization.users,
        provider: form.provider,
        uid: form.uid
      ).first
    end

    def verify_oauth_signature!
      raise InvalidOauthSignature, "Invalid oauth signature: #{form.oauth_signature}" unless signature_valid?
    end

    def signature_valid?
      signature = OmniauthRegistrationForm.create_signature(form.provider, form.uid)
      form.oauth_signature == signature
    end
  end

  class InvalidOauthSignature < StandardError
  end
end
