# frozen_string_literal: true

module Decidim
  # A command with all the business logic for when a user stops following a resource.
  class DeleteFollow < Rectify::Command
    # Public: Initializes the command.
    #
    # form         - A form object with the params.
    # current_user - The current user.
    def initialize(form, current_user)
      @form = form
      @current_user = current_user
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid, together with the follow.
    # - :invalid if the form wasn't valid and we couldn't proceed.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) if form.invalid?

      delete_follow!

      broadcast(:ok)
    end

    private

    attr_reader :form, :current_user

    def delete_follow!
      form.follow.destroy!
    end
  end
end
