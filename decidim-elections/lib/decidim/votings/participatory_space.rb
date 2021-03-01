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

  participatory_space.exports :votings do |export|
    export.collection do |voting|
      Decidim::Votings::Voting.where(id: voting.id)
    end

    export.include_in_open_data = true

    export.serializer Decidim::Votings::VotingSerializer
  end

  participatory_space.seeds do
    organization = Decidim::Organization.first
    seeds_root = File.join(__dir__, "..", "..", "..", "db", "seeds")

    3.times do |n|
      params = {
        organization: organization,
        title: Decidim::Faker::Localized.sentence(word_count: 5),
        slug: Decidim::Faker::Internet.unique.slug(words: nil, glue: "-"),
        description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(sentence_count: 3)
        end,
        scope: n.positive? ? nil : Decidim::Scope.reorder(Arel.sql("RANDOM()")).first,
        banner_image: File.new(File.join(seeds_root, "city.jpeg")),
        published_at: 2.weeks.ago,
        start_time: n.weeks.from_now,
        end_time: (n + 1).weeks.from_now + 4.hours,
        voting_type: Decidim::Votings::Voting.voting_types.values.sample,
        promoted: n.odd?
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

      landing_page_content_blocks = [:header, :description, :elections, :polling_stations, :attachments_and_folders, :stats, :metrics]

      landing_page_content_blocks.each.with_index(1) do |manifest_name, index|
        Decidim::ContentBlock.create(
          organization: organization,
          scope_name: :voting_landing_page,
          manifest_name: manifest_name,
          weight: index,
          scoped_resource_id: voting.id,
          published_at: Time.current
        )
      end
    end
  end
end

Decidim.register_global_engine(
  :decidim_votings_polling_officer_zone,
  Decidim::Votings::PollingOfficerZoneEngine,
  at: "/polling_officers"
)
