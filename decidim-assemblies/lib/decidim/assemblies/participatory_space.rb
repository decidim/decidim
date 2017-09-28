# frozen_string_literal: true

Decidim.register_participatory_space(:assemblies) do |participatory_space|
  participatory_space.engine = Decidim::Assemblies::Engine
  participatory_space.admin_engine = Decidim::Assemblies::AdminEngine
  participatory_space.icon = "decidim/assemblies/icon.svg"
  participatory_space.model_class_name = "Decidim::Assembly"

  participatory_space.seeds do
    organization = Decidim::Organization.first
    seeds_root = File.join(__dir__, "..", "..", "..", "db", "seeds")

    3.times do
      Decidim::Assembly.create!(
        title: Decidim::Faker::Localized.sentence(5),
        slug: Faker::Internet.unique.slug(nil, "-"),
        subtitle: Decidim::Faker::Localized.sentence(2),
        hashtag: "##{Faker::Lorem.word}",
        short_description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.sentence(3)
        end,
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end,
        hero_image: File.new(File.join(seeds_root, "city.jpeg")),
        banner_image: File.new(File.join(seeds_root, "city2.jpeg")),
        promoted: true,
        published_at: 2.weeks.ago,
        organization: organization,
        meta_scope: Decidim::Faker::Localized.word,
        developer_group: Decidim::Faker::Localized.sentence(1),
        local_area: Decidim::Faker::Localized.sentence(2),
        target: Decidim::Faker::Localized.sentence(3),
        participatory_scope: Decidim::Faker::Localized.sentence(1),
        participatory_structure: Decidim::Faker::Localized.sentence(2),
        scope: Faker::Boolean.boolean(0.5) ? nil : Decidim::Scope.reorder("RANDOM()").first
      )
    end

    Decidim::Assembly.find_each do |assembly|
      Decidim::Attachment.create!(
        title: Decidim::Faker::Localized.sentence(2),
        description: Decidim::Faker::Localized.sentence(5),
        file: File.new(File.join(seeds_root, "city.jpeg")),
        attached_to: assembly
      )

      Decidim::Attachment.create!(
        title: Decidim::Faker::Localized.sentence(2),
        description: Decidim::Faker::Localized.sentence(5),
        file: File.new(File.join(seeds_root, "Exampledocument.pdf")),
        attached_to: assembly
      )

      2.times do
        Decidim::Category.create!(
          name: Decidim::Faker::Localized.sentence(5),
          description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(3)
          end,
          participatory_space: assembly
        )
      end

      Decidim.feature_manifests.each do |manifest|
        manifest.seed!(assembly.reload)
      end
    end
  end
end
