module Decidim
  class ViewModel < Cell::ViewModel
    include ActionView::Helpers::TranslationHelper
    include ::Cell::Translation
    include Decidim::ResourceHelper
  end
end
