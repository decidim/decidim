# frozen_string_literal: true

module Decidim
  class ConversationCell < Decidim::ViewModel
    include Decidim::Core::Engine.routes.url_helpers
    include ActionView::Helpers::DateHelper

    delegate :current_user, to: :controller

    def show
      @form = Decidim::Messaging::MessageForm.new
      render :show
    end

    def recipient
      @recipient ||= conversation.interlocutors(current_user).first
    end

    def conversation
      @conversation ||= context[:conversation]
    end
  end
end
