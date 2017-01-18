# frozen_string_literal: true
module Decidim
  # A command to authorize a user with an authorization handler.
  class AuthorizeUser < Rectify::Command
    # Public: Initializes the command.
    #
    # handler - An AuthorizationHandler object.
    def initialize(handler)
      @handler = handler
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the handler wasn't valid and we couldn't proceed.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless handler.valid?

      create_authorization
      broadcast(:ok)
    end

    private

    attr_reader :handler

    def create_authorization
      Authorization.create!(
        user: handler.user,
        unique_id: handler.unique_id,
        name: handler.handler_name,
        metadata: handler.metadata
      )
    end
  end
end
