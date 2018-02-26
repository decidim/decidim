module Decidim
  module Proposals
    class ViewModel < Cell::ViewModel
      include ActionView::Helpers::TranslationHelper
      include ::Cell::Translation
      include Decidim::ResourceHelper
    end
  end
end
