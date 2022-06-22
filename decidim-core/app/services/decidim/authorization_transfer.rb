# frozen_string_literal: true

module Decidim
  # This is a helper class in order to publish authorization transfer events
  # so that components can react to these and perform whatever they are
  # required to.
  class AuthorizationTransfer
    EVENT_NAME = "decidim.authorization.transfer"

    # Publishes the event to ActiveSupport::Notifications.
    #
    # authorization - The Decidim::Authorization that is being transferred to
    #   another user.
    # handler - The Decidim::AuthorizationHandler that holds the user that the
    #   authorization should be transferred to.
    def self.publish(authorization, handler)
      ActiveSupport::Notifications.publish(
        EVENT_NAME,
        authorization_id: authorization.id,
        user_id: handler.user.id
      )
    end

    # Creates a subscription to events for authorization transfers.
    #
    # block - The block to be executed when an authorization is being
    #   transferred.
    def self.subscribe(&block)
      return unless block_given?

      ActiveSupport::Notifications.subscribe(EVENT_NAME) do |*args|
        data = args.extract_options!
        authorization = Decidim::Authorization.find_by(id: data[:authorization_id])
        target_user = Decidim::User.find_by(id: data[:user_id])

        block.call(authorization, target_user) if authorization && authorization.user && target_user
      end
    end
  end
end
