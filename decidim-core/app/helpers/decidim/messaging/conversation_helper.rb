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

        conversation_between = UserConversations.for(current_user).find do |conversation|
          conversation.participants.to_set == [current_user, user].to_set
        end

        if conversation_between
          decidim.conversation_path(conversation_between)
        else
          decidim.new_conversation_path(recipient_id: user.id)
        end
      end
    end
  end
end
