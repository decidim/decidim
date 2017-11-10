# frozen_string_literal: true

module Decidim
  module Messaging
    module ChatHelper
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
