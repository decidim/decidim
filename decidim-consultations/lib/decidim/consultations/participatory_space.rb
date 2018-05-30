# frozen_string_literal: true

Decidim.register_participatory_space(:consultations) do |participatory_space|
  participatory_space.icon = "decidim/consultations/icon.svg"
  participatory_space.model_class_name = "Decidim::Consultations::Question"
  participatory_space.permissions_class_name = "Decidim::Consultations::Permissions"

  participatory_space.participatory_spaces do |organization|
    Decidim::Consultations::Question.where(organization: organization)
  end

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
  end

  participatory_space.seeds do
    seeds_root = File.join(__dir__, "..", "..", "..", "db", "seeds")
    organization = Decidim::Organization.first

    # Active consultation
    active_consultation = Decidim::Consultation.create!(
      slug: Faker::Internet.unique.slug(nil, "-"),
      title: Decidim::Faker::Localized.sentence(3),
      subtitle: Decidim::Faker::Localized.sentence(3),
      description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
        Decidim::Faker::Localized.paragraph(3)
      end,
      published_at: Time.now.utc,
      start_voting_date: Time.zone.today,
      end_voting_date: Time.zone.today + 1.month,
      banner_image: File.new(File.join(seeds_root, "city2.jpeg")),
      introductory_video_url: "https://www.youtube.com/embed/zhMMW0TENNA",
      decidim_highlighted_scope_id: Decidim::Scope.reorder(Arel.sql("RANDOM()")).first.id,
      organization: organization
    )

    finished_consultation = Decidim::Consultation.create!(
      slug: Faker::Internet.unique.slug(nil, "-"),
      title: Decidim::Faker::Localized.sentence(3),
      subtitle: Decidim::Faker::Localized.sentence(3),
      description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
        Decidim::Faker::Localized.paragraph(3)
      end,
      published_at: Time.zone.today - 2.months,
      results_published_at: Time.zone.today - 1.month,
      start_voting_date: Time.zone.today - 2.months,
      end_voting_date: Time.zone.today - 1.month,
      banner_image: File.new(File.join(seeds_root, "city2.jpeg")),
      introductory_video_url: "https://www.youtube.com/embed/zhMMW0TENNA",
      decidim_highlighted_scope_id: Decidim::Scope.reorder(Arel.sql("RANDOM()")).first.id,
      organization: organization
    )

    upcoming_consultation = Decidim::Consultation.create!(
      slug: Faker::Internet.unique.slug(nil, "-"),
      title: Decidim::Faker::Localized.sentence(3),
      subtitle: Decidim::Faker::Localized.sentence(3),
      description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
        Decidim::Faker::Localized.paragraph(3)
      end,
      published_at: Time.zone.today + 1.month,
      start_voting_date: Time.zone.today + 1.month + 1.day,
      end_voting_date: Time.zone.today + 2.months,
      banner_image: File.new(File.join(seeds_root, "city2.jpeg")),
      introductory_video_url: "https://www.youtube.com/embed/zhMMW0TENNA",
      decidim_highlighted_scope_id: Decidim::Scope.reorder(Arel.sql("RANDOM()")).first.id,
      organization: organization
    )

    [finished_consultation, active_consultation, upcoming_consultation].each do |consultation|
      4.times do
        question = Decidim::Consultations::Question.create!(
          consultation: consultation,
          slug: Faker::Internet.unique.slug(nil, "-"),
          decidim_scope_id: Decidim::Scope.reorder(Arel.sql("RANDOM()")).first.id,
          title: Decidim::Faker::Localized.sentence(3),
          subtitle: Decidim::Faker::Localized.sentence(3),
          what_is_decided: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(3)
          end,
          question_context: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(3)
          end,
          hero_image: File.new(File.join(seeds_root, "city.jpeg")),
          banner_image: File.new(File.join(seeds_root, "city2.jpeg")),
          promoter_group: Decidim::Faker::Localized.sentence(3),
          participatory_scope: Decidim::Faker::Localized.sentence(3),
          published_at: Time.now.utc,
          organization: organization
        )

        2.times do
          Decidim::Consultations::Response.create(
            question: question,
            title: Decidim::Faker::Localized.sentence(3)
          )
        end

        Decidim::Comments::Seed.comments_for(question)

        Decidim::Attachment.create!(
          title: Decidim::Faker::Localized.sentence(2),
          description: Decidim::Faker::Localized.sentence(5),
          file: File.new(File.join(seeds_root, "city.jpeg")),
          attached_to: question
        )

        Decidim::Attachment.create!(
          title: Decidim::Faker::Localized.sentence(2),
          description: Decidim::Faker::Localized.sentence(5),
          file: File.new(File.join(seeds_root, "Exampledocument.pdf")),
          attached_to: question
        )
      end
    end
  end
end
