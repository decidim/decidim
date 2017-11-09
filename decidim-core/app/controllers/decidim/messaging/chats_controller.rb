# frozen_string_literal: true

module Decidim
  module Messaging
    # The controller to handle the user's chats.
    class ChatsController < Decidim::ApplicationController
      helper Decidim::DatetimeHelper

      before_action :authenticate_user!

      helper_method :username_list, :chat

      def index
        authorize! :index, Chat

        @chats = UserChats.for(current_user)
      end

      def show
        authorize! :show, chat
      end

      private

      def chat
        @chat ||= Chat.find(params[:id])
      end

      def username_list(users)
        users.pluck(:name).join(", ")
      end
    end
  end
end
