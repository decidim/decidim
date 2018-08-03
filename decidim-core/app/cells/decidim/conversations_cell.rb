# frozen_string_literal: true

module Decidim
  class ConversationsCell < Decidim::ViewModel
    include Decidim::CellsPaginateHelper
    include Decidim::IconHelper
    include Decidim::Core::Engine.routes.url_helpers
    include ActionView::Helpers::DateHelper

    helper_method :conversations

    delegate :current_user, to: :controller

    def show
      render :show
    end

    private

    def conversations
      @conversations ||= Decidim::Messaging::UserConversations.for(current_user)
    end
  end
end
