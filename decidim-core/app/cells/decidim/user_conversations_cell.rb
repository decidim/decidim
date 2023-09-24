# frozen_string_literal: true

module Decidim
  class UserConversationsCell < Decidim::ViewModel
    include Cell::ViewModel::Partial
    include CellsPaginateHelper
    include Decidim::Core::Engine.routes.url_helpers
    include ActionView::Helpers::DateHelper
    include Decidim::ApplicationHelper

    delegate :nickname, to: :user

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
  end
end
