# frozen_string_literal: true

module Decidim
  class ViewModel < Cell::ViewModel
    include ActionView::Helpers::TranslationHelper
    include ::Cell::Translation
    include Decidim::ResourceHelper
    include Decidim::TranslationsHelper
    include Decidim::ResourceReferenceHelper
    include Decidim::TranslatableAttributes
    include Decidim::ScopesHelper
  end
end
