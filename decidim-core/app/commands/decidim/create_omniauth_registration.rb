# frozen_string_literal: true

module Decidim
  # A command with all the business logic to create a user from omniauth
  class CreateOmniauthRegistration < Decidim::Command
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
        if existing_identity
          user = existing_identity.user
          verify_user_confirmed(user)

          return broadcast(:ok, user)
        end
        return broadcast(:invalid) if form.invalid?

        transaction do
          create_or_find_user
          @identity = create_identity
        end
        trigger_omniauth_registration

        broadcast(:ok, @user)
      rescue ActiveRecord::RecordInvalid => e
        broadcast(:error, e.record)
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

      if @user.persisted?
        # If user has left the account unconfirmed and later on decides to sign
        # in with omniauth with an already verified account, the account needs
        # to be marked confirmed.
        @user.skip_confirmation! if !@user.confirmed? && @user.email == verified_email
      else
        @user.email = (verified_email || form.email)
        @user.name = form.name
        @user.nickname = form.normalized_nickname
        @user.newsletter_notifications_at = nil
        @user.password = generated_password
        @user.password_confirmation = generated_password
        if form.avatar_url.present?
          url = URI.parse(form.avatar_url)
          filename = File.basename(url.path)
          file = url.open
          @user.avatar.attach(io: file, filename: filename)
        end
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
      @existing_identity ||= Identity.find_by(
        user: organization.users,
        provider: form.provider,
        uid: form.uid
      )
    end

    def verify_user_confirmed(user)
      return true if user.confirmed?
      return false if user.email != verified_email

      user.skip_confirmation!
      user.save!
    end

    def verify_oauth_signature!
      raise InvalidOauthSignature, "Invalid oauth signature: #{form.oauth_signature}" unless signature_valid?
    end

    def signature_valid?
      signature = OmniauthRegistrationForm.create_signature(form.provider, form.uid)
      form.oauth_signature == signature
    end

    def trigger_omniauth_registration
      ActiveSupport::Notifications.publish(
        "decidim.user.omniauth_registration",
        user_id: @user.id,
        identity_id: @identity.id,
        provider: form.provider,
        uid: form.uid,
        email: form.email,
        name: form.name,
        nickname: form.normalized_nickname,
        avatar_url: form.avatar_url,
        raw_data: form.raw_data
      )
    end
  end

  class InvalidOauthSignature < StandardError
  end
end
