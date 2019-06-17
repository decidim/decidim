# frozen_string_literal: true

module Decidim
  module Conferences
    # This cell renders the photos list
    class PhotosListCell < Decidim::ViewModel
      include Cell::ViewModel::Partial
      include Decidim::ApplicationHelper
      include Decidim::SanitizeHelper

      def show
        return unless model.any?

        render
      end
    end
  end
end
