# frozen_string_literal: true

module Decidim
  module Messaging
    # The controller to handle the user's chats.
    class ChatsController < Decidim::ApplicationController
      before_action :authenticate_user!

      def index
        authorize! :index, :chats
      end
    end
  end
end
