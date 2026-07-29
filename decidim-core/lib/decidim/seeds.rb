# frozen_string_literal: true

require "faker"
require "decidim/faker/internet"
require "decidim/faker/localized"

module Decidim
  # Base class to be inherited from the different modules' seeds classes
  class Seeds
    SEEDS_CONFIG = {
      comments_per_resource_count: { slow: 0..6, fast: 0..2 },
      comments_nested_probability: { slow: 0.5, fast: 0.2 },
      comments_vote_skip_probability: { slow: 0.5, fast: 0.7 },
      comments_votes_per_comment_count: { slow: 0..12, fast: 0..3 },
      # Note that the slow seeds for the budgets component are heavy because of
      # the amount of votes per budget:
      # - Maximum amount of votes in each budgets component: 3 * 100 = 300
      # - Amount of spaces: 2 processes + 4 assemblies + 2 conferences = 6
      # - Maximum total amount of votes: 300 * 6 = 1800
      budgets_count: { slow: 1..3, fast: 1 },
      budgets_projects_per_budget_count: { slow: 3..5, fast: 1 },
      budgets_votes_per_budget_count: { slow: 10..100, fast: 2..20 },
      # Note that the slow seeds for the meetings component are heavy because of
      # these values:
      # - Maximum amount of surveys per component: 5
      # - Maximum amount of responses per component: 5 * 200 = 1000
      # - Amount of spaces: 2 processes + 4 assemblies + 2 conferences = 6
      # - Maximum total amount of surveys: 6 * 5 = 30
      # - Maximum total amount of responses for all surveys: 6 * 1000 = 6000
      surveys_count: { slow: 3..5, fast: 1 },
      surveys_responses_count: { slow: 0..200, fast: 0..20 },
      surveys_response_options_count: { slow: 3, fast: 2 },
      surveys_matrix_rows_count: { slow: 3, fast: 2 },
      initiatives_types_count: { slow: 3..5, fast: 1 },
      initiatives_votes_count: { slow: 0..50, fast: 0..10 },
      # Note that the slow seeds for the accountability component are heavy
      # because of these values (particularly because of the amount of comments
      # created):
      # - Maximum amount of result taxonomies for each space: 5
      # - Maximum amount of parent results for each space: 5 * 5 = 25
      # - Maximum amount of child results for each space: 25 * 2 = 50
      # - Maximum total amount of results for each space: 75
      # - Maximum amount of top-level comments for all results in a space: 75 * 6 = 450
      # - Maximum amount of nested comments for all results in a space (one for each top-level comment): 450
      # - Maximum total amount of comments for all results in a space: 900
      # - Amount of spaces: 2 processes + 4 assemblies + 2 conferences = 6
      # - Maximum total amount of results: 6 * 75 = 450
      # - Maximum total amount of comments for all results: 6 * 900 = 5400
      accountability_statuses_count: { slow: 5, fast: 3 },
      accountability_taxonomies_count: { slow: 6, fast: 1 },
      accountability_results_per_taxonomy_count: { slow: 3..5, fast: 1 },
      accountability_children_per_result_count: { slow: 0..2, fast: 0..1 },
      accountability_milestones_per_result_count: { slow: 3..5, fast: 1 },
      # For each assembly also a child assembly is created, so the total number
      # of assemblies is actually two times the defined amount.
      assemblies_count: { slow: 2, fast: 1 },
      assemblies_types_taxonomies_count: { slow: 3..5, fast: 1 },
      conferences_count: { slow: 2, fast: 1 },
      participatory_processes_count: { slow: 2, fast: 1 },
      participatory_processes_groups_count: { slow: 2, fast: 1 },
      participatory_processes_types_taxonomies_count: { slow: 3..5, fast: 1 },
      conferences_speakers_count: { slow: 3..5, fast: 1 },
      conferences_partners_per_type_count: { slow: 3..5, fast: 1 },
      conferences_media_links_count: { slow: 3..5, fast: 1 },
      conferences_registration_types_count: { slow: 3..5, fast: 1 },
      # Note that the slow seeds for the meetings component are heavy because of
      # these values:
      # - Amount of meeting types: 4
      # - Maximum amount of meetings per component: 4 * 5 = 20
      # - Maximum total amount of comments for all meetings in a space: 20 * 6 * 2 = 240
      # - Amount of spaces: 2 processes + 4 assemblies + 2 conferences = 6
      # - Maximum total amount of meetings: 6 * 20 = 120
      # - Maximum total amount of comments for all meetings: 6 * 240 = 1440
      meetings_per_type_count: { slow: 3..5, fast: 1 },
      meetings_services_per_meeting_count: { slow: 3..5, fast: 1 },
      meetings_registrations_per_meeting_count: { slow: 3..5, fast: 1 },
      # Note that the slow seeds for the meetings component are heavy because of
      # these values:
      # - Maximum amount of proposals per component: 50
      # - Maximum total amount of comments for all proposals in a space: 50 * 6 * 2 = 600
      # - Amount of spaces: 2 processes + 4 assemblies + 2 conferences = 6
      # - Maximum total amount of proposals: 6 * 50 = 300
      # - Maximum total amount of comments for all meetings: 6 * 600 = 3600
      proposals_count: { slow: 5..50, fast: 5..10 },
      proposals_votes_per_proposal_count: { slow: 0..2, fast: 0..2 },
      proposals_notes_per_proposal_count: { slow: 0..2, fast: 0..2 },
      blogs_posts_count: { slow: 3..5, fast: 1 },
      collaborative_texts_published_documents_count: { slow: 3..5, fast: 1 },
      collaborative_texts_unpublished_documents_count: { slow: 3..5, fast: 1 },
      collaborative_texts_versions_per_document_count: { slow: 3..5, fast: 1 },
      debates_open_count: { slow: 3..5, fast: 1 },
      elections_count: { slow: 3..5, fast: 1 },
      elections_create_questions_probability: { slow: 0.3, fast: 0.3 },
      elections_questions_per_election_count: { slow: 3..5, fast: 1 },
      elections_voters_per_election_count: { slow: 3..5, fast: 1 },
      root_taxonomies_states_count: { slow: 3..5, fast: 1 },
      root_taxonomies_cities_per_state_count: { slow: 3..5, fast: 1 },
      root_taxonomies_territories_count: { slow: 3..5, fast: 1 },
      root_taxonomies_sectors_count: { slow: 3..5, fast: 1 },
      root_taxonomies_categories_count: { slow: 3..5, fast: 1 },
      root_taxonomies_subcategories_per_category_count: { slow: 3..5, fast: 1 },
      scopes_count: { slow: 3..5, fast: 1 },
      scopes_subscopes_per_scope_count: { slow: 3..5, fast: 1 },
      areas_territories_count: { slow: 3..5, fast: 1 },
      areas_sectors_count: { slow: 3..5, fast: 1 }
    }.freeze

    protected

    def slow_seeds?
      Decidim::Env.new("SLOW_SEEDS").present?
    end

    def config_value(key)
      value = slow_seeds? ? SEEDS_CONFIG[key][:slow] : SEEDS_CONFIG[key][:fast]
      return rand(value) if value.is_a?(Range)

      value
    end

    def organization
      @organization ||= Decidim::Organization.first
    end

    def admin_user
      @admin_user ||= Decidim::User.find_by(organization:, email: "admin@example.org")
    end

    def generate_nickname
      suffix = ["-", "_", ""].sample + rand(100_000).to_s
      base = Faker::Internet.username(specifier: nil, separators: ["_", "-"])[0...(20 - suffix.length)]

      I18n.transliterate("#{base}#{suffix}").downcase.gsub(/[^a-z0-9_-]/, "_")
    end

    def find_or_initialize_user_by(email:, with_random_avatar: true)
      user = Decidim::User.find_or_initialize_by(email:)
      avatar = with_random_avatar ? random_avatar : nil
      user.update!(generate_user_details(avatar:))

      user
    end

    def bulk_find_or_create_users(emails:, only_ids: false)
      existing_emails = Decidim::User.where(organization:, email: emails).pluck(:email)

      result = Decidim::User.transaction do
        # rubocop:disable Rails/SkipsModelValidations
        Decidim::User.insert_all(
          (emails - existing_emails).map do |email|
            details = generate_user_details.except(:organization, :tos_agreement, :avatar)
            encrypted_password = ::Devise::Encryptor.digest(Decidim::User, details.delete(:password))
            { decidim_organization_id: organization.id, email:, encrypted_password:, **details }
          end
        )
        # rubocop:enable Rails/SkipsModelValidations
      end
      return result.rows.map(&:first) if only_ids

      Decidim::User.where(organization:, email: emails)
    end

    def generate_user_details(avatar: nil)
      {
        name: ::Faker::Name.name,
        nickname: generate_nickname,
        password: "decidim123456789",
        organization:,
        confirmed_at: Time.current,
        locale: I18n.default_locale,
        personal_url: ::Faker::Internet.url,
        about: ::Faker::Lorem.paragraph(sentence_count: 2),
        avatar:,
        accepted_tos_version: organization.tos_version + 1.hour,
        newsletter_notifications_at: Time.current,
        tos_agreement: true,
        password_updated_at: Time.current
      }
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

    def random_email(suffix:)
      r = SecureRandom.hex(4)

      "#{suffix}-author-#{participatory_space.underscored_name}-#{participatory_space.id}-#{r}@example.org"
    end

    def create_follow!(user, followable)
      Decidim::Follow.create!(followable:, user:)
    end
  end
end
