# frozen_string_literal: true

require "decidim/votings/seeds"

Decidim.register_participatory_space(:votings) do |participatory_space|
  participatory_space.icon = "media/images/decidim_votings.svg"
  participatory_space.model_class_name = "Decidim::Votings::Voting"
  participatory_space.content_blocks_scope_name = "voting_landing_page"
  participatory_space.permissions_class_name = "Decidim::Votings::Permissions"
  participatory_space.stylesheet = "decidim/votings/votings"
  participatory_space.query_type = "Decidim::Votings::VotingType"

  participatory_space.breadcrumb_cell = "decidim/votings/voting_dropdown_metadata"

  participatory_space.participatory_spaces do |organization|
    Decidim::Votings::Voting.where(organization:)
  end

  participatory_space.register_resource(:voting) do |resource|
    resource.model_class_name = "Decidim::Votings::Voting"
    resource.card = "decidim/votings/voting"
    resource.searchable = true
  end

  participatory_space.context(:public) do |context|
    context.engine = Decidim::Votings::Engine
    context.layout = "layouts/decidim/votings"
    context.helper = "Decidim::Votings::ApplicationHelper"
  end

  participatory_space.context(:admin) do |context|
    context.engine = Decidim::Votings::AdminEngine
    context.layout = "layouts/decidim/admin/voting"
  end

  participatory_space.exports :votings do |export|
    export.collection do |voting|
      Decidim::Votings::Voting.where(id: voting.id)
    end

    export.include_in_open_data = true

    export.serializer Decidim::Votings::VotingSerializer
  end

  participatory_space.seeds do
    Decidim::Votings::Seeds.new.call
  end
end

Decidim.register_global_engine(
  :decidim_votings_polling_officer_zone,
  Decidim::Votings::PollingOfficerZoneEngine,
  at: "/polling_officers"
)
