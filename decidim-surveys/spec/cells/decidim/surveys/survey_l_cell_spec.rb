# frozen_string_literal: true

require "spec_helper"

module Decidim::Surveys
  describe SurveyLCell, type: :cell do
    controller Decidim::Surveys::SurveysController

    subject { cell_html }

    let(:my_cell) { cell("decidim/surveys/survey_l", survey, context: { show_space: }) }
    let(:cell_html) { my_cell.call }
    let(:component) { survey.component }
    let(:survey) { create(:survey, starts_at: 2.days.ago, ends_at: 1.week.from_now) }
    let(:model) { survey }
    let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    context "when rendering" do
      let(:show_space) { false }

      it "renders the card" do
        expect(subject).to have_css("[id^='surveys__survey']")
      end

      it "renders the metadata" do
        expect(subject).to have_css(".card__list-metadata")
      end

      it "renders the title" do
        expect(subject).to have_content(decidim_sanitize(translated_attribute(survey.title), strip_tags: true))
        expect(subject).to have_css(".card__list-title")
      end

      it "renders the description" do
        expect(subject).to have_content(decidim_sanitize(translated_attribute(survey.description), strip_tags: true))
        expect(subject).to have_css(".card__list-text")
      end
    end
  end
end
