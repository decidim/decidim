# frozen_string_literal: true

require "spec_helper"

describe Decidim::OpenDataExporter do # rubocop:disable RSpec/SpecFilePathFormat
  subject { described_class.new(organization, path) }

  let(:organization) { create(:organization) }
  let(:path) { Rails.root.join("tmp/open-data-export") }

  describe "published survey user responses" do
    let(:component) { create(:surveys_component, organization:, published_at: Time.current) }
    let(:questionnaire) { create(:questionnaire) }
    let(:questions) { create(:questionnaire_question, survey_responses_published_at: Time.current) }

    context "when no responses are published" do
      before do
        questions.update(survey_responses_published_at: nil)
      end

      it "does not export unpublished responses" do
        subject.export

        csv_file = Dir.glob(path.join("*published-survey-user-responses*.csv")).first

        expect(CSV.read(csv_file, headers: true).count).to eq(0) if csv_file
      end
    end

    context "when survey component is unpublished" do
      before do
        component.update(published_at: nil)
        questions.update(survey_responses_published_at: nil)
      end

      it "does not export responses from unpublished responses" do
        subject.export

        csv_file = Dir.glob(path.join("*published-survey-user-responses*.csv")).first

        expect(CSV.read(csv_file, headers: true).count).to eq(0) if csv_file
      end
    end
  end
end
