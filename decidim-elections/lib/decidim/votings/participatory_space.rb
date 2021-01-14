# frozen_string_literal: true

Decidim.register_participatory_space(:votings) do |participatory_space|
  participatory_space.icon = "decidim/votings/icon.svg"
  participatory_space.model_class_name = "Decidim::Votings::Voting"
  participatory_space.permissions_class_name = "Decidim::Votings::Permissions"
  participatory_space.stylesheet = "decidim/votings/votings"
  participatory_space.query_type = "Decidim::Votings::VotingType"

  participatory_space.participatory_spaces do |organization|
    Decidim::Votings::Voting.where(organization: organization)
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

  # participatory_space.register_on_destroy_account do |user|
  #   Decidim::VotingsUserRole.where(user: user).destroy_all
  # end

  # participatory_space.seeds do
  # end
end
