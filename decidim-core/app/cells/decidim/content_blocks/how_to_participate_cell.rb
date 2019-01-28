# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class HowToParticipateCell < Decidim::ViewModel
      include Decidim::IconHelper
      include Decidim::Core::Engine.routes.url_helpers
    end
  end
end
