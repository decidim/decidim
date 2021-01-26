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

  participatory_space.seeds do
    organization = Decidim::Organization.first

    2.times do |n|
      params = {
        organization: organization,
        title: Decidim::Faker::Localized.sentence(word_count: 5),
        slug: Decidim::Faker::Internet.unique.slug(words: nil, glue: "-"),
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(sentence_count: 3)
        end,
        published_at: 2.weeks.ago,
        start_time: 3.weeks.from_now,
        end_time: 3.weeks.from_now + 4.hours,
        scope: n.positive? ? nil : Decidim::Scope.reorder(Arel.sql("RANDOM()")).first
      }

      voting = Decidim.traceability.perform_action!(
        "publish",
        Decidim::Votings::Voting,
        organization.users.first,
        visibility: "all"
      ) do
        Decidim::Votings::Voting.create!(params)
      end
      voting.add_to_index_as_search_resource
    end
  end
end
