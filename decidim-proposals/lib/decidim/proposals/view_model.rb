# frozen_string_literal: true

module Decidim
  module Proposals
    class ViewModel < Decidim::ViewModel
      include Decidim::Proposals::ApplicationHelper
      include Decidim::Proposals::Engine.routes.url_helpers
      include Decidim::LayoutHelper
      include Decidim::ApplicationHelper
      include Decidim::ActionAuthorization
      include Decidim::ActionAuthorizationHelper
      include Decidim::TranslationsHelper
      include Decidim::ResourceReferenceHelper
      include Decidim::TranslatableAttributes
    end
  end
end
