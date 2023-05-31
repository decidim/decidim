# frozen_string_literal: true

require "spec_helper"

describe Decidim::Surveys::Metrics::AnswersMetricManage do
  let(:day) { Time.zone.today - 1.day }
  let(:organization) { create(:organization) }
  let(:participatory_space) { create(:participatory_process, organization:) }
  let(:surveys_component) { create(:surveys_component, :published, participatory_space:) }
  let(:survey) { create(:survey, component: surveys_component) }
  let(:questionnaire) { create(:questionnaire, questionnaire_for: survey) }
  let!(:answers) { create_list(:answer, 5, questionnaire:, created_at: day) }
  let!(:old_answers) { create_list(:answer, 5, questionnaire:, created_at: day - 1.week) }

  include_context "when managing metrics"

  context "when executing" do
    it "creates new metric records" do
      registry = generate_metric_registry

      expect(registry.collect(&:day)).to eq([day])
      expect(registry.collect(&:cumulative)).to eq([10])
      expect(registry.collect(&:quantity)).to eq([5])
    end

    it "does not create any record if there is no data" do
      registry = generate_metric_registry("2017-01-01")

      expect(Decidim::Metric.count).to eq(0)
      expect(registry).to be_empty
    end

    it "updates metric records" do
      create(:metric, metric_type: "survey_answers", day:, cumulative: 1, quantity: 1, organization:, category: nil, participatory_space:, related_object: survey)
      registry = generate_metric_registry

      expect(Decidim::Metric.count).to eq(1)
      expect(registry.collect(&:cumulative)).to eq([10])
      expect(registry.collect(&:quantity)).to eq([5])
    end
  end
end
