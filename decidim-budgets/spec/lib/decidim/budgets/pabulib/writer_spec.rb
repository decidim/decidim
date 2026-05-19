# frozen_string_literal: true

require "spec_helper"

describe Decidim::Budgets::Pabulib::Writer do
  let(:writer) { described_class.new(io, metadata) }

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
      num_projects: 12,
      num_votes: 5,
      budget: 1_000_000,
      vote_type:,
      min_length: 0,
      max_length: 5,
      date_begin:,
      date_end:,
      # Specific arguments for each vote type
      # approval
      min_sum_cost: 0,
      max_sum_cost: 1_000_000,
      # ordinal
      scoring_fn: Decidim::Budgets::Pabulib::SCORING_FNS.first,
      # cumulative, scoring
      min_points: 0,
      max_points: 5,
      # cumulative
      min_sum_points: 0,
      max_sum_points: 5,
      # scoring
      default_score: 0
    )
  end
  let(:vote_type) { "approval" }
  let(:date_begin) { 14.days.ago }
  let(:date_end) { 7.days.from_now }

  describe "#write_metadata" do
    subject { writer.write_metadata }

    context "with approval vote" do
      before { subject }

      it "writes the correct metadata" do
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
            date_begin;#{metadata.date_begin.strftime("%d.%m.%Y")}
            date_end;#{metadata.date_end.strftime("%d.%m.%Y")}
          OUT
        )
      end
    end

    context "with ordinal vote" do
      let(:vote_type) { "ordinal" }

      before { subject }

      it "writes the correct metadata" do
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
            scoring_fn;#{metadata.scoring_fn}
            date_begin;#{metadata.date_begin.strftime("%d.%m.%Y")}
            date_end;#{metadata.date_end.strftime("%d.%m.%Y")}
          OUT
        )
      end
    end

    context "with cumulative vote" do
      let(:vote_type) { "cumulative" }

      before { subject }

      it "writes the correct metadata" do
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
            min_points;#{metadata.min_points}
            max_points;#{metadata.max_points}
            min_sum_points;#{metadata.min_sum_points}
            max_sum_points;#{metadata.max_sum_points}
            date_begin;#{metadata.date_begin.strftime("%d.%m.%Y")}
            date_end;#{metadata.date_end.strftime("%d.%m.%Y")}
          OUT
        )
      end
    end

    context "with scoring vote" do
      let(:vote_type) { "scoring" }

      before { subject }

      it "writes the correct metadata" do
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
            min_points;#{metadata.min_points}
            max_points;#{metadata.max_points}
            default_score;#{metadata.default_score}
            date_begin;#{metadata.date_begin.strftime("%d.%m.%Y")}
            date_end;#{metadata.date_end.strftime("%d.%m.%Y")}
          OUT
        )
      end
    end

    context "with unknown vote" do
      let(:vote_type) { "unknown" }

      it "raises InvalidMetadataError" do
        expect { subject }.to raise_error(described_class::InvalidMetadataError)
      end
    end
  end

  describe "#write_projects" do
    subject do
      writer.write_projects(projects) do |pr|
        Decidim::Budgets::Pabulib::Project.new(
          project_id: pr.id,
          name: pr.title["en"],
          cost: pr.budget_amount,
          votes: pr.id * 5,
          selected: pr.selected? ? 1 : 0
        )
      end
    end

    let(:budget) { create(:budget, total_budget: 1_000_000) }
    let(:projects) do
      [
        create(:project, :selected, title: { en: "First project" }, budget_amount: 500_000),
        create(:project, :selected, title: { en: "Second project" }, budget_amount: 400_000),
        create(:project, title: { en: "Third project" }, budget_amount: 300_000),
        create(:project, :selected, title: { en: "Fourth project" }, budget_amount: 200_000),
        create(:project, :selected, title: { en: "Fifth project" }, budget_amount: 100_000)
      ]
    end

    before { subject }

    it "writes the correct data" do
      expect(output).to eq(
        <<~OUT
          PROJECTS
          project_id;name;cost;votes;selected
          #{projects.map { |pr| "#{pr.id};#{pr.title["en"]};#{pr.budget_amount};#{pr.id * 5};#{pr.selected? ? 1 : 0}" }.join("\n")}
        OUT
      )
    end
  end

  describe "#write_votes" do
    subject do
      writer.write_votes(orders) do |ord|
        Decidim::Budgets::Pabulib::Vote.new(
          voter_id: ord.id,
          vote: ord.projects.pluck(:id).sort.join(",")
        )
      end
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
    let(:orders) do
      create_list(:order, 5, budget:).tap do |orders|
        create(:line_item, project: projects[0], order: orders[0])
        create(:line_item, project: projects[1], order: orders[0])

        create(:line_item, project: projects[1], order: orders[1])
        create(:line_item, project: projects[2], order: orders[1])
        create(:line_item, project: projects[3], order: orders[1])
        create(:line_item, project: projects[4], order: orders[1])

        create(:line_item, project: projects[1], order: orders[2])
        create(:line_item, project: projects[4], order: orders[2])

        create(:line_item, project: projects[0], order: orders[3])
        create(:line_item, project: projects[4], order: orders[3])

        create(:line_item, project: projects[0], order: orders[4])
        create(:line_item, project: projects[1], order: orders[4])
        create(:line_item, project: projects[4], order: orders[4])

        orders.each do |order|
          order.reload
          order.update!(checked_out_at: Time.zone.today)
        end
      end
    end

    before { subject }

    it "writes the correct data" do
      expect(output).to eq(
        <<~OUT
          VOTES
          voter_id;vote
          #{orders.map { |ord| "#{ord.id};#{ord.projects.pluck(:id).sort.join(",")}" }.join("\n")}
        OUT
      )
    end
  end
end
