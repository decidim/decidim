# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/seeds"

module Decidim
  module CollaborativeTexts
    class Seeds < Decidim::Seeds
      attr_reader :participatory_space

      def initialize(participatory_space:)
        @participatory_space = participatory_space
      end

      def call
        component = create_component!

        number_of_records.times do
          create_document!(component:)
        end

        number_of_records.times do
          create_document!(component:, published_at: nil)
        end
      end

      def create_component!
        params = {
          name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :collaborative_texts).i18n_name,
          manifest_name: :collaborative_texts,
          published_at: Time.current,
          participatory_space: participatory_space
        }

        Decidim.traceability.perform_action!(
          "publish",
          Decidim::Component,
          admin_user,
          visibility: "all"
        ) do
          Decidim::Component.create!(params)
        end
      end

      def create_document!(component:, published_at: Time.current)
        body_blocks = create_body_blocks
        params = {
          component:,
          title: ::Faker::Lorem.paragraph,
          body: body_blocks.join("\n"),
          published_at:,
          accepting_suggestions: [true, false].sample,
          coauthorships: [Decidim::Coauthorship.new(author: organization)]
        }

        document = Decidim.traceability.create!(
          Decidim::CollaborativeTexts::Document,
          admin_user,
          params,
          visibility: "all"
        )

        # Create some versions
        number_of_records.times do |num|
          params = {
            document:,
            body: create_body,
            created_at: num.seconds.from_now
          }
          Decidim.traceability.create!(
            Decidim::CollaborativeTexts::Version,
            admin_user,
            params,
            visibility: "all"
          )
        end

        # Create some suggestions
        random_positions = (0...body_blocks.size).to_a.sample(5)
        random_positions.each do |position|
          changeset = {
            firstNode: position.to_s,
            lastNode: (position + rand(1..3)).to_s,
            replace: rand(1..4).times.map { ::Faker::HTML.paragraph(sentence_count: rand(1..3)) }
          }
          create_suggestion!(document_version: document.current_version, changeset:)
        end

        document
      end

      def create_suggestion!(document_version:, changeset:)
        params = {
          document_version:,
          changeset:,
          author: document_version.organization.users.sample
        }
        Decidim::CollaborativeTexts::Suggestion.create!(params)
      end

      def create_body_blocks
        blocks = []
        rand(3..5).times do
          blocks << "<h2>#{::Faker::Lorem.word.capitalize}</h2>"
          level = 3
          rand(1..4).times do
            blocks << "<h#{level}>#{::Faker::Lorem.word.capitalize}</h#{level}>"
            blocks << ::Faker::HTML.paragraph(sentence_count: rand(3..5))
            blocks << ::Faker::HTML.random(exclude: [:heading, :script, :table])
            level += 1
          end
        end
        blocks
      end
    end
  end
end
