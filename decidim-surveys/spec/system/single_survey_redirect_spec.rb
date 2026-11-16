# frozen_string_literal: true

require "spec_helper"

describe "Single survey redirect" do
  include_context "with a component"

  let(:manifest_name) { "surveys" }
  let(:survey_path) { Decidim::EngineRouter.main_proxy(component).survey_path(survey) }

  context "when there is a single open published survey" do
    let!(:survey) { create(:survey, :published, :allow_responses, component:) }

    it "redirects to the survey" do
      visit_component

      expect(page).to have_current_path(survey_path, ignore_query: true)
    end
  end

  context "when there is a single closed published survey" do
    let!(:survey) { create(:survey, :published, component:) }

    it "redirects to the survey" do
      visit_component

      expect(page).to have_current_path(survey_path, ignore_query: true)
    end
  end

  context "when there is more than one published survey" do
    let!(:survey) { create(:survey, :published, :allow_responses, component:) }
    let!(:another_survey) { create(:survey, :published, :allow_responses, component:) }

    it "shows the list of surveys" do
      visit_component

      expect(page).to have_css("a.card__list", count: 2)
    end
  end

  context "when there are no published surveys" do
    let!(:survey) { create(:survey, component:) }

    it "shows the empty message" do
      visit_component

      expect(page).to have_text("No surveys match your search criteria or there is not any survey open.")
    end
  end
end
