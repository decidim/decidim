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
      return broadcast(:invalid) unless handler.valid? && unique?

      create_authorization
      broadcast(:ok)
    end

    private

    attr_reader :handler

    def create_authorization
      authorization = Authorization.find_or_initialize_by(
        user: handler.user,
        name: handler.handler_name
      )

      authorization.attributes = {
        unique_id: handler.unique_id,
        metadata: handler.metadata
      }

      authorization.grant!
    end

    def unique?
      return true if handler.unique_id.nil?

      duplicates = Authorization.where(
        user: User.where.not(id: handler.user.id).where(organization: handler.user.organization.id),
        name: handler.handler_name,
        unique_id: handler.unique_id
      )

      return true unless duplicates.any?

      handler.errors.add(:base, I18n.t("decidim.authorization_handlers.errors.duplicate_authorization"))
      false
    end
  end
end
