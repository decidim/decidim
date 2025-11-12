# frozen_string_literal: true

require "spec_helper"
require "csv"

require "decidim/core/test/shared_examples/open_data_exporter_examples"

describe Decidim::OpenDataExporter do
  subject { described_class.new(organization, path) }

  let(:organization) { create(:organization) }
  let(:path) { Rails.root.join("tmp/open-data-export") }

  describe "published survey user responses" do
    let(:resource_file_name) { "published-survey-user-responses" }
    let(:participatory_process) { create(:participatory_process, organization:) }

    let(:component) do
      create(:surveys_component, participatory_space: participatory_process, published_at: Time.current)
    end
    let!(:published_survey) { create(:survey, :published, component:) }
    let!(:published_question) { create(:questionnaire_question, questionnaire: published_survey.questionnaire) }
    let!(:published_responses) do
      3.times.map do
        create(:response, questionnaire: published_survey.questionnaire, question: published_question)
      end
    end

    let(:unpublished_component) do
      create(:surveys_component, participatory_space: participatory_process, published_at: nil)
    end
    let!(:unpublished_survey) { create(:survey, component: unpublished_component) }

    before do
      published_question.update(survey_responses_published_at: Time.current)
    end

    it_behaves_like "open data exporter"
  end
end
