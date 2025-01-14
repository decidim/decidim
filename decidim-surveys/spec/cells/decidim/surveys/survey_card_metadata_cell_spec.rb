# frozen_string_literal: true

require "spec_helper"

module Decidim::Surveys
  describe SurveyCardMetadataCell, type: :cell do
    controller Decidim::Surveys::SurveysController

    subject { cell_html }

    let(:my_cell) { cell("decidim/surveys/survey_card_metadata", survey) }
    let(:cell_html) { my_cell.call }
    let(:survey) { create(:survey, published_at: Time.current, starts_at: 2.days.ago, ends_at: 1.week.from_now) }
    let(:component) { survey.component }
    let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }

    describe "duration" do
      context "when survey is open" do
        before do
          allow(survey).to receive(:open?).and_return(true)
        end

        it "renders the 'open' text and the time-line icon" do
          expect(subject.to_s).to include(I18n.t("open", scope: "decidim.surveys.surveys.show"))
          expect(subject.to_s).to include("time-line")
        end
      end

      context "when survey is closed" do
        before do
          allow(survey).to receive(:open?).and_return(false)
        end

        it "renders the 'closed' text and the time-line icon" do
          expect(subject.to_s).to include(I18n.t("closed", scope: "decidim.surveys.surveys.show"))
          expect(subject.to_s).to include("time-line")
        end
      end
    end

    describe "questions_count_item" do
      it "renders the correct number of questions and survey icon" do
        questions_count = survey.questionnaire.questions.size
        expect(subject.to_s).to include("#{questions_count} #{I18n.t("questions", scope: "decidim.surveys.surveys.show")}")
        expect(subject.to_s).to include("survey-line")
      end
    end
  end
end
