# frozen_string_literal: true

Decidim.register_participatory_space(:consultations) do |participatory_space|
  participatory_space.icon = "decidim_consultations.svg"
  participatory_space.model_class_name = "Decidim::Consultation"
  participatory_space.permissions_class_name = "Decidim::Consultations::Permissions"
  participatory_space.stylesheet = "decidim/consultations/consultations"

  participatory_space.participatory_spaces do |organization|
    Decidim::Consultation.where(organization:)
  end

  participatory_space.query_type = "Decidim::Consultations::ConsultationType"

  participatory_space.context(:public) do |context|
    context.engine = Decidim::Consultations::Engine
    context.layout = "layouts/decidim/question"
    context.helper = "Decidim::Consultations::ConsultationsHelper"
  end

  participatory_space.context(:admin) do |context|
    context.engine = Decidim::Consultations::AdminEngine
    context.layout = "layouts/decidim/admin/question"
  end

  participatory_space.register_resource(:consultation) do |resource|
    resource.model_class_name = "Decidim::Consultation"
    resource.card = "decidim/consultations/consultation"
    resource.searchable = true
  end

  participatory_space.register_resource(:question) do |resource|
    resource.model_class_name = "Decidim::Consultations::Question"
    resource.actions = %w(vote comment)
  end

  participatory_space.seeds do
    seeds_root = File.join(__dir__, "..", "..", "..", "db", "seeds")
    organization = Decidim::Organization.first

    # Active consultation
    active_consultation_params = {
      slug: Decidim::Faker::Internet.unique.slug(words: nil, glue: "-"),
      title: Decidim::Faker::Localized.sentence(word_count: 3),
      subtitle: Decidim::Faker::Localized.sentence(word_count: 3),
      description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
        Decidim::Faker::Localized.paragraph(sentence_count: 3)
      end,
      published_at: Time.now.utc,
      start_voting_date: Time.zone.today,
      end_voting_date: Time.zone.today + 1.month,
      organization:,
      banner_image: ActiveStorage::Blob.create_and_upload!(
        io: File.open(File.join(seeds_root, "city2.jpeg")),
        filename: "banner_image.jpeg",
        content_type: "image/jpeg",
        metadata: nil
      ), # Keep after organization
      introductory_video_url: "https://www.youtube.com/embed/zhMMW0TENNA",
      decidim_highlighted_scope_id: Decidim::Scope.reorder(Arel.sql("RANDOM()")).first.id
    }

    active_consultation = Decidim.traceability.perform_action!(
      "publish",
      Decidim::Consultation,
      organization.users.first,
      visibility: "all"
    ) do
      Decidim::Consultation.create!(active_consultation_params)
    end
    active_consultation.add_to_index_as_search_resource

    finished_consultation_params = {
      slug: Decidim::Faker::Internet.unique.slug(words: nil, glue: "-"),
      title: Decidim::Faker::Localized.sentence(word_count: 3),
      subtitle: Decidim::Faker::Localized.sentence(word_count: 3),
      description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
        Decidim::Faker::Localized.paragraph(sentence_count: 3)
      end,
      published_at: Time.zone.today - 2.months,
      results_published_at: Time.zone.today - 1.month,
      start_voting_date: Time.zone.today - 2.months,
      end_voting_date: Time.zone.today - 1.month,
      organization:,
      banner_image: ActiveStorage::Blob.create_and_upload!(
        io: File.open(File.join(seeds_root, "city2.jpeg")),
        filename: "banner_image.jpeg",
        content_type: "image/jpeg",
        metadata: nil
      ), # Keep after organization
      introductory_video_url: "https://www.youtube.com/embed/zhMMW0TENNA",
      decidim_highlighted_scope_id: Decidim::Scope.reorder(Arel.sql("RANDOM()")).first.id
    }

    finished_consultation = Decidim.traceability.perform_action!(
      "publish",
      Decidim::Consultation,
      organization.users.first,
      visibility: "all"
    ) do
      Decidim::Consultation.create!(finished_consultation_params)
    end
    finished_consultation.add_to_index_as_search_resource

    upcoming_consultation_params = {
      slug: Decidim::Faker::Internet.unique.slug(words: nil, glue: "-"),
      title: Decidim::Faker::Localized.sentence(word_count: 3),
      subtitle: Decidim::Faker::Localized.sentence(word_count: 3),
      description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
        Decidim::Faker::Localized.paragraph(sentence_count: 3)
      end,
      published_at: Time.zone.today + 1.month,
      start_voting_date: Time.zone.today + 1.month + 1.day,
      end_voting_date: Time.zone.today + 2.months,
      organization:,
      banner_image: ActiveStorage::Blob.create_and_upload!(
        io: File.open(File.join(seeds_root, "city2.jpeg")),
        filename: "banner_image.jpeg",
        content_type: "image/jpeg",
        metadata: nil
      ), # Keep after organization
      introductory_video_url: "https://www.youtube.com/embed/zhMMW0TENNA",
      decidim_highlighted_scope_id: Decidim::Scope.reorder(Arel.sql("RANDOM()")).first.id
    }

    upcoming_consultation = Decidim.traceability.perform_action!(
      "publish",
      Decidim::Consultation,
      organization.users.first,
      visibility: "all"
    ) do
      Decidim::Consultation.create!(upcoming_consultation_params)
    end
    upcoming_consultation.add_to_index_as_search_resource

    [finished_consultation, active_consultation, upcoming_consultation].each do |consultation|
      4.times do
        params = {
          consultation:,
          slug: Decidim::Faker::Internet.unique.slug(words: nil, glue: "-"),
          decidim_scope_id: Decidim::Scope.reorder(Arel.sql("RANDOM()")).first.id,
          title: Decidim::Faker::Localized.sentence(word_count: 3),
          subtitle: Decidim::Faker::Localized.sentence(word_count: 3),
          what_is_decided: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 3)
          end,
          question_context: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 3)
          end,
          organization:,
          hero_image: ActiveStorage::Blob.create_and_upload!(
            io: File.open(File.join(seeds_root, "city.jpeg")),
            filename: "hero_image.jpeg",
            content_type: "image/jpeg",
            metadata: nil
          ), # Keep after organization
          banner_image: ActiveStorage::Blob.create_and_upload!(
            io: File.open(File.join(seeds_root, "city2.jpeg")),
            filename: "banner_image.jpeg",
            content_type: "image/jpeg",
            metadata: nil
          ), # Keep after organization
          promoter_group: Decidim::Faker::Localized.sentence(word_count: 3),
          participatory_scope: Decidim::Faker::Localized.sentence(word_count: 3),
          published_at: Time.now.utc
        }

        question = Decidim.traceability.perform_action!(
          "publish",
          Decidim::Consultations::Question,
          organization.users.first,
          visibility: "all"
        ) do
          Decidim::Consultations::Question.create!(params)
        end

        2.times do
          Decidim::Consultations::Response.create(
            question:,
            title: Decidim::Faker::Localized.sentence(word_count: 3)
          )
        end

        Decidim::Comments::Seed.comments_for(question)

        Decidim::Attachment.create!(
          title: Decidim::Faker::Localized.sentence(word_count: 2),
          description: Decidim::Faker::Localized.sentence(word_count: 5),
          attached_to: question,
          content_type: "image/jpeg",
          file: ActiveStorage::Blob.create_and_upload!(
            io: File.open(File.join(seeds_root, "city.jpeg")),
            filename: "city.jpeg",
            content_type: "image/jpeg",
            metadata: nil
          ) # Keep after attached_to
        )

        Decidim::Attachment.create!(
          title: Decidim::Faker::Localized.sentence(word_count: 2),
          description: Decidim::Faker::Localized.sentence(word_count: 5),
          attached_to: question,
          content_type: "application/pdf",
          file: ActiveStorage::Blob.create_and_upload!(
            io: File.open(File.join(seeds_root, "Exampledocument.pdf")),
            filename: "Exampledocument.pdf",
            content_type: "application/pdf",
            metadata: nil
          ) # Keep after attached_to
        )
      end
    end
  end
end
