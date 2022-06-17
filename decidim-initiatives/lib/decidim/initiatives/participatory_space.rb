# frozen_string_literal: true

Decidim.register_participatory_space(:initiatives) do |participatory_space|
  participatory_space.icon = "media/images/decidim_initiatives.svg"
  participatory_space.stylesheet = "decidim/initiatives/initiatives"

  participatory_space.context(:public) do |context|
    context.engine = Decidim::Initiatives::Engine
    context.layout = "layouts/decidim/initiative"
  end

  participatory_space.context(:admin) do |context|
    context.engine = Decidim::Initiatives::AdminEngine
    context.layout = "layouts/decidim/admin/initiative"
  end

  participatory_space.participatory_spaces do |organization|
    Decidim::Initiative.where(organization:)
  end

  participatory_space.query_type = "Decidim::Initiatives::InitiativeType"

  participatory_space.register_resource(:initiative) do |resource|
    resource.actions = %w(comment)
    resource.permissions_class_name = "Decidim::Initiatives::Permissions"
    resource.model_class_name = "Decidim::Initiative"
    resource.card = "decidim/initiatives/initiative"
    resource.searchable = true
  end

  participatory_space.register_resource(:initiatives_type) do |resource|
    resource.model_class_name = "Decidim::InitiativesType"
    resource.actions = %w(vote)
  end

  participatory_space.model_class_name = "Decidim::Initiative"
  participatory_space.permissions_class_name = "Decidim::Initiatives::Permissions"

  participatory_space.exports :initiatives do |export|
    export.collection do
      Decidim::Initiative
    end

    export.serializer Decidim::Initiatives::InitiativeSerializer
  end

  participatory_space.seeds do
    seeds_root = File.join(__dir__, "..", "..", "..", "db", "seeds")
    organization = Decidim::Organization.first

    Decidim::ContentBlock.create(
      organization:,
      weight: 33,
      scope_name: :homepage,
      manifest_name: :highlighted_initiatives,
      published_at: Time.current
    )

    3.times do |n|
      type = Decidim::InitiativesType.create!(
        title: Decidim::Faker::Localized.sentence(word_count: 5),
        description: Decidim::Faker::Localized.sentence(word_count: 25),
        organization:,
        banner_image: ActiveStorage::Blob.create_and_upload!(
          io: File.open(File.join(seeds_root, "city2.jpeg")),
          filename: "banner_image.jpeg",
          content_type: "image/jpeg",
          metadata: nil
        )
      )

      organization.top_scopes.each do |scope|
        Decidim::InitiativesTypeScope.create(
          type:,
          scope:,
          supports_required: (n + 1) * 1000
        )
      end
    end

    Decidim::Initiative.states.keys.each do |state|
      Decidim::Initiative.skip_callback(:save, :after, :notify_state_change, raise: false)
      Decidim::Initiative.skip_callback(:create, :after, :notify_creation, raise: false)

      params = {
        title: Decidim::Faker::Localized.sentence(word_count: 3),
        description: Decidim::Faker::Localized.sentence(word_count: 25),
        scoped_type: Decidim::InitiativesTypeScope.reorder(Arel.sql("RANDOM()")).first,
        state:,
        signature_type: "online",
        signature_start_date: Date.current - 7.days,
        signature_end_date: Date.current + 7.days,
        published_at: 7.days.ago,
        author: Decidim::User.reorder(Arel.sql("RANDOM()")).first,
        organization:
      }

      initiative = Decidim.traceability.perform_action!(
        "publish",
        Decidim::Initiative,
        organization.users.first,
        visibility: "all"
      ) do
        Decidim::Initiative.create!(params)
      end
      initiative.add_to_index_as_search_resource

      Decidim::Comments::Seed.comments_for(initiative)

      Decidim::Attachment.create!(
        title: Decidim::Faker::Localized.sentence(word_count: 2),
        description: Decidim::Faker::Localized.sentence(word_count: 5),
        attached_to: initiative,
        content_type: "image/jpeg",
        file: ActiveStorage::Blob.create_and_upload!(
          io: File.open(File.join(seeds_root, "city.jpeg")),
          filename: "city.jpeg",
          content_type: "image/jpeg",
          metadata: nil
        )
      )

      Decidim::Initiatives.default_components.each do |component_name|
        component = Decidim::Component.create!(
          name: Decidim::Components::Namer.new(initiative.organization.available_locales, component_name).i18n_name,
          manifest_name: component_name,
          published_at: Time.current,
          participatory_space: initiative
        )

        next unless component_name == :pages

        Decidim::Pages::CreatePage.call(component) do
          on(:invalid) { raise "Can't create page" }
        end
      end
    end
  end
end
