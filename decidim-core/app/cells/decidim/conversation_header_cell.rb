# frozen_string_literal: true

module Decidim
  class ConversationHeaderCell < Decidim::ViewModel
    include Decidim::IconHelper
    include Decidim::Core::Engine.routes.url_helpers

    def show
      render :show
    end

    def recipient
      @recipient ||= Decidim::UserPresenter.new(model)
    end
  end
end
