# frozen_string_literal: true

module Decidim
  class UserConversationCell < Decidim::ViewModel
    include Cell::ViewModel::Partial
    include Decidim::LayoutHelper
    include Decidim::Core::Engine.routes.url_helpers

    def user
      model
    end

    def show
      render :show
    end

    def conversation
      context[:conversation]
    end
  end
end
