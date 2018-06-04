# frozen_string_literal: true

Decidim.register_participatory_space(:initiatives) do |participatory_space|
  participatory_space.stylesheet = "decidim/initiatives/initiatives"

  participatory_space.context(:public) do |context|
    context.engine = Decidim::Initiatives::Engine
    context.layout = "layouts/decidim/initiative"
  end

  participatory_space.context(:admin) do |context|
    context.engine = Decidim::Initiatives::AdminEngine
    context.layout = "layouts/decidim/admin/initiatives"
  end

  participatory_space.participatory_spaces do |organization|
    Decidim::Initiative.where(organization: organization)
  end

  participatory_space.register_resource(:initiative) do |resource|
    resource.model_class_name = "Decidim::Initiative"
    resource.card = "decidim/initiatives/initiative"
  end

  participatory_space.model_class_name = "Decidim::Initiative"
  participatory_space.permissions_class_name = "Decidim::Initiatives::Permissions"

  participatory_space.seeds do
    seeds_root = File.join(__dir__, "..", "..", "..", "db", "seeds")
    organization = Decidim::Organization.first

    3.times do |n|
      type = Decidim::InitiativesType.create!(
        title: Decidim::Faker::Localized.sentence(5),
        description: Decidim::Faker::Localized.sentence(25),
        organization: organization,
        banner_image: File.new(File.join(seeds_root, "city2.jpeg"))
      )

      organization.top_scopes.each do |scope|
        Decidim::InitiativesTypeScope.create(
          type: type,
          scope: scope,
          supports_required: (n + 1) * 1000
        )
      end
    end

    Decidim::Initiative.states.keys.each do |state|
      Decidim::Initiative.skip_callback(:save, :after, :notify_state_change, raise: false)
      Decidim::Initiative.skip_callback(:create, :after, :notify_creation, raise: false)

      initiative = Decidim::Initiative.create!(
        title: Decidim::Faker::Localized.sentence(3),
        description: Decidim::Faker::Localized.sentence(25),
        scoped_type: Decidim::InitiativesTypeScope.reorder(Arel.sql("RANDOM()")).first,
        state: state,
        signature_type: "online",
        signature_start_time: DateTime.current - 7.days,
        signature_end_time:  DateTime.current + 7.days,
        published_at: DateTime.current - 7.days,
        author: Decidim::User.reorder(Arel.sql("RANDOM()")).first,
        organization: organization
      )

      Decidim::Comments::Seed.comments_for(initiative)

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
