# frozen_string_literal: true

Decidim.register_participatory_space(:participatory_processes) do |participatory_space|
  participatory_space.icon = "media/images/decidim_participatory_processes.svg"
  participatory_space.model_class_name = "Decidim::ParticipatoryProcess"
  participatory_space.content_blocks_scope_name = "participatory_process_homepage"

  participatory_space.participatory_spaces do |organization|
    Decidim::ParticipatoryProcesses::OrganizationParticipatoryProcesses.new(organization).query
  end

  participatory_space.query_type = "Decidim::ParticipatoryProcesses::ParticipatoryProcessType"
  participatory_space.query_finder = "Decidim::ParticipatoryProcesses::ParticipatoryProcessFinder"
  participatory_space.query_list = "Decidim::ParticipatoryProcesses::ParticipatoryProcessList"

  participatory_space.permissions_class_name = "Decidim::ParticipatoryProcesses::Permissions"

  participatory_space.breadcrumb_cell = "decidim/participatory_processes/process_dropdown_metadata"

  participatory_space.register_resource(:participatory_process) do |resource|
    resource.model_class_name = "Decidim::ParticipatoryProcess"
    resource.card = "decidim/participatory_processes/process"
    resource.searchable = true
  end

  participatory_space.register_resource(:participatory_process_group) do |resource|
    resource.model_class_name = "Decidim::ParticipatoryProcessGroup"
    resource.card = "decidim/participatory_processes/process_group"
    resource.content_blocks_scope_name = "participatory_process_group_homepage"
    resource.searchable = true
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
    export.collection do
      Decidim::ParticipatoryProcess.public_spaces
    end

    export.include_in_open_data = true

    export.serializer Decidim::ParticipatoryProcesses::ParticipatoryProcessSerializer
    export.open_data_serializer Decidim::ParticipatoryProcesses::OpenDataParticipatoryProcessSerializer
  end

  participatory_space.register_on_destroy_account do |user|
    Decidim::ParticipatoryProcessUserRole.where(user:).destroy_all
  end

  participatory_space.seeds do
    require "decidim/participatory_processes/seeds"

    Decidim::ParticipatoryProcesses::Seeds.new.call
  end
end
