# frozen_string_literal: true

module Decidim
  class UserConversationCell < Decidim::ViewModel
    include Cell::ViewModel::Partial
    include Decidim::LayoutHelper
    include Decidim::ApplicationHelper
    include Decidim::FormFactory
    include Decidim::Core::Engine.routes.url_helpers
    include Messaging::ConversationHelper

    def user
      model
    end

    def show
      render :show
    end

    def message(message)
      render locals: { message: message }
    end

    def conversation
      context[:conversation]
    end

    def participants
      conversation.interlocutors(current_user)
    end

    def form_ob
      Messaging::MessageForm.new
    end
  end
end
