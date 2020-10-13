# frozen_string_literal: true

module Decidim
  module Conferences
    # This cell renders the media link card for an instance of a MediaLink
    class MediaLinkCell < Decidim::ViewModel
      include Decidim::LayoutHelper
      include Decidim::SanitizeHelper

      def show
        render
      end
    end
  end
end
