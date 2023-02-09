# frozen_string_literal: true

module Decidim
  # This cell is used to render the images panel of a resource inside
  # a tab of a show view
  #
  # The `model` must be a resource to get the images from and is expected to
  # respond to photos method
  #
  # Example:
  #
  #   cell(
  #     "decidim/images_panel",
  #     meeting
  #   )
  class ImagesPanelCell < Decidim::ViewModel
    alias resource model

    def show
      return if photos.blank?

      render
    end

    def photos
      @photos ||= resource.try(:photos)
    end
  end
end
