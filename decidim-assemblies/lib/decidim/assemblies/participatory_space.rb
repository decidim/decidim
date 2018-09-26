# frozen_string_literal: true

Decidim.register_participatory_space(:assemblies) do |participatory_space|
  participatory_space.icon = "decidim/assemblies/assembly.svg"
  participatory_space.model_class_name = "Decidim::Assembly"

  participatory_space.participatory_spaces do |organization|
    Decidim::Assemblies::OrganizationAssemblies.new(organization).query
  end

  participatory_space.permissions_class_name = "Decidim::Assemblies::Permissions"

  participatory_space.register_resource(:assembly) do |resource|
    resource.model_class_name = "Decidim::Assembly"
    resource.card = "decidim/assemblies/assembly"
  end

  participatory_space.context(:public) do |context|
    context.engine = Decidim::Assemblies::Engine
    context.layout = "layouts/decidim/assembly"
  end

  participatory_space.context(:admin) do |context|
    context.engine = Decidim::Assemblies::AdminEngine
    context.layout = "layouts/decidim/admin/assembly"
  end

  participatory_space.seeds do
    organization = Decidim::Organization.first
    seeds_root = File.join(__dir__, "..", "..", "..", "db", "seeds")

    Decidim::ContentBlock.create(
      organization: organization,
      weight: 32,
      scope: :homepage,
      manifest_name: :highlighted_assemblies,
      published_at: Time.current
    )

    2.times do |n|
      params = {
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
        scope: n.positive? ? Decidim::Scope.reorder(Arel.sql("RANDOM()")).first : nil,
        purpose_of_action: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end,
        composition: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end,
        assembly_type: "others",
        assembly_type_other: Decidim::Faker::Localized.word,
        creation_date: 1.day.from_now,
        created_by: "others",
        created_by_other: Decidim::Faker::Localized.word,
        duration: 2.days.from_now,
        included_at: 5.days.from_now,
        closing_date: 5.days.from_now,
        closing_date_reason: Decidim::Faker::Localized.sentence(3),
        internal_organisation: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end,
        is_transparent: true,
        special_features: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(3)
        end,
        twitter_handler: Faker::Lorem.word,
        facebook_handler: Faker::Lorem.word,
        instagram_handler: Faker::Lorem.word,
        youtube_handler: Faker::Lorem.word,
        github_handler: Faker::Lorem.word
      }

      assembly = Decidim.traceability.create!(
        Decidim::Assembly,
        organization.users.first,
        params,
        visibility: "all"
      )

      # Create users with specific roles
      Decidim::AssemblyUserRole::ROLES.each do |role|
        email = "assembly_#{assembly.id}_#{role}@example.org"

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

        Decidim::AssemblyUserRole.find_or_create_by!(
          user: user,
          assembly: assembly,
          role: role
        )
      end

      child = Decidim::Assembly.create!(
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
        scope: n.positive? ? Decidim::Scope.reorder(Arel.sql("RANDOM()")).first : nil,
        parent: assembly
      )

      [assembly, child].each do |current_assembly|
        attachment_collection = Decidim::AttachmentCollection.create!(
          name: Decidim::Faker::Localized.word,
          description: Decidim::Faker::Localized.sentence(5),
          collection_for: current_assembly
        )

        Decidim::Attachment.create!(
          title: Decidim::Faker::Localized.sentence(2),
          description: Decidim::Faker::Localized.sentence(5),
          file: File.new(File.join(seeds_root, "Exampledocument.pdf")),
          attachment_collection: attachment_collection,
          attached_to: current_assembly
        )

        Decidim::Attachment.create!(
          title: Decidim::Faker::Localized.sentence(2),
          description: Decidim::Faker::Localized.sentence(5),
          file: File.new(File.join(seeds_root, "city.jpeg")),
          attached_to: current_assembly
        )

        Decidim::Attachment.create!(
          title: Decidim::Faker::Localized.sentence(2),
          description: Decidim::Faker::Localized.sentence(5),
          file: File.new(File.join(seeds_root, "Exampledocument.pdf")),
          attached_to: current_assembly
        )

        2.times do
          Decidim::Category.create!(
            name: Decidim::Faker::Localized.sentence(5),
            description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
              Decidim::Faker::Localized.paragraph(3)
            end,
            participatory_space: current_assembly
          )
        end

        Decidim::AssemblyMember::POSITIONS.each do |position|
          Decidim::AssemblyMember.create!(
            full_name: Faker::Name.name,
            gender: Faker::Lorem.word,
            birthday: Faker::Date.birthday(18, 65),
            birthplace: Faker::Demographic.demonym,
            designation_date: Faker::Date.between(1.year.ago, 1.month.ago),
            designation_mode: Faker::Lorem.word,
            position: position,
            position_other: position == "other" ? Faker::Job.position : nil,
            assembly: current_assembly
          )
        end

        Decidim::AssemblyMember.create!(
          user: current_assembly.organization.users.first,
          gender: Faker::Lorem.word,
          birthday: Faker::Date.birthday(18, 65),
          birthplace: Faker::Demographic.demonym,
          designation_date: Faker::Date.between(1.year.ago, 1.month.ago),
          designation_mode: Faker::Lorem.word,
          position: "other",
          position_other: Faker::Job.position,
          assembly: current_assembly
        )

        Decidim.component_manifests.each do |manifest|
          manifest.seed!(current_assembly.reload)
        end
      end
    end
  end
end
