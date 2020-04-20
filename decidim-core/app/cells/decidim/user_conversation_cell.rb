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
      return render :show if conversation.id

      render :new
    end

    def message(message)
      render locals: { message: message }
    end

    def conversation
      context[:conversation]
    end

    def interlocutors
      conversation.interlocutors(user)
    end

    def form_ob
      return Messaging::MessageForm.new if conversation.id

      Messaging::ConversationForm.new(recipient_id: interlocutors)
    end

    def recipients
      return [] if conversation.id

      conversation.interlocutors(user)
    end

    def conversation_form_path
      return decidim.profile_conversations_path(nickname: user.nickname) unless conversation.id

      decidim.profile_conversation_path(nickname: user.nickname, id: conversation.id)
    end
  end
end
