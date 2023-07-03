# frozen_string_literal: true

module Decidim
  class UserConversationCell < Decidim::ViewModel
    include Cell::ViewModel::Partial
    include Decidim::ApplicationHelper
    include Decidim::FormFactory
    include Decidim::Core::Engine.routes.url_helpers

    def user
      model
    end

    def show
      return render :show if conversation.id

      render :new
    end

    # renders a unique message, useful for ajax calls
    def message(msg)
      render view: :messages, locals: { sender: msg.sender, messages: [msg] }
    end

    def user_grouped_messages
      conversation.messages.includes(:sender).chunk(&:sender)
    end

    def conversation
      context[:conversation]
    end

    def sender_is_user?(sender)
      user.id == sender.id
    end

    def form_ob
      return Messaging::MessageForm.new if conversation.id

      Messaging::ConversationForm.new(recipient_id: interlocutors)
    end

    def interlocutors
      conversation.interlocutors(user)
    end

    def recipients
      return [] if conversation.id

      interlocutors
    end

    def reply_form(&)
      return form_for(form_ob, url: decidim.profile_conversations_path(nickname: user.nickname), method: :post, &) unless conversation.id

      form_for(form_ob, url: decidim.profile_conversation_path(nickname: user.nickname, id: conversation.id), method: :put, remote: true, &)
    end

    def back_path
      decidim.profile_conversations_path(nickname: user.nickname)
    end
  end
end
