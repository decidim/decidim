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

  participatory_space.breadcrumb_cell = "decidim/initiatives/initiative_dropdown_metadata"

  participatory_space.register_resource(:initiative) do |resource|
    resource.actions = %w(comment)
    resource.permissions_class_name = "Decidim::Initiatives::Permissions"
    resource.model_class_name = "Decidim::Initiative"
    resource.card = "decidim/initiatives/initiative"
    resource.searchable = true
  end

  participatory_space.register_resource(:initiatives_type) do |resource|
    resource.model_class_name = "Decidim::InitiativesType"
    resource.actions = %w(create)
  end

  participatory_space.register_stat :followers_count,
                                    priority: Decidim::StatsRegistry::MEDIUM_PRIORITY,
                                    icon_name: "user-follow-line",
                                    tooltip_key: "followers_count_tooltip" do
    Decidim::Initiatives::InitiativesStatsFollowersCount.for(participatory_space)
  end

  participatory_space.model_class_name = "Decidim::Initiative"
  participatory_space.permissions_class_name = "Decidim::Initiatives::Permissions"

  participatory_space.data_portable_entities = [
    "Decidim::Initiative"
  ]

  participatory_space.exports :initiatives do |export|
    export.collection do
      Decidim::Initiative.public_spaces
    end

    export.include_in_open_data = true

    export.serializer Decidim::Initiatives::InitiativeSerializer
    export.open_data_serializer Decidim::Initiatives::OpenDataInitiativeSerializer
  end

  participatory_space.seeds do
    require "decidim/initiatives/seeds"

    Decidim::Initiatives::Seeds.new.call
  end
end
