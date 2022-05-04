# frozen_string_literal: true

module Decidim
  module Admin
    # This class contains helpers needed to obtain information about
    # image dimensions from the processors defined in the specific image's Uploader class
    module UploaderImageDimensionsHelper
      # Find the dimensions info of a model's image field and get the first value for dimensions ([w, h])
      #
      # model - The model to which the image belongs (An instance of `ActiveRecord`)
      # image_name - The attribute name for the image (either a `symbol` or a `string`)
      #
      # Returns an integer array with [width, height]
      def image_dimensions(model, image_name)
        uploader = model.attached_uploader(image_name) || model.send(image_name)
        versions = uploader.dimensions_info
        [:small, :medium, :default].map { |v| versions.dig(v, :dimensions) }.compact.first
      end

      # Find the first value for the processed image width
      def image_width(model, image_name)
        image_dimensions(model, image_name)[0]
      end

      # Find the first value for the processed image height
      def image_height(model, image_name)
        image_dimensions(model, image_name)[1]
      end
    end
  end
end
