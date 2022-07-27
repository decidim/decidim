# frozen_string_literal: true

require "spec_helper"

describe Decidim::Surveys::Metrics::SurveyParticipantsMetricMeasure do
  let(:day) { Time.zone.yesterday }
  let(:organization) { create(:organization) }
  let(:not_valid_resource) { create(:dummy_resource) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization:) }

  # Answer a survey (Surveys)
  let(:surveys_component) { create(:surveys_component, :published, participatory_space:) }
  let(:survey) { create(:survey, component: surveys_component) }
  let(:questionnaire) { create(:questionnaire, questionnaire_for: survey) }
  let!(:answers) { create_list(:answer, 5, questionnaire:, created_at: day) }
  let!(:old_answers) { create_list(:answer, 5, questionnaire:, created_at: day - 1.week) }
  # TOTAL Participants for Surveys:
  #  Cumulative: 10
  #  Quantity: 5

  context "when executing class" do
    it "fails to create object with an invalid resource" do
      manager = described_class.new(day, not_valid_resource)

      expect(manager).not_to be_valid
    end

    it "calculates" do
      result = described_class.new(day, surveys_component).calculate

      expect(result[:cumulative_users].count).to eq(10)
      expect(result[:quantity_users].count).to eq(5)
    end

    it "does not found any result for past days" do
      result = described_class.new(day - 1.month, surveys_component).calculate

      expect(result[:cumulative_users].count).to eq(0)
      expect(result[:quantity_users].count).to eq(0)
    end
  end
end
