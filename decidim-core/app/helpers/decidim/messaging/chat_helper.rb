# frozen_string_literal: true

module Decidim
  module Messaging
    module ChatHelper
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
      def link_to_current_or_new_chat_with(user)
        return decidim.new_user_session_path unless user_signed_in?

        chat_between = UserChats.for(current_user).find do |chat|
          chat.participants.to_set == [current_user, user].to_set
        end

        if chat_between
          decidim.chat_path(chat_between)
        else
          decidim.new_chat_path(recipient_id: user.id)
        end
      end
    end
  end
end
