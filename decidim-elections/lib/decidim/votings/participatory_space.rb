# frozen_string_literal: true

Decidim.register_participatory_space(:votings) do |participatory_space|
  participatory_space.icon = "media/images/decidim_votings.svg"
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
        banner_image: ActiveStorage::Blob.create_and_upload!(
          io: File.open(File.join(seeds_root, "city.jpeg")),
          filename: "banner_image.jpeg",
          content_type: "image/jpeg",
          metadata: nil
        ), # Keep after organization
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

      unless voting.online_voting?
        3.times do
          params = {
            voting: voting,
            title: Decidim::Faker::Localized.sentence(word_count: 5),
            address: Faker::Address.full_address,
            latitude: Faker::Address.latitude,
            longitude: Faker::Address.longitude,
            location: Decidim::Faker::Localized.sentence,
            location_hints: Decidim::Faker::Localized.sentence
          }

          polling_station = Decidim.traceability.create!(
            Decidim::Votings::PollingStation,
            organization.users.first,
            params,
            visibility: "all"
          )

          email = "voting_#{voting.id}_president_#{polling_station.id}@example.org"

          user = Decidim::User.find_or_initialize_by(email: email)
          user.update!(
            name: Faker::Name.name,
            nickname: Faker::Twitter.unique.screen_name,
            password: "decidim123456789",
            password_confirmation: "decidim123456789",
            organization: organization,
            confirmed_at: Time.current,
            locale: I18n.default_locale,
            tos_agreement: true
          )

          Decidim.traceability.create!(
            Decidim::Votings::PollingOfficer,
            organization.users.first,
            {
              voting: voting,
              user: user,
              presided_polling_station: polling_station
            },
            visibility: "all"
          )
        end
      end

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

      2.times do
        Decidim::Category.create!(
          name: Decidim::Faker::Localized.sentence(word_count: 5),
          description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 3)
          end,
          participatory_space: voting
        )
      end

      Decidim.component_manifests.each do |manifest|
        manifest.seed!(voting.reload)
      end

      unless voting.online_voting?
        voting.reload.published_elections.finished.each do |election|
          polling_officer = voting.polling_officers.sample
          ps_closure = Decidim::Votings::PollingStationClosure.create!(
            election: election,
            polling_officer: polling_officer,
            polling_station: polling_officer.polling_station,
            signed_at: Time.current,
            phase: :complete
          )

          valid_ballots = Faker::Number.number(digits: 3)
          Decidim::Elections::Result.create!(
            value: valid_ballots,
            closurable: ps_closure,
            question: nil,
            answer: nil,
            result_type: :valid_ballots
          )

          null_ballots = Faker::Number.number(digits: 1)
          Decidim::Elections::Result.create!(
            value: null_ballots,
            closurable: ps_closure,
            question: nil,
            answer: nil,
            result_type: :null_ballots
          )

          blank_ballots = Faker::Number.number(digits: 2)
          Decidim::Elections::Result.create!(
            value: blank_ballots,
            closurable: ps_closure,
            question: nil,
            answer: nil,
            result_type: :blank_ballots
          )

          Decidim::Elections::Result.create!(
            value: valid_ballots + null_ballots + blank_ballots,
            closurable: ps_closure,
            question: nil,
            answer: nil,
            result_type: :total_ballots
          )

          election.questions.each do |question|
            question_pending = valid_ballots
            question.answers.shuffle.each do |answer|
              answer_value = Faker::Number.between(from: 0, to: question_pending)
              Decidim::Elections::Result.create!(
                value: answer_value,
                closurable: ps_closure,
                question: question,
                answer: answer,
                result_type: :valid_answers
              )
              question_pending -= answer_value
            end

            next unless question.nota_option?

            Decidim::Elections::Result.create!(
              value: question_pending,
              closurable: ps_closure,
              question: question,
              answer: nil,
              result_type: :blank_answers
            )
          end
        end
      end

      (1..2).each do |i|
        ballot_style = voting.ballot_styles.create!(code: "DISTRICT#{i}")
        voting.elections.each do |election|
          election.questions.sample(1 + rand(election.questions.count)).each do |question|
            ballot_style.ballot_style_questions.create!(question: question)
          end
        end
      end
    end
  end
end

Decidim.register_global_engine(
  :decidim_votings_polling_officer_zone,
  Decidim::Votings::PollingOfficerZoneEngine,
  at: "/polling_officers"
)
