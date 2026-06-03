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

            create_project_votes!(project:)

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

        step_settings = if participatory_space.allows_steps?
                          { participatory_space.active_step.id => {
                            votes: %w(enabled disabled finished).sample
                          } }
                        else
                          {}
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
          },
          step_settings:
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
            total_budget: ::Faker::Number.number(digits: 7)
          )
        end
      end

      def create_project!(budget:)
        minimum_amount = Integer(budget.total_budget * 0.1)
        maximum_amount = Integer(budget.total_budget * 0.5)
        params = {
          budget:,
          title: Decidim::Faker::Localized.sentence(word_count: 2),
          description: Decidim::Faker::Localized.wrapped("<p>", "</p>") do
            Decidim::Faker::Localized.paragraph(sentence_count: 3)
          end,
          budget_amount: ::Faker::Number.between(from: minimum_amount, to: maximum_amount)
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

      def create_project_votes!(project:)
        candidate_projects = project.budget.projects.where.not(id: project.id).to_a

        min_budgets_votes_count = config_value(:budgets_votes_count) / 5
        max_budgets_votes_count = config_value(:budgets_votes_count) * 2

        rand(min_budgets_votes_count..max_budgets_votes_count).times do |n|
          user = find_or_initialize_user_by(email: random_email(suffix: "budget-#{project.id}-vote-#{n}"), with_random_avatar: false)

          Decidim.traceability.perform_action!(
            "create",
            Decidim::Budgets::Order,
            user,
            visibility: "private-only"
          ) do
            order = Decidim::Budgets::Order.create!(user:, budget: project.budget)
            add_projects_to_order!(order:, project:, candidate_projects:)
            order.update!(checked_out_at: Time.current) if order.can_checkout?
            order
          end
        end
      end

      def add_projects_to_order!(order:, project:, candidate_projects:)
        selected_projects = [project]
        total_budget = project.budget_amount

        candidate_projects.shuffle.each do |candidate|
          next if selected_projects.include?(candidate)
          next if total_budget + candidate.budget_amount > project.budget.total_budget

          selected_projects << candidate
          total_budget += candidate.budget_amount
        end

        selected_projects.each do |selected_project|
          order.projects << selected_project
        end
      end
    end
  end
end
