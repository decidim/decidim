# frozen_string_literal: true

require "decidim/seeds"

module Decidim
  module Votings
    class Seeds < Decidim::Seeds
      def call
        Decidim::Votings::Voting.voting_types.values.each do |voting_type|
          voting = create_voting!(voting_type:)

          unless voting.online_voting?
            3.times do
              polling_station = create_polling_station!(voting:)

              create_polling_officer!(voting:, polling_station:)
            end
          end

          create_landing_page!(voting:)

          2.times do
            create_category!(participatory_space: voting)
          end

          Decidim.component_manifests.each do |manifest|
            manifest.seed!(voting.reload)
          end

          unless voting.online_voting?
            voting.reload.published_elections.finished.each do |election|
              create_results!(election:, voting:)
            end
          end

          (1..2).each do |i|
            ballot_style = voting.ballot_styles.create!(code: "DISTRICT#{i}")
            voting.elections.each do |election|
              election.questions.sample(1 + rand(election.questions.count)).each do |question|
                ballot_style.ballot_style_questions.create!(question:)
              end
            end
          end
        end
      end

      def create_voting!(voting_type: Decidim::Votings::Voting.voting_types.values.sample)
        n = rand(3)
        params = {
          organization:,
          title: Decidim::Faker::Localized.sentence(word_count: 5),
          slug: Decidim::Faker::Internet.unique.slug(words: nil, glue: "-"),
          description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 3)
          end,
          scope: n.positive? ? nil : Decidim::Scope.all.sample,
          banner_image: ::Faker::Boolean.boolean(true_ratio: 0.5) ? banner_image : nil, # Keep after organization
          published_at: 2.weeks.ago,
          start_time: n.weeks.from_now,
          end_time: (n + 1).weeks.from_now + 4.hours,
          voting_type:,
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

        voting
      end

      def create_polling_station!(voting:)
        params = {
          voting:,
          title: Decidim::Faker::Localized.sentence(word_count: 5),
          address: ::Faker::Address.full_address,
          latitude: ::Faker::Address.latitude,
          longitude: ::Faker::Address.longitude,
          location: Decidim::Faker::Localized.sentence,
          location_hints: Decidim::Faker::Localized.sentence
        }

        Decidim.traceability.create!(
          Decidim::Votings::PollingStation,
          organization.users.first,
          params,
          visibility: "all"
        )
      end

      def create_polling_officer!(voting:, polling_station:)
        email = "voting_#{voting.id}_president_#{polling_station.id}@example.org"
        user = find_or_initialize_user_by(email:)

        Decidim.traceability.create!(
          Decidim::Votings::PollingOfficer,
          organization.users.first,
          {
            voting:,
            user:,
            presided_polling_station: polling_station
          },
          visibility: "all"
        )
      end

      def create_landing_page!(voting:)
        landing_page_content_blocks = [:hero, :title, :related_elections, :polling_stations, :related_documents, :related_images, :stats, :metrics]

        landing_page_content_blocks.each.with_index(1) do |manifest_name, index|
          Decidim::ContentBlock.create(
            organization:,
            scope_name: :voting_landing_page,
            manifest_name:,
            weight: index,
            scoped_resource_id: voting.id,
            published_at: Time.current
          )
        end
      end

      def create_results!(election:, voting:)
        polling_officer = voting.polling_officers.sample
        ps_closure = Decidim::Votings::PollingStationClosure.create!(
          election:,
          polling_officer:,
          polling_station: polling_officer.polling_station,
          signed_at: Time.current,
          phase: :complete
        )

        valid_ballots = ::Faker::Number.number(digits: 3)
        Decidim::Elections::Result.create!(
          value: valid_ballots,
          closurable: ps_closure,
          question: nil,
          answer: nil,
          result_type: :valid_ballots
        )

        null_ballots = ::Faker::Number.number(digits: 1)
        Decidim::Elections::Result.create!(
          value: null_ballots,
          closurable: ps_closure,
          question: nil,
          answer: nil,
          result_type: :null_ballots
        )

        blank_ballots = ::Faker::Number.number(digits: 2)
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
            answer_value = ::Faker::Number.between(from: 0, to: question_pending)
            Decidim::Elections::Result.create!(
              value: answer_value,
              closurable: ps_closure,
              question:,
              answer:,
              result_type: :valid_answers
            )
            question_pending -= answer_value
          end

          next unless question.nota_option?

          Decidim::Elections::Result.create!(
            value: question_pending,
            closurable: ps_closure,
            question:,
            answer: nil,
            result_type: :blank_answers
          )
        end
      end
    end
  end
end
