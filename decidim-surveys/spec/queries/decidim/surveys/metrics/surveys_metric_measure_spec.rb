# frozen_string_literal: true

require "spec_helper"

describe Decidim::Surveys::Metrics::SurveysMetricMeasure do
  let(:day) { Time.zone.today - 1.day }
  let(:organization) { create(:organization) }
  let(:not_valid_resource) { create(:dummy_resource) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization: organization) }

  # Answer a survey (Surveys)
  let(:surveys_component) { create(:surveys_component, :published, participatory_space: participatory_space) }
  let(:survey) { create(:survey, component: surveys_component) }
  let(:questionnaire) { create(:questionnaire, questionnaire_for: survey) }
  let(:answers) { create_list(:answer, 5, questionnaire: questionnaire, created_at: day) }
  # TOTAL Participants for Surveys: 5
  let(:all) { answers }

  context "when executing class" do
    before { all }

    it "fails to create object with an invalid resource" do
      manager = described_class.for(day, not_valid_resource)

      expect(manager).not_to be_valid
    end

    it "calculates" do
      result = described_class.for(day, surveys_component).calculate

      expect(result[:cumulative_users].count).to eq(5)
      expect(result[:quantity_users].count).to eq(5)
    end

    it "does not found any result for past days" do
      result = described_class.for(day - 1.month, surveys_component).calculate

      expect(result[:cumulative_users].count).to eq(0)
      expect(result[:quantity_users].count).to eq(0)
    end
  end
end
