# frozen_string_literal: true

module Decidim
  module Messaging
    # The controller to handle the user's chats.
    class ChatsController < Decidim::ApplicationController
      helper Decidim::DatetimeHelper

      before_action :authenticate_user!

      helper_method :username_list

      def index
        authorize! :index, Chat

        @chats = UserChats.for(current_user)
      end

      private

      def username_list(users)
        users.pluck(:name).join(", ")
      end
    end
  end
end
