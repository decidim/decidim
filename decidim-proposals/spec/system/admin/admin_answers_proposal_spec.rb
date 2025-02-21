# frozen_string_literal: true

require "spec_helper"

describe "Admin answers proposals" do
  let(:manifest_name) { "proposals" }
  let(:proposal_answers_with_costs?) { false }
  let!(:component) { create(:proposal_component, participatory_space:) }
  let!(:proposals) { create_list(:proposal, 3, component:, cost_report: {}) }

  include_context "when managing a component as an admin"

  before do
    visit current_path
  end

  context "when proposals answering is enabled" do
    before do
      component.update!(
        settings: { proposal_answering_enabled: true },
        step_settings: {
          component.participatory_space.active_step.id => {
            proposal_answering_enabled: true,
            answers_with_costs: proposal_answers_with_costs?
          }
        }
      )
      visit current_path
    end

    it "when accepting, can submit answer with a text answer" do
      find("a.action-icon--show-proposal", match: :first).click
      find("label[for='proposal_answer_internal_state_accepted']").click
      fill_in_i18n_editor(
        :proposal_answer_answer,
        "#proposal_answer-answer-tabs",
        en: "An accepted answer without costs"
      )
      find("*[type=submit][name=commit]", match: :first).click
      expect(page).to have_css(".flash", text: "Proposal successfully answered.")
    end

    context "with costs enabled" do
      let(:proposal_answers_with_costs?) { true }

      before do
        find("a.action-icon--show-proposal", match: :first).click
        fill_in_i18n_editor(
          :proposal_answer_answer,
          "#proposal_answer-answer-tabs",
          en: "A text answer that is long enough to be valid"
        )
      end

      it "when accepting, a cost value and cost report are required" do
        find("input#proposal_answer_internal_state_accepted").click
        find("*[type=submit][name=commit]", match: :first).click
        expect(find("label[for=proposal_answer_cost_report]")).to have_content("Required field")
        expect(find("label[for=proposal_answer_cost]")).to have_content("Required field")
        expect(page).to have_css(".flash", text: "There was a problem answering this proposal.")
      end

      it "when rejecting, do not require a cost value or cost report" do
        find("input#proposal_answer_internal_state_rejected").click
        find("*[type=submit][name=commit]", match: :first).click
        expect(page).to have_css(".flash", text: "Proposal successfully answered.")
      end

      it "when accepting, can submit answer with a cost value and cost report" do
        find("input#proposal_answer_internal_state_accepted").click
        fill_in_i18n_editor(
          :proposal_answer_cost_report,
          "#proposal_answer-cost_report-tabs",
          en: "Cost report on the proposal"
        )
        fill_in :proposal_answer_cost, with: "50"

        find("*[type=submit][name=commit]", match: :first).click
        expect(page).to have_css(".flash", text: "Proposal successfully answered.")
      end
    end
  end
end
