# frozen_string_literal: true

require "spec_helper"

describe "Proposal", type: :system do
  include_context "with a feature"
  let(:manifest_name) { "proposals" }

  let!(:category) { create :category, participatory_space: participatory_process }
  let!(:scope) { create :scope, organization: organization }
  let!(:user) { create :user, :confirmed, organization: organization }
  let(:scoped_participatory_process) { create(:participatory_process, :with_steps, organization: organization, scope: scope) }

  let(:address) { "Carrer Pare Llaurador 113, baixos, 08224 Terrassa" }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }

  let(:proposal_title) { "Oriol for president" }
  let(:proposal_body) { "He will solve everything" }

  let!(:feature) do
    create(:proposal_feature,
           :with_creation_enabled,
           manifest: manifest,
           participatory_space: participatory_process)
  end

  context "when creating a new proposal" do

    before do
      login_as user, scope: :user
      visit_feature
      click_link "New proposal"
    end

    context "step_1: Start" do
      it "show current step_1 highlighted" do
        within ".wizard__steps" do
          expect(page).to have_css(".step--active", count: 1)
          expect(page).to have_css(".step--past", count: 0)
          expect(page).to have_css(".step--active.step_1")
        end
      end

      it "fill in title and body" do
        within ".new_proposal" do
          fill_in :proposal_title, with: proposal_title
          fill_in :proposal_body, with: proposal_body
          find("*[type=submit]").click
        end
      end
    end

    context "step_2: Compare" do
      let(:proposal_draft) { create(:proposal, :draft, feature: feature, title: proposal_title, body: proposal_body ) }
      before do
        visit compare_proposal_path(feature, proposal_draft)
      end


      context "with similar results" do
        before do
          create(:proposal, title: "Agusti for president", body: "He will solve everything", feature: feature)
          create(:proposal, title: "Homer for president", body: "He will not solve everything", feature: feature)
          visit compare_proposal_path(feature, proposal_draft)
        end

        it "show previous and current step_2 highlighted" do
          within ".wizard__steps" do
            expect(page).to have_css(".step--active", count: 1)
            expect(page).to have_css(".step--past", count: 1)
            expect(page).to have_css(".step--active.step_2")
          end
        end
        it "shows similar proposals" do
          expect(page).to have_css(".card--proposal", text: "Agusti for president")
          expect(page).to have_css(".card--proposal", count: 2)
        end

        it "show continue button" do
          expect(page).to have_content("My proposal is different")
        end
      end

      context "without similar results" do
        let(:proposal_draft) { create(:proposal, :draft, feature: feature, title: proposal_title, body: proposal_body ) }

        before do
          visit compare_proposal_path(feature, proposal_draft)
        end

        it "redirects to the publish step" do
          expect(page).to have_content("PUBLISH YOUR PROPOSAL")
        end

        it "shows no similar proposal found" do
          within ".flash.callout.success" do
            expect(page).to have_content("Well done! No similar proposals found")
          end
        end
      end
    end
  end

  private

  def compare_proposal_path(feature, proposal)
    Decidim::EngineRouter.main_proxy(feature).compare_proposal_path(proposal)
  end

  def preview_proposal_path(feature, proposal)
    Decidim::EngineRouter.main_proxy(feature).preview_proposal_path(proposal)
  end
end
