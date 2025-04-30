# frozen_string_literal: true

Decidim.register_participatory_space(:assemblies) do |participatory_space|
  participatory_space.icon = "media/images/decidim_assemblies.svg"
  participatory_space.model_class_name = "Decidim::Assembly"
  participatory_space.content_blocks_scope_name = "assembly_homepage"

  participatory_space.participatory_spaces do |organization|
    Decidim::Assemblies::OrganizationAssemblies.new(organization).query
  end

  participatory_space.permissions_class_name = "Decidim::Assemblies::Permissions"

  participatory_space.query_type = "Decidim::Assemblies::AssemblyType"

  participatory_space.breadcrumb_cell = "decidim/assemblies/assembly_dropdown_metadata"

  participatory_space.register_resource(:assembly) do |resource|
    resource.model_class_name = "Decidim::Assembly"
    resource.card = "decidim/assemblies/assembly"
    resource.searchable = true
  end

  participatory_space.register_stat :followers_count,
                                    priority: Decidim::StatsRegistry::MEDIUM_PRIORITY,
                                    icon_name: "user-follow-line",
                                    tooltip_key: "followers_count_tooltip" do
    Decidim::Assemblies::AssembliesStatsFollowersCount.for(participatory_space)
  end

  participatory_space.context(:public) do |context|
    context.engine = Decidim::Assemblies::Engine
    context.layout = "layouts/decidim/assembly"
  end

  participatory_space.context(:admin) do |context|
    context.engine = Decidim::Assemblies::AdminEngine
    context.layout = "layouts/decidim/admin/assembly"
  end

  participatory_space.exports :assemblies do |export|
    export.collection do
      Decidim::Assembly
        .public_spaces
        .includes(:attachment_collections)
    end

    export.include_in_open_data = true

    export.serializer Decidim::Assemblies::AssemblySerializer
    export.open_data_serializer Decidim::Assemblies::OpenDataAssemblySerializer
  end

  participatory_space.register_on_destroy_account do |user|
    Decidim::AssemblyUserRole.where(user:).destroy_all
  end

  participatory_space.seeds do
    require "decidim/assemblies/seeds"

    Decidim::Assemblies::Seeds.new.call
  end
end
