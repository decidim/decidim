# frozen_string_literal: true

require "faker"
require "decidim/faker/internet"
require "decidim/faker/localized"

module Decidim
  # Base class to be inherited from the different modules' seeds classes
  class Seeds
    protected

    def organization
      @organization ||= Decidim::Organization.first
    end

    def seeds_root = File.join(__dir__, "..", "..", "db", "seeds")

    def hero_image = create_blob!(seeds_file: "city.jpeg", filename: "hero_image.jpeg", content_type: "image/jpeg")

    def banner_image = create_blob!(seeds_file: "city2.jpeg", filename: "banner_image.jpeg", content_type: "image/jpeg")

    def create_attachments!(attached_to:)
      attachment_collection = create_attachment_collection(collection_for: attached_to)
      create_attachment(attached_to:, filename: "Exampledocument.pdf", attachment_collection:)
      create_attachment(attached_to:, filename: "city.jpeg")
      create_attachment(attached_to:, filename: "Exampledocument.pdf")
    end

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
        file: create_blob!(seeds_file: filename, filename:, content_type:) # Keep after attached_to
      )
    end

    def create_attachment_collection(collection_for:)
      Decidim::AttachmentCollection.create!(
        name: Decidim::Faker::Localized.word,
        description: Decidim::Faker::Localized.sentence(word_count: 5),
        collection_for:
      )
    end

    def create_blob!(seeds_file:, filename:, content_type:)
      ActiveStorage::Blob.create_and_upload!(
        io: File.open(File.join(seeds_root, seeds_file)),
        filename:,
        content_type:,
        metadata: nil
      )
    end

    def create_category!(participatory_space:)
      Decidim::Category.create!(
        name: Decidim::Faker::Localized.sentence(word_count: 5),
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(sentence_count: 3)
        end,
        participatory_space:
      )
    end

    def seed_components_manifests!(participatory_space:)
      Decidim.component_manifests.each do |manifest|
        manifest.seed!(participatory_space.reload)
      end
    end
  end
end
