# frozen_string_literal: true

require "faker"
require "decidim/faker/internet"
require "decidim/faker/localized"

module Decidim
  # Base class to be inherited from the different modules' seeds classes
  class Seeds
    protected

    def fast_seeds?
      Decidim::Env.new("FAST_SEEDS").present?
    end

    def number_of_records
      fast_seeds? ? 1 : rand(3..5)
    end

    def organization
      @organization ||= Decidim::Organization.first
    end

    def admin_user
      @admin_user ||= Decidim::User.find_by(organization:, email: "admin@example.org")
    end

    def find_or_initialize_user_by(email:)
      user = Decidim::User.find_or_initialize_by(email:)
      user.update!(
        name: ::Faker::Name.name,
        nickname: "#{::Faker::Twitter.unique.screen_name}-#{rand(10_000)}"[0...20],
        password: "decidim123456789",
        organization:,
        confirmed_at: Time.current,
        locale: I18n.default_locale,
        personal_url: ::Faker::Internet.url,
        about: ::Faker::Lorem.paragraph(sentence_count: 2),
        avatar: random_avatar,
        accepted_tos_version: organization.tos_version + 1.hour,
        newsletter_notifications_at: Time.current,
        tos_agreement: true,
        password_updated_at: Time.current
      )

      user
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

    def create_taxonomy!(name:, parent:)
      Decidim::Taxonomy.create!(
        name: Decidim::Faker::Localized.literal(name),
        organization:,
        parent:
      )
    end

    def create_taxonomy_filter!(root_taxonomy:, taxonomies:, participatory_space_manifests: [])
      Decidim::TaxonomyFilter.create!(
        root_taxonomy:,
        participatory_space_manifests:,
        filter_items: taxonomies.map do |taxonomy_item|
          Decidim::TaxonomyFilterItem.new(
            taxonomy_item:
          )
        end
      )
    end

    def create_report!(reportable:, current_user:)
      moderation = Moderation.find_or_create_by!(reportable:, participatory_space: reportable.participatory_space)

      Decidim::Report.create!(
        moderation:,
        user: current_user,
        locale: I18n.locale,
        reason: "spam",
        details: "From the seeds"
      )
    rescue ActiveRecord::RecordInvalid
      # Ignore in case we have an error in the report creation.
      # Most likely is a "Validation failed: User has already been taken"
    end

    def hide_report!(reportable:)
      moderation = Moderation.find_or_create_by!(reportable:, participatory_space: reportable.participatory_space)
      moderation.update!(hidden_at: Time.zone.now)
    end

    def create_user_report!(reportable:, current_user:)
      moderation = UserModeration.find_or_create_by!(user: reportable)

      UserReport.create!(
        moderation:,
        user: current_user,
        reason: "spam",
        details: "From the seeds"
      )
    end

    def seed_components_manifests!(participatory_space:)
      Decidim.component_manifests.each do |manifest|
        manifest.seed!(participatory_space.reload)
      end
    end

    def random_avatar
      file_number = format("%03d", rand(1...100))

      create_blob!(seeds_file: "avatars/#{file_number}.jpg", filename: "#{file_number}.jpg", content_type: "image/jpeg")
    end

    def create_follow!(user, followable)
      Decidim::Follow.create!(followable:, user:)
    end
  end
end
