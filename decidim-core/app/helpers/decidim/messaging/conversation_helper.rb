# frozen_string_literal: true

module Decidim
  module Messaging
    module ConversationHelper
      #
      # Builds a link to the conversation between the current user and another
      # user.
      #
      # * If there's no current user, it links to the login form.
      #
      # * If there's no prior existing conversation between the users, it links
      #   to the new conversation form.
      #
      # * Otherwise, it links to the existing conversation.
      #
      # @param user [Decidim::User] The user to link to a conversation with
      #
      # @return [String] The resulting route
      #
      def link_to_current_or_new_conversation_with(user)
        return decidim.new_user_session_path unless user_signed_in?

        conversation = conversation_between(current_user, user)

        if conversation
          decidim.conversation_path(conversation)
        else
          decidim.new_conversation_path(recipient_id: user.id)
        end
      end

      def conversation_between(one_user, another_user)
        UserConversations.for(one_user).find do |conversation|
          conversation.participants.to_set == [one_user, another_user].to_set
        end
      end
    end
  end
end
