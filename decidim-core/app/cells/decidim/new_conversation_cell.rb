# frozen_string_literal: true

module Decidim
  class NewConversationCell < Decidim::ViewModel
    include Decidim::IconHelper
    include Decidim::Core::Engine.routes.url_helpers
    include ActionView::Helpers::DateHelper

    delegate :current_organization, to: :controller

    def show
      render :show
    end

    def form
      context[:form]
    end
  end
end
