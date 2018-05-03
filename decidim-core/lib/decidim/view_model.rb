# frozen_string_literal: true

module Decidim
  class ViewModel < Cell::ViewModel
    include ActionView::Helpers::TranslationHelper
    include ::Cell::Translation
    include Decidim::ResourceHelper
    include Decidim::ScopesHelper
    include ActionController::Helpers
    include Decidim::ActionAuthorization
    include Decidim::ActionAuthorizationHelper
  end
end
