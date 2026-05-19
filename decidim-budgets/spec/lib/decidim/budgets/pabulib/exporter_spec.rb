# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::Pabulib::Exporter do
  let(:exporter) { described_class.new(metadata) }

  let(:io) { StringIO.new }
  let(:output) do
    io.rewind
    io.read
  end
  let(:metadata) do
    Decidim::Budgets::Pabulib::Metadata.new(
      description: "Example description",
      country: "Finland",
      unit: "Helsinki",
      instance: "2026",
      num_projects: 5,
      num_votes: 1,
      budget: 1_000_000,
      vote_type: "approval",
      min_length: 0,
      max_length: 5,
      min_sum_cost: 0,
      max_sum_cost: 1_000_000
    )
  end

  let(:component) { create(:budgets_component, :with_minimum_budget_projects, vote_minimum_budget_projects_number: 1) }
  let(:budget) { create(:budget, component:, total_budget: 1_000_000) }
  let(:projects) do
    [
      create(:project, :selected, budget:, title: { en: "First project" }, budget_amount: 500_000),
      create(:project, :selected, budget:, title: { en: "Second project" }, budget_amount: 400_000),
      create(:project, budget:, title: { en: "Third project" }, budget_amount: 300_000),
      create(:project, budget:, title: { en: "Fourth project" }, budget_amount: 200_000),
      create(:project, :selected, budget:, title: { en: "Fifth project" }, budget_amount: 100_000)
    ]
  end
  let!(:order) do
    create(:order, budget:).tap do |order|
      create(:line_item, project: projects[0], order:)
      create(:line_item, project: projects[1], order:)

      order.reload
      order.update!(checked_out_at: Time.zone.today)
    end
  end

  describe "#export" do
    subject { exporter.export(budget, io) }

    let(:calculate_votes) do
      lambda do |project|
        Decidim::Budgets::LineItem.joins(:order).where(project:).where.not(
          decidim_budgets_orders: { checked_out_at: nil }
        ).count
      end
    end

    before { subject }

    it "exports the correct data" do
      expect(output).to eq(
        <<~OUT
          META
          key;value
          description;#{metadata.description}
          country;#{metadata.country}
          unit;#{metadata.unit}
          instance;#{metadata.instance}
          num_projects;#{metadata.num_projects}
          num_votes;#{metadata.num_votes}
          budget;#{metadata.budget}
          rule;greedy
          vote_type;#{metadata.vote_type}
          min_length;#{metadata.min_length}
          max_length;#{metadata.max_length}
          min_sum_cost;#{metadata.min_sum_cost}
          max_sum_cost;#{metadata.max_sum_cost}
          date_begin;#{order.created_at.strftime("%d.%m.%Y")}
          date_end;#{order.created_at.strftime("%d.%m.%Y")}
          PROJECTS
          project_id;name;cost;votes;selected
          #{budget.projects.map { |pr| "#{pr.id};#{pr.title["en"]};#{pr.budget_amount};#{calculate_votes.call(pr)};#{pr.selected? ? 1 : 0}" }.join("\n")}
          VOTES
          voter_id;vote
          #{order.id};#{order.projects.pluck(:id).join(",")}
        OUT
      )
    end
  end
end
