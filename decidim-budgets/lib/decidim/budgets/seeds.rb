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

      def number_of_budgets
        slow_seeds? ? rand(1..3) : 1
      end

      def call
        component = create_component!

        number_of_budgets.times do
          create_budget!(component:)
        end

        Decidim::Budgets::Budget.where(component:).each do |budget|
          number_of_records.times do
            project = create_project!(budget:)

            create_attachments!(attached_to: project)

            Decidim::Comments::Seed.comments_for(project)
          end
          create_budget_votes!(budget:)
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

      def create_budget_votes!(budget:)
        min_budgets_votes_count = config_value(:budgets_votes_count) / 5
        max_budgets_votes_count = config_value(:budgets_votes_count) * 2

        users = users_pool.sample(rand(min_budgets_votes_count..max_budgets_votes_count))
        users = users.index_by(&:id)

        orders = []
        line_items = {}
        users.values.each do |user|
          projects = select_projects_to_order(budget:)

          orders << {
            decidim_budgets_budget_id: budget.id,
            decidim_user_id: user.id,
            checked_out_at: can_checkout?(budget, projects) ? Time.current : nil
          }
          line_items[user.id] = projects.map do |project|
            { decidim_project_id: project.id }
          end
        end

        # rubocop:disable Rails/SkipsModelValidations
        result = Decidim::Budgets::Order.insert_all(orders, returning: %w(id decidim_user_id))
        result.each do |row|
          user = users[row["decidim_user_id"]]
          Decidim.traceability.perform_action!(
            "create",
            Decidim::Budgets::Order,
            user,
            visibility: "private-only"
          ) do
            SeedOrder.new(
              id: row["id"],
              type: "Decidim::Budgets::Order",
              decidim_component_id: budget.decidim_component_id
            )
          end

          line_items[user.id].each do |item|
            item[:decidim_order_id] = row["id"]
          end
        end
        Decidim::Budgets::LineItem.insert_all(line_items.values.flatten)
        # rubocop:enable Rails/SkipsModelValidations
      end

      def users_pool
        @users_pool ||= begin
          emails = (config_value(:budgets_votes_count) * 2).times.map do |n|
            random_email(suffix: "budget-vote-#{n}")
          end
          bulk_find_or_create_users(emails:)
        end
      end

      def select_projects_to_order(budget:)
        selected_projects = []
        total_budget = 0

        budget.projects.shuffle.each do |candidate|
          next if selected_projects.include?(candidate)
          next if total_budget + candidate.budget_amount > budget.total_budget

          selected_projects << candidate
          total_budget += candidate.budget_amount
        end

        selected_projects
      end

      def can_checkout?(budget, selected_projects)
        if budget.settings.voting_rule == "selected_projects"
          selected_projects.count >= budget.settings.vote_selected_projects_minimum && selected_projects.count <= budget.settings.vote_selected_projects_maximum
        elsif budget.settings.voting_rule == "minimum_projects"
          selected_projects.count >= budget.settings.vote_minimum_budget_projects_number
        else
          minimum_budget = budget.total_budget.to_f * (budget.settings.vote_threshold_percent.to_f / 100)
          selected_projects.sum(&:budget_amount).to_f >= minimum_budget
        end
      end

      SeedOrder = Struct.new(:id, :type, :decidim_component_id) do
        def valid?
          true
        end
      end
    end
  end
end
