# frozen_string_literal: true

module Decidim
  # A command with all the business logic to create an ephemeral user.
  class CreateEphemeralUser < Decidim::Command
    # Public: Initializes the command.
    #
    # form - A form object with the params.
    def initialize(form)
      @form = form
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the form was not valid and we could not proceed.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) if form.invalid?

      create_user!
      confirm_user

      broadcast(:ok, @user)
    rescue ActiveRecord::RecordInvalid
      broadcast(:invalid)
    end

    private

    attr_reader :form

    def create_user!
      # The user is saved with tos_agreement to true but in the verification
      # phase the tos_agreement will be mandatory for ephemeral users
      @user = User.create!(
        name: form.name,
        nickname: form.nickname,
        organization: form.organization,
        locale: form.locale,
        tos_agreement: true,
        managed: true,
        extended_data: { ephemeral: true, verified: form.verified }
      )
    end

    def confirm_user
      @user.confirm
    end
  end
end
