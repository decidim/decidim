# frozen_string_literal: true

module Decidim
  class UserConversationsCell < Decidim::ViewModel
    include Cell::ViewModel::Partial
    include Decidim::LayoutHelper
    include CellsPaginateHelper
    include Decidim::Core::Engine.routes.url_helpers
    include Messaging::ConversationHelper
    include ActionView::Helpers::DateHelper

    def user
      model
    end

    def show
      render :show
    end

    def conversations
      context[:conversations] || []
    end

    def form_ob
      Messaging::MessageForm.new
    end

    def conversation_avatar(conversation)
      return user.avatar.default_multiuser_url unless conversation.interlocutors(user).count == 1

      conversation.interlocutors(user).first.avatar_url
    end

    def conversation_interlocutors(conversation)
      return username_list(conversation.interlocutors(user), shorten: true) unless conversation.interlocutors(user).count == 1

      "#{conversation.interlocutors(user).first.name} <span class=\"muted\">@#{conversation.interlocutors(user).first.nickname}</span>"
    end
  end
end
