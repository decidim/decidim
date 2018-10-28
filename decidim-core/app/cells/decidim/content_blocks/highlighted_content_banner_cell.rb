# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class HighlightedContentBannerCell < Decidim::ViewModel
      include Decidim::SanitizeHelper

      def show
        return unless current_organization.highlighted_content_banner_enabled
        render
      end

      delegate :current_organization, to: :controller
    end
  end
end
