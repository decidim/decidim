# frozen_string_literal: true

require "faker"

module Decidim
  # Base class to be inherited from the different modules' seeds classes
  class Seeds
    protected

    def seeds_root = File.join(__dir__, "..", "..", "db", "seeds")

    def hero_image = create_image!(seeds_file: "city.jpeg", filename: "hero_image.jpeg")

    def banner_image = create_image!(seeds_file: "city2.jpeg", filename: "banner_image.jpeg")

    def create_attachment(attached_to:, filename:, attachment_collection: nil)
      content_type = {
        jpg: "image/jpeg",
        jpeg: "image/jpeg",
        pdf: "application/pdf"
      }[filename.split(".")[1].to_sym]

      Decidim::Attachment.create!(
        title: Decidim::Faker::Localized.sentence(word_count: 2),
        description: Decidim::Faker::Localized.sentence(word_count: 5),
        attachment_collection:,
        attached_to:,
        content_type:,
        file: create_image!(seeds_file: filename, filename:) # Keep after attached_to
      )
    end

    def create_attachment_collection(collection_for:)
      Decidim::AttachmentCollection.create!(
        name: Decidim::Faker::Localized.word,
        description: Decidim::Faker::Localized.sentence(word_count: 5),
        collection_for:
      )
    end

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
