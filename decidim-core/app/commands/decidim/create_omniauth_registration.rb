# frozen_string_literal: true
module Decidim
  class CreateOmniauthRegistration < Rectify::Command
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

      begin
        create_user
        create_identity

        broadcast(:ok, @user)
      rescue ActiveRecord::RecordNotUnique
        broadcast(:error)
      end
    end

    private

    attr_reader :form

    def create_user
      generated_password = SecureRandom.hex

      @user = User.create!(email: form.email,
                           name: form.name,
                           password: generated_password,
                           password_confirmation: generated_password,
                           organization: form.current_organization,
                           tos_agreement: tos_agreement)

      @user.skip_confirmation! if form.email_verified?
    end

    def create_identity
      @user.identities.create!(provider: form.provider,
                               uid: form.uid)
    end

    def tos_agreement
      form.provider.to_s == "facebook" || form.tos_agreement
    end
  end
end
