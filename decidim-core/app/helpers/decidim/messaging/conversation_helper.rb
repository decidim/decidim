# frozen_string_literal: true

module Decidim
  module Messaging
    module ConversationHelper
      #
      # Links to the conversation between the current user and another user
      #
      def link_to_current_or_new_conversation_with(user, title = t("decidim.contact"))
        link_to current_or_new_conversation_path_with(user), title: title do
          icon "envelope-closed", aria_label: title, class: "icon--small"
        end
      end

      #
      # Finds the right path to the conversation the current user and another
      # user.
      #
      # * If there's no current user, it returns to the login form path.
      #
      # * If there's no prior existing conversation between the users, it
      #   returns the new conversation form path.
      #
      # * Otherwise, it returns the path to the existing conversation.
      #
      # @param user [Decidim::User] The user to link to a conversation with
      #
      # @return [String] The resulting route
      #
      def current_or_new_conversation_path_with(user)
        decidim_routes = Decidim::Core::Engine.routes.url_helpers
        return decidim_routes.new_user_session_path unless user_signed_in?

        conversation = conversation_between(current_user, user)

        if conversation
          decidim_routes.conversation_path(conversation)
        else
          decidim_routes.new_conversation_path(recipient_id: user.id)
        end
      end

      #
      # Finds the conversation between the given participants
      #
      # @param participants [Array<Decidim::User>] The participants to find a
      #   conversation between.
      #
      # @return [Decidim::Messaging::Conversation]
      def conversation_between(*participants)
        return if participants.to_set.length <= 1

        UserConversations.for(participants.first).find do |conversation|
          conversation.participants.to_set == participants.to_set
        end
      end
    end
  end
end
