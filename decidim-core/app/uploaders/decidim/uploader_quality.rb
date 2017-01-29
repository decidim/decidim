module Decidim
  # Set of methods meant to be injected into an uploader to manipulate
  # an attachment's quality.
  module UploaderQuality
    # Sets the quality of the image to a given percentage.
    #
    # percentage - An integer with the actual percentage.
    def quality(percentage)
      manipulate! do |img|
        img.quality(percentage.to_s)
        img = yield(img) if block_given?
        img
      end
    end
  end
end
