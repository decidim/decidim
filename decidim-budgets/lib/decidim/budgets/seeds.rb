# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/seeds"

module Decidim
  module Budgets
    class Seeds < Decidim::Seeds
      attr_reader :participatory_space

      def initialize(participatory_space:)
        @participatory_space = participatory_space
      end

      def call
        landing_page_content = Decidim::Faker::Localized.localized do
          "<h2>#{::Faker::Lorem.sentence}</h2>" \
            "<p>#{::Faker::Lorem.paragraph}</p>" \
            "<p>#{::Faker::Lorem.paragraph}</p>"
        end

        component = Decidim::Component.create!(
          name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :budgets).i18n_name,
          manifest_name: :budgets,
          published_at: Time.current,
          participatory_space:,
          settings: {
            landing_page_content:,
            more_information_modal: Decidim::Faker::Localized.paragraph(sentence_count: 4),
            workflow: Decidim::Budgets.workflows.keys.sample
          }
        )

        rand(1...3).times do
          Decidim::Budgets::Budget.create!(
            component:,
            title: Decidim::Faker::Localized.sentence(word_count: 2),
            description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
              Decidim::Faker::Localized.paragraph(sentence_count: 3)
            end,
            total_budget: ::Faker::Number.number(digits: 8)
          )
        end

        Decidim::Budgets::Budget.where(component:).each do |budget|
          rand(2...4).times do
            project = Decidim::Budgets::Project.create!(
              budget:,
              scope: participatory_space.organization.scopes.sample,
              category: participatory_space.categories.sample,
              title: Decidim::Faker::Localized.sentence(word_count: 2),
              description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
                Decidim::Faker::Localized.paragraph(sentence_count: 3)
              end,
              budget_amount: ::Faker::Number.between(from: Integer(budget.total_budget * 0.7), to: budget.total_budget)
            )

            attachment_collection = create_attachment_collection(collection_for: project)
            create_attachment(attached_to: project, filename: "Exampledocument.pdf", attachment_collection:)
            create_attachment(attached_to: project, filename: "city.jpeg")
            create_attachment(attached_to: project, filename: "Exampledocument.pdf")

            Decidim::Comments::Seed.comments_for(project)
          end
        end
      end
    end
  end
end
