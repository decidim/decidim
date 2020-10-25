# frozen_string_literal: true

Decidim.register_participatory_space(:participatory_processes) do |participatory_space|
  participatory_space.icon = "decidim/participatory_processes/process.svg"
  participatory_space.model_class_name = "Decidim::ParticipatoryProcess"

  participatory_space.participatory_spaces do |organization|
    Decidim::ParticipatoryProcesses::OrganizationParticipatoryProcesses.new(organization).query
  end

  participatory_space.query_type = "Decidim::ParticipatoryProcesses::ParticipatoryProcessType"
  participatory_space.query_finder = "Decidim::ParticipatoryProcesses::ParticipatoryProcessFinder"
  participatory_space.query_list = "Decidim::ParticipatoryProcesses::ParticipatoryProcessList"

  participatory_space.permissions_class_name = "Decidim::ParticipatoryProcesses::Permissions"

  participatory_space.register_resource(:participatory_process) do |resource|
    resource.model_class_name = "Decidim::ParticipatoryProcess"
    resource.card = "decidim/participatory_processes/process"
    resource.searchable = true
  end

  participatory_space.register_resource(:participatory_process_group) do |resource|
    resource.model_class_name = "Decidim::ParticipatoryProcessGroup"
    resource.card = "decidim/participatory_processes/process_group"
  end

  participatory_space.register_stat :followers_count, tag: :followers, priority: Decidim::StatsRegistry::LOW_PRIORITY do |spaces, _start_at, _end_at|
    Decidim::Follow.where(followable: spaces).count
  end

  participatory_space.context(:public) do |context|
    context.engine = Decidim::ParticipatoryProcesses::Engine
    context.layout = "layouts/decidim/participatory_process"
    context.helper = "Decidim::ParticipatoryProcesses::ParticipatoryProcessHelper"
  end

  participatory_space.context(:admin) do |context|
    context.engine = Decidim::ParticipatoryProcesses::AdminEngine
    context.layout = "layouts/decidim/admin/participatory_process"
  end

  participatory_space.exports :participatory_processes do |export|
    export.collection do |participatory_process|
      Decidim::ParticipatoryProcess.where(id: participatory_process.id)
    end

    export.serializer Decidim::ParticipatoryProcesses::ParticipatoryProcessSerializer
  end

  participatory_space.register_on_destroy_account do |user|
    Decidim::ParticipatoryProcessUserRole.where(user: user).destroy_all
  end

  participatory_space.seeds do
    organization = Decidim::Organization.first
    seeds_root = File.join(__dir__, "..", "..", "..", "db", "seeds")

    Decidim::ContentBlock.create(
      organization: organization,
      weight: 31,
      scope_name: :homepage,
      manifest_name: :highlighted_processes,
      published_at: Time.current
    )

    process_groups = []
    2.times do
      process_groups << Decidim::ParticipatoryProcessGroup.create!(
        name: Decidim::Faker::Localized.sentence(3),
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end,
        organization: organization,
        hero_image: File.new(File.join(seeds_root, "city.jpeg")) # Keep after organization
      )
    end

    2.times do |n|
      params = {
        title: Decidim::Faker::Localized.sentence(5),
        slug: Faker::Internet.unique.slug(words: nil, glue: "-"),
        subtitle: Decidim::Faker::Localized.sentence(2),
        hashtag: "##{Faker::Lorem.word}",
        short_description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.sentence(3)
        end,
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end,
        organization: organization,
        hero_image: File.new(File.join(seeds_root, "city.jpeg")), # Keep after organization
        banner_image: File.new(File.join(seeds_root, "city2.jpeg")), # Keep after organization
        promoted: true,
        published_at: 2.weeks.ago,
        meta_scope: Decidim::Faker::Localized.word,
        developer_group: Decidim::Faker::Localized.sentence(1),
        local_area: Decidim::Faker::Localized.sentence(2),
        target: Decidim::Faker::Localized.sentence(3),
        participatory_scope: Decidim::Faker::Localized.sentence(1),
        participatory_structure: Decidim::Faker::Localized.sentence(2),
        start_date: Date.current,
        end_date: 2.months.from_now,
        participatory_process_group: process_groups.sample,
        scope: n.positive? ? nil : Decidim::Scope.reorder(Arel.sql("RANDOM()")).first
      }

      process = Decidim.traceability.perform_action!(
        "publish",
        Decidim::ParticipatoryProcess,
        organization.users.first,
        visibility: "all"
      ) do
        Decidim::ParticipatoryProcess.create!(params)
      end
      process.add_to_index_as_search_resource

      Decidim::ParticipatoryProcessStep.find_or_initialize_by(
        participatory_process: process,
        active: true
      ).update!(
        title: Decidim::Faker::Localized.sentence(1, false, 2),
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end,
        start_date: 1.month.ago,
        end_date: 2.months.from_now
      )

      # Create users with specific roles
      Decidim::ParticipatoryProcessUserRole::ROLES.each do |role|
        email = "participatory_process_#{process.id}_#{role}@example.org"

        user = Decidim::User.find_or_initialize_by(email: email)
        user.update!(
          name: Faker::Name.name,
          nickname: Faker::Twitter.unique.screen_name,
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

      attachment_collection = Decidim::AttachmentCollection.create!(
        name: Decidim::Faker::Localized.word,
        description: Decidim::Faker::Localized.sentence(5),
        collection_for: process
      )

      Decidim::Attachment.create!(
        title: Decidim::Faker::Localized.sentence(2),
        description: Decidim::Faker::Localized.sentence(5),
        attachment_collection: attachment_collection,
        attached_to: process,
        file: File.new(File.join(seeds_root, "Exampledocument.pdf")) # Keep after attached_to
      )

      Decidim::Attachment.create!(
        title: Decidim::Faker::Localized.sentence(2),
        description: Decidim::Faker::Localized.sentence(5),
        attached_to: process,
        file: File.new(File.join(seeds_root, "city.jpeg")) # Keep after attached_to
      )

      Decidim::Attachment.create!(
        title: Decidim::Faker::Localized.sentence(2),
        description: Decidim::Faker::Localized.sentence(5),
        attached_to: process,
        file: File.new(File.join(seeds_root, "Exampledocument.pdf")) # Keep after attached_to
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

      Decidim.component_manifests.each do |manifest|
        manifest.seed!(process.reload)
      end
    end
  end
end
