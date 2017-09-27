# frozen_string_literal: true

Decidim.register_participatory_space(:participatory_processes) do |participatory_space|
  participatory_space.engine = Decidim::ParticipatoryProcesses::Engine
  participatory_space.admin_engine = Decidim::ParticipatoryProcesses::AdminEngine
  participatory_space.icon = "decidim/participatory_processes/icon.svg"
  participatory_space.model_class_name = "Decidim::ParticipatoryProcess"

  participatory_space.seeds do
    organization = Decidim::Organization.first
    seeds_root = File.join(__dir__, "..", "..", "..", "db", "seeds")

    process_groups = []
    3.times do
      process_groups << Decidim::ParticipatoryProcessGroup.create!(
        name: Decidim::Faker::Localized.sentence(3),
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end,
        hero_image: File.new(File.join(seeds_root, "city.jpeg")),
        organization: organization
      )
    end

    3.times do
      Decidim::ParticipatoryProcess.create!(
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
        start_date: Time.current,
        end_date: 2.month.from_now.at_midnight,
        participatory_process_group: process_groups.sample,
        scope: Faker::Boolean.boolean(0.5) ? nil : Decidim::Scope.reorder("RANDOM()").first
      )
    end

    Decidim::ParticipatoryProcess.find_each do |process|
      Decidim::ParticipatoryProcessStep.find_or_initialize_by(
        participatory_process: process,
        active: true
      ).update!(
        title: Decidim::Faker::Localized.sentence(1, false, 2),
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end,
        start_date: 1.month.ago.at_midnight,
        end_date: 2.months.from_now.at_midnight
      )

      # Create users with specific roles
      Decidim::ParticipatoryProcessUserRole::ROLES.each do |role|
        email = "participatory_process_#{process.id}_#{role}@example.org"

        user = Decidim::User.find_or_initialize_by(email: email)
        user.update!(
          name: Faker::Name.name,
          password: "decidim123456",
          password_confirmation: "decidim123456",
          organization: organization,
          confirmed_at: Time.current,
          locale: I18n.default_locale,
          tos_agreement: true
        )

        Decidim::ParticipatoryProcessUserRole.find_or_create_by!(
          user: user,
          participatory_process: process,
          role: role
        )
      end

      Decidim::Attachment.create!(
        title: Decidim::Faker::Localized.sentence(2),
        description: Decidim::Faker::Localized.sentence(5),
        file: File.new(File.join(seeds_root, "city.jpeg")),
        attached_to: process
      )

      Decidim::Attachment.create!(
        title: Decidim::Faker::Localized.sentence(2),
        description: Decidim::Faker::Localized.sentence(5),
        file: File.new(File.join(seeds_root, "Exampledocument.pdf")),
        attached_to: process
      )

      2.times do
        Decidim::Category.create!(
          name: Decidim::Faker::Localized.sentence(5),
          description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(3)
          end,
          participatory_space: process
        )
      end

      Decidim.feature_manifests.each do |manifest|
        manifest.seed!(process.reload)
      end
    end
  end
end
