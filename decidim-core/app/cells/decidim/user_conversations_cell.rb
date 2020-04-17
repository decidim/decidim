# frozen_string_literal: true

module Decidim
  class UserConversationsCell < Decidim::ViewModel
    include Cell::ViewModel::Partial
    include Decidim::LayoutHelper
    include CellsPaginateHelper
    include Decidim::Core::Engine.routes.url_helpers
    include Messaging::ConversationHelper

    def user
      model
    end

    def show
      render :show
    end

    def conversations
      context[:conversations] || []
    end
  end
end
