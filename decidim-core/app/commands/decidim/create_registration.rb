# frozen_string_literal: true
module Decidim
  # A command with all the business logic to create a user
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

      create_user
      broadcast(:ok, @user)
    end

    private

    attr_reader :form

    def create_user
      @user = User.create!(email: form.email,
                           name: form.name,
                           password: form.password,
                           password_confirmation: form.password_confirmation,
                           organization: form.current_organization,
                           tos_agreement: form.tos_agreement)
    end
  end
end
