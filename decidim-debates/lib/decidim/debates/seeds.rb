# frozen_string_literal: true

require "decidim/components/namer"

module Decidim
  module Debates
    class Seeds < Decidim::Seeds
      attr_reader :participatory_space

      def initialize(participatory_space:)
        @participatory_space = participatory_space
      end

      def call
        user = Decidim::User.find_by(
          organization: participatory_space.organization,
          email: "user@example.org"
        )

        params = {
          name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :debates).i18n_name,
          manifest_name: :debates,
          published_at: Time.current,
          participatory_space:
        }

        component = Decidim.traceability.perform_action!(
          "publish",
          Decidim::Component,
          admin_user,
          visibility: "all"
        ) do
          Decidim::Component.create!(params)
        end

        number_of_records.times do |x|
          finite = x != 2
          if finite
            start_time = [rand(1..20).weeks.from_now, rand(1..20).weeks.ago].sample
            end_time = start_time + [rand(1..4).hours, rand(1..20).days].sample
          else
            start_time = nil
            end_time = nil
          end
          params = {
            component:,
            title: Decidim::Faker::Localized.sentence(word_count: 2),
            description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
              Decidim::Faker::Localized.paragraph(sentence_count: 3)
            end,
            instructions: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
              Decidim::Faker::Localized.paragraph(sentence_count: 3)
            end,
            start_time:,
            end_time:,
            author: component.organization
          }

          debate = Decidim.traceability.create!(
            Decidim::Debates::Debate,
            admin_user,
            params,
            visibility: "all"
          )

          Decidim::Comments::Seed.comments_for(debate)
        end

        closed_debate = Decidim::Debates::Debate.last
        closed_debate.conclusions = Decidim::Faker::Localized.wrapped("<p>", "</p>") do
          Decidim::Faker::Localized.paragraph(sentence_count: 3)
        end
        closed_debate.closed_at = Time.current
        closed_debate.save!

        params = {
          component:,
          title: Decidim::Faker::Localized.sentence(word_count: 2),
          description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 3)
          end,
          instructions: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 3)
          end,
          author: user
        }

        Decidim.traceability.create!(
          Decidim::Debates::Debate,
          user,
          params,
          visibility: "all"
        )
      end
    end
  end
end
