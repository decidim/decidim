# frozen_string_literal: true

module Decidim
  class ViewModel < Cell::ViewModel
    include ActionView::Helpers::TranslationHelper
    include ::Cell::Translation
    include Decidim::ResourceHelper
    include Decidim::ScopesHelper
    include ActionController::Helpers
    include Decidim::ActionAuthorizationHelper
    include Decidim::ReplaceButtonsHelper

    def current_user
      context[:current_user]
    end
  end
end
