# frozen_string_literal: true

module Decidim
  # This cell renders the photos list
  class PhotosListCell < Decidim::ViewModel
    include Cell::ViewModel::Partial

    def show
      return unless model.any?

      render
    end
  end
end
