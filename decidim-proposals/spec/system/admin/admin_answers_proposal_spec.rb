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
      within "tr", text: translated(proposals.first.title) do
        find("button[data-component='dropdown']").click
        click_on "Answer proposal"
      end
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
        within "tr", text: translated(proposals.first.title) do
          find("button[data-component='dropdown']").click
          click_on "Answer proposal"
        end
        fill_in_i18n_editor(
          :proposal_answer_answer,
          "#proposal_answer-answer-tabs",
          en: "A text answer that is long enough to be valid"
        )
      end

      shared_examples "successful handling of proposal answers" do
        it "when accepting, can submit answer with a cost, cost report and execution period" do
          find("input#proposal_answer_internal_state_accepted").click
          fill_in_i18n_editor(
            :proposal_answer_cost_report,
            "#proposal_answer-cost_report-tabs",
            en: "Cost report on the proposal"
          )
          fill_in :proposal_answer_cost, with: "50"
          fill_in_i18n_editor(
            :proposal_answer_execution_period,
            "#proposal_answer-cost_report-tabs",
            en: "Cost execution period on the proposal"
          )

          find("*[type=submit][name=commit]", match: :first).click
          expect(page).to have_css(".flash", text: "Proposal successfully answered.")
        end
      end

      it_behaves_like "successful handling of proposal answers"

      context "when proposal has likes" do
        let!(:proposals) { create_list(:proposal, 3, :with_likes, component:, cost_report: {}) }

        it_behaves_like "successful handling of proposal answers"
      end

      context "when proposal has documents" do
        let!(:proposals) { create_list(:proposal, 3, :with_document, component:, cost_report: {}) }

        it_behaves_like "successful handling of proposal answers"
      end

      context "when proposal has meetings" do
        let!(:proposals) { create_list(:proposal, 3, component:, cost_report: {}) }
        let(:meeting_component) { create(:meeting_component, participatory_space: component.participatory_space) }

        before do
          proposals.each do |proposal|
            proposal.link_resources(create(:meeting, component: meeting_component), "proposals_from_meeting")
          end
        end

        it_behaves_like "successful handling of proposal answers"
      end

      context "when proposal has photos" do
        let!(:proposals) { create_list(:proposal, 3, :with_photo, component:, cost_report: {}) }

        it_behaves_like "successful handling of proposal answers"
      end

      it "when rejecting, do not require a cost value or cost report" do
        find("input#proposal_answer_internal_state_rejected").click
        find("*[type=submit][name=commit]", match: :first).click
        expect(page).to have_css(".flash", text: "Proposal successfully answered.")
      end
    end
  end
end
