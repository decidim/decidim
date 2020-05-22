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

    def conversation_avatar
      if interlocutors.count == 1
        interlocutors.first.avatar_url
      else
        current_user.avatar.default_multiuser_url
      end
    end

    def form_ob
      return Messaging::MessageForm.new if conversation.id

      Messaging::ConversationForm.new(recipient_id: interlocutors)
    end

    def interlocutors
      conversation.interlocutors(user)
    end

    def interlocutors_names
      return username_list(interlocutors) unless interlocutors.count == 1

      "<strong>#{interlocutors.first.name}</strong><br><span class=\"muted\">@#{interlocutors.first.nickname}</span>"
    end

    def recipients
      return [] if conversation.id

      interlocutors
    end

    def reply_form(&block)
      return form_for(form_ob, url: decidim.profile_conversations_path(nickname: user.nickname), method: :post, &block) unless conversation.id

      form_for(form_ob, url: decidim.profile_conversation_path(nickname: user.nickname, id: conversation.id), method: :put, remote: true, &block)
    end
  end
end
