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
        params = {
          component:,
          title: ::Faker::Lorem.paragraph,
          body: create_body,
          published_at:,
          accepting_suggestions: [true, false].sample
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

        document
      end

      def create_body
        text_block = []
        rand(3..5).times do
          text_block << "<h2>#{::Faker::Lorem.word.capitalize}</h2>"
          level = 3
          rand(1..4).times do
            text_block << "<h#{level}>#{::Faker::Lorem.word.capitalize}</h#{level}>"
            text_block << ::Faker::HTML.paragraph(sentence_count: rand(3..5))
            text_block << ::Faker::HTML.random(exclude: [:heading, :script, :table])
            level += 1
          end
        end
        text_block.join("\n")
      end
    end
  end
end
