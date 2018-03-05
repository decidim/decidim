module Decidim
  class ViewModel < Cell::ViewModel
    include ActionView::Helpers::TranslationHelper
    include ::Cell::Translation
    include Decidim::ResourceHelper
    include Decidim::LayoutHelper
    include Decidim::ApplicationHelper
    include Decidim::ActionAuthorizationHelper
    include Decidim::TranslationsHelper
    include Decidim::ResourceReferenceHelper

    include Partial
  end
end
