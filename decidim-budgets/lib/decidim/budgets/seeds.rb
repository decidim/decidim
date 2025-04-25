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
        component = create_component!

        number_of_records.times do
          create_budget!(component:)
        end

        Decidim::Budgets::Budget.where(component:).each do |budget|
          number_of_records.times do
            project = create_project!(budget:)

            create_attachments!(attached_to: project)

            Decidim::Comments::Seed.comments_for(project)
          end
        end
      end

      def create_component!
        landing_page_content = Decidim::Faker::Localized.localized do
          "<h2>#{::Faker::Lorem.sentence}</h2>" \
            "<p>#{::Faker::Lorem.paragraph}</p>" \
            "<p>#{::Faker::Lorem.paragraph}</p>"
        end

        params = {
          name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :budgets).i18n_name,
          manifest_name: :budgets,
          published_at: Time.current,
          participatory_space:,
          settings: {
            geocoding_enabled: [true, false].sample,
            landing_page_content:,
            more_information_modal: Decidim::Faker::Localized.paragraph(sentence_count: 4),
            workflow: Decidim::Budgets.workflows.keys.sample
          }
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

      def create_budget!(component:)
        Decidim.traceability.perform_action!(
          "create",
          Decidim::Budgets::Budget,
          admin_user
        ) do
          Decidim::Budgets::Budget.create!(
            component:,
            title: Decidim::Faker::Localized.sentence(word_count: 2),
            description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
              Decidim::Faker::Localized.paragraph(sentence_count: 3)
            end,
            total_budget: ::Faker::Number.number(digits: 8)
          )
        end
      end

      def create_project!(budget:)
        params = {
          budget:,
          title: Decidim::Faker::Localized.sentence(word_count: 2),
          description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 3)
          end,
          budget_amount: ::Faker::Number.between(from: Integer(budget.total_budget * 0.7), to: budget.total_budget)
        }

        if budget.component.settings.geocoding_enabled?
          params = params.merge(
            address: "#{::Faker::Address.street_address} #{::Faker::Address.zip} #{::Faker::Address.city}",
            latitude: ::Faker::Address.latitude,
            longitude: ::Faker::Address.longitude
          )
        end

        Decidim.traceability.perform_action!(
          "create",
          Decidim::Budgets::Project,
          admin_user
        ) do
          Decidim::Budgets::Project.create!(params)
        end
      end
    end
  end
end
