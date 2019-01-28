# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class FooterSubHeroCell < Decidim::ViewModel
      include Decidim::IconHelper
      include Decidim::Core::Engine.routes.url_helpers
      
      delegate :current_organization, to: :controller
      delegate :current_user, to: :controller
    end
  end
end
