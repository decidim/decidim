# frozen_string_literal: true

require "spec_helper"
require "decidim/maintenance"

describe "Executing Pabulib export tasks" do
  let(:organization) { create(:organization, host: "foo.example.org") }
  let(:participatory_space) { create(:participatory_process, title: { "en" => "Process" }, organization:) }
  let(:component) { create(:budgets_component, :with_minimum_budget_projects, organization:, participatory_space:, vote_minimum_budget_projects_number: 1) }
  let(:budget) { create(:budget, component:) }
  let!(:projects) do
    [
      create(:project, budget:, budget_amount: 10_000_000),
      create(:project, budget:, budget_amount: 15_000_000),
      create(:project, budget:, budget_amount: 20_000_000)
    ]
  end
  let!(:orders) do
    [[0], [1], [2], [0, 1], [1, 2], [0, 2]].map do |items|
      create(:order, budget:).tap do |order|
        items.each do |idx|
          create(:line_item, project: projects[idx], order:)
        end

        order.reload
        order.update!(checked_out_at: Time.current)
      end
    end
  end

  describe "rake decidim:budgets:export:budget_pabulib", type: :task do
    let(:task) { Rake::Task["decidim:budgets:export:budget_pabulib"] }
    let(:output_path) { Rails.root.join("tmp/budgets/#{organization.host}_#{budget.id}_pabulib.pb") }
    let(:output) { File.read(output_path) }
    let(:calculate_votes) do
      lambda do |project|
        Decidim::Budgets::LineItem.joins(:order).where(project:).where.not(
          decidim_budgets_orders: { checked_out_at: nil }
        ).count
      end
    end

    before do
      FileUtils.mkdir_p(File.dirname(output_path))
    end

    it "creates the export with correct details" do
      task.reenable
      task.invoke(budget.id, output_path)

      expect(output).to eq(
        <<~OUT
          META
          key;value
          description;#{translated_attribute(organization.name)} - #{translated_attribute(component.name)} - #{translated_attribute(budget.title)}
          unit;#{translated_attribute(budget.title)}
          instance;#{budget.created_at.strftime("%Y")}
          num_projects;#{projects.count}
          num_votes;#{orders.count}
          budget;#{budget.total_budget}
          rule;greedy
          vote_type;approval
          min_length;1
          max_length;#{projects.count}
          date_begin;#{orders.map(&:created_at).min.strftime("%d.%m.%Y")}
          date_end;#{orders.map(&:created_at).max.strftime("%d.%m.%Y")}
          PROJECTS
          project_id;name;cost;votes;selected
          #{budget.projects.map { |pr| "#{pr.id};#{pr.title["en"]};#{pr.budget_amount};#{calculate_votes.call(pr)};#{pr.selected? ? 1 : 0}" }.join("\n")}
          VOTES
          voter_id;vote
          #{orders.map { |ord| "#{ord.id};#{ord.projects.pluck(:id).join(",")}" }.join("\n")}
        OUT
      )
    end
  end
end
