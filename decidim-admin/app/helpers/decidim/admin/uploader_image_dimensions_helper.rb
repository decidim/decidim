# frozen_string_literal: true

module Decidim
  module Admin
    # This class contains helpers needed in order for $$$$$$$$$$$$$$$TODO to
    # $$$$$$$$$$$$$$$TODO.
    module UploaderImageDimensionsHelper
      # TODO: doc
      def image_dimensions(model, image_name)
        versions = model.send(image_name).dimensions_info
        [:small, :medium, :default].map { |v| versions.dig(v, :dimensions) }.compact.first
      end

      # TODO: doc
      def image_width(model, image_name)
        image_dimensions(model, image_name)[0]
      end

      # TODO: doc
      def image_height(model, image_name)
        image_dimensions(model, image_name)[1]
      end
    end
  end
end
