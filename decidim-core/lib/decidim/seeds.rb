# frozen_string_literal: true

require "faker"

module Decidim
  # Base class to be inherited from the different modules' seeds classes
  class Seeds
    protected

    def seeds_root = File.join(__dir__, "..", "..", "db", "seeds")

    def hero_image = create_image!(seeds_file: "city.jpeg", filename: "hero_image.jpeg")

    def banner_image = create_image!(seeds_file: "city2.jpeg", filename: "banner_image.jpeg")

    def create_image!(seeds_file:, filename:)
      ActiveStorage::Blob.create_and_upload!(
        io: File.open(File.join(seeds_root, seeds_file)),
        filename:,
        content_type: "image/jpeg",
        metadata: nil
      )
    end
  end
end
