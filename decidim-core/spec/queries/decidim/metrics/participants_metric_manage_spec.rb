# frozen_string_literal: true

require "spec_helper"
require "decidim/debates/test/factories"
require "decidim/surveys/test/factories"
require "decidim/budgets/test/factories"
require "decidim/comments/test/factories"

describe Decidim::Metrics::ParticipantsMetricManage do
  let(:day) { Time.zone.today - 1.day }
  let(:organization) { create(:organization) }

  # Create a proposal (Proposals)
  # Give support to a proposal (Proposals)
  # Endorse (Proposals)
  # TOTAL Participants for Proposals: 16 ( 1 proposal, 10 votes, 5 endorsements )
  let(:participatory_space) { create(:participatory_process, :with_steps, organization: organization) }
  let(:proposals_component) { create(:proposal_component, :published, participatory_space: participatory_space) }
  let(:proposal) { create(:proposal, :with_endorsements, published_at: day, component: proposals_component) }
  let(:proposal_votes) { create_list(:proposal_vote, 10, created_at: day, proposal: proposal) }
  let(:proposal_endorsements) { create_list(:proposal_endorsement, 5, created_at: day, proposal: proposal) }

  # Create a debate (Debates)
  # TOTAL Participants for Debates: 5
  let(:debates_component) { create(:debates_component, :published, participatory_space: participatory_space) }
  let(:debates) { create_list(:debate, 5, :with_author, component: debates_component, created_at: day) }

  # Answer a survey (Surveys)
  # TOTAL Participants for Surveys: 5
  let(:survey_component) { create(:surveys_component, :published, participatory_space: participatory_space) }
  let(:survey) { create(:survey, component: survey_component) }
  let(:questionnaire) { create(:questionnaire, questionnaire_for: survey) }
  let(:answers) { create_list(:answer, 5, questionnaire: questionnaire, created_at: day) }

  # Vote a participatory budgeting project (Budgets)
  # TOTAL Participants for Budgets: 5
  let(:budget_component) { create(:budget_component, :published, participatory_space: participatory_space, settings: { vote_threshold_percent: 0 }) }
  let(:orders) { create_list(:order, 5, component: budget_component, checked_out_at: day) }

  # Leave a comment (Comments)
  # TOTAL Participants for Comments: 2
  let(:comments) { create_list(:comment, 2, root_commentable: proposal, commentable: proposal, created_at: day) }

  # TOTAL Participants: 33
  let(:all) { proposal && proposal_votes && proposal_endorsements && debates && answers && orders && comments }

  context "when executing" do
    context "without data" do
      it "does not create any record" do
        expect(Decidim::Metric.count).to eq(0)
        generate_metric_registry
        expect(Decidim::Metric.count).to eq(0)
      end
    end

    context "with data" do
      before { all }

      it "creates new metric records" do
        registry = generate_metric_registry

        expect(registry.collect(&:day)).to eq([day])
        expect(registry.collect(&:cumulative)).to eq([33])
        expect(registry.collect(&:quantity)).to eq([33])
      end

      it "does not create any record if there is no data" do
        registry = generate_metric_registry("2017-01-01")

        expect(Decidim::Metric.count).to eq(0)
        expect(registry).to be_empty
      end

      it "updates metric records" do
        create(:metric, metric_type: "participants", day: day, cumulative: 1, quantity: 1, organization: organization, category: nil, participatory_space: participatory_space)
        registry = generate_metric_registry

        expect(Decidim::Metric.count).to eq(1)
        expect(registry.collect(&:cumulative)).to eq([33])
        expect(registry.collect(&:quantity)).to eq([33])
      end
    end
  end
end

def generate_metric_registry(date = nil)
  metric = described_class.for(date, organization)
  metric.save
end
