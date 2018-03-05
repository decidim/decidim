module Decidim
  module Proposals
    class ViewModel < Decidim::ViewModel
      include Decidim::Proposals::ApplicationHelper
      include Decidim::Proposals::Engine.routes.url_helpers
    end
  end
end
