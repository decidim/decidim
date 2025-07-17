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
    # - :invalid if the form was not valid and we could not proceed.
    #
    # Returns nothing.
    def call
      verify_oauth_signature!

      begin
        if (@identity = existing_identity)
          @user = existing_identity.user
          verify_user_confirmed(@user)

          trigger_omniauth_event("decidim.user.omniauth_login")
          return broadcast(:ok, @user)
        end
        return broadcast(:invalid) if form.invalid?

        transaction do
          create_or_find_user
          @identity = create_identity
        end
        trigger_omniauth_event

        broadcast(:ok, @user)
      rescue NeedTosAcceptance
        broadcast(:add_tos_errors, @user)
      rescue ActiveRecord::RecordInvalid => e
        broadcast(:error, e.record)
      end
    end

    private

    attr_reader :form, :verified_email

    REGEXP_SANITIZER = /[<>?%&\^*#@()\[\]=+:;"{}\\|]/

    def create_or_find_user
      @user = User.find_or_initialize_by(
        email: verified_email,
        organization:
      )

      if @user.persisted?
        # If user has left the account unconfirmed and later on decides to sign
        # in with omniauth with an already verified account, the account needs
        # to be marked confirmed.
        if !@user.confirmed? && @user.email == verified_email
          @user.skip_confirmation!
          @user.after_confirmation
        end
        @user.tos_agreement = "1"
        @user.save!
      else
        @user.email = (verified_email || form.email)
        @user.name = form.name.gsub(REGEXP_SANITIZER, "")
        @user.nickname = form.normalized_nickname
        @user.newsletter_notifications_at = nil
        @user.password = SecureRandom.hex
        attach_avatar(form.avatar_url) if form.avatar_url.present?
        @user.tos_agreement = form.tos_agreement
        @user.accepted_tos_version = Time.current
        raise NeedTosAcceptance if @user.tos_agreement.blank?

        @user.skip_confirmation! if verified_email
        @user.save!
        @user.after_confirmation if verified_email
      end
    end

    def attach_avatar(avatar_url)
      url = URI.parse(avatar_url)
      filename = File.basename(url.path)
      file = url.open
      @user.avatar.attach(io: file, filename:)
    rescue OpenURI::HTTPError, Errno::ECONNREFUSED
      # Do not attach the avatar, as it fails to fetch it.
    end

    def create_identity
      @user.identities.create!(
        provider: form.provider,
        uid: form.uid,
        organization:
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

    def trigger_omniauth_event(event_name = "decidim.user.omniauth_registration")
      ActiveSupport::Notifications.publish(
        event_name,
        user_id: @user.id,
        identity_id: @identity.id,
        provider: form.provider,
        uid: form.uid,
        email: form.email,
        name: form.name.gsub(REGEXP_SANITIZER, ""),
        nickname: form.normalized_nickname,
        avatar_url: form.avatar_url,
        raw_data: form.raw_data,
        tos_agreement: form.tos_agreement,
        newsletter_notifications_at: form.newsletter_at,
        accepted_tos_version: form.current_organization.tos_version
      )
    end
  end

  class NeedTosAcceptance < StandardError
  end

  class InvalidOauthSignature < StandardError
  end
end
